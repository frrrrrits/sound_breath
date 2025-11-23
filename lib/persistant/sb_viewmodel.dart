import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sound_breath/constants/app_constants.dart';
import 'package:sound_breath/data/audio_player_service.dart';
import 'package:sound_breath/model/audio.dart';
import 'package:sound_breath/networking/tcp_connection.dart';
import 'package:sound_breath/utils/message.dart';
import 'package:sound_breath/utils/network.dart';

class SbViewmodel extends ChangeNotifier {
  final TcpConnection _tcp = TcpConnection();
  List<Message> messages = [];
  List<Audio> audio = [];

  Audio? nowPlaying;
  String status = 'Initializing...';
  String clientStatus = 'Disconnected';

  bool isConnected = false;
  bool isConnectedWithClient = false;

  SbViewmodel() {
    _tcp.messages.listen((msg) {
      if (msg.text.startsWith('200')) {
        clientStatus = 'Client Connected';
        isConnectedWithClient = true;
        notifyListeners();
      } else if (msg.text.startsWith('400')) {
        clientStatus = 'Client Disconnected';
        isConnectedWithClient = false;
        notifyListeners();
      }

      if (msg.text.startsWith('PLAY:')) {
        final url = msg.text.substring(5);
        final song = audio.firstWhere(
          (s) => s.url == url,
          orElse: () => Audio(title: 'Unknown', url: url),
        );
        nowPlaying = song;
        if (Platform.isWindows) {
          AudioPlayerService.playUrl(url);
          messages.add(msg);
        }
        notifyListeners();
      } else if (msg.text.startsWith('ADD:')) {
        final parts = msg.text.substring(4).split('|');
        final url = parts[0];
        final title = parts.length > 1
            ? parts[1]
            : url.split('/').last.split('?').first;
        final song = Audio(title: title, url: url);
        if (!audio.any((s) => s.url == url)) {
          audio.add(song);
          notifyListeners();
        }
      }
    });
    if (Platform.isWindows) {
       _startAsServer();
    } else {
      status = 'Server not connected';
      notifyListeners();
    }
  }

  Future<void> _startAsServer() async {
    status = 'Starting server...';
    notifyListeners();

    String localIp = await Network.getLocalIp();
    await _tcp.startServer(localIp: localIp);
    status = 'Server running at $localIp\nConnect your client, to ip above';

    isConnected = true;
    notifyListeners();
  }

  Future<void> _startAsClient(
    String serverIp, {
    int port = AppConstants.tcpPort,
  }) async {
    status = 'Connecting to server...';
    notifyListeners();

    if (serverIp.isEmpty) {
      status = 'Server not found';
      notifyListeners();
      return;
    }

    final connected = await _tcp.connectToServer(serverIp, port);
    if (connected) {
      status = 'Connected to server';
      clientStatus = 'Client connected';
      isConnected = true;
    } else {
      status = 'Failed to connect';
      clientStatus = 'Client could not connected';
      isConnected = false;
    }
    isConnectedWithClient = _tcp.isConnected();
    notifyListeners();
  }

  void addAudio(String url, {String? title, String? artist}) {
    final audioTitle = title ?? url.split('/').last.split('?').first;
    final audioItem = Audio(title: audioTitle, url: url);
    audio.add(audioItem);
    _tcp.sendMessage(
      'ADD:$url|${audioItem.title}${artist != null ? '|$artist' : ''}',
    );
    notifyListeners();
  }

  void playSong(Audio audio) {
    _tcp.sendMessage('PLAY:${audio.url}');
    nowPlaying = audio;
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _tcp.sendMessage(text.trim());
  }

  void connectToServer(String serverIp, {int port = AppConstants.tcpPort}) {
    _startAsClient(serverIp, port: port);
  }

  @override
  void dispose() {
    _tcp.dispose();
    super.dispose();
  }
}
