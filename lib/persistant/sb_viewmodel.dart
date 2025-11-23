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
  String clientStatus = 'Initializing...';

  bool isConnected = false;
  bool isConnectedWithClient = false;

  SbViewmodel() {
    _tcp.messages.listen((msg) {
      if (msg.text.startsWith('PLAY:')) {
        final url = msg.text.substring(5);
        final song = audio.firstWhere(
          (s) => s.url == url,
          orElse: () => Audio(title: 'Unknown', url: url),
        );
        nowPlaying = song;
        AudioPlayerService.playUrl(url);
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
      } else if (msg.text == 'CLEAR') {
        audio.clear();
        notifyListeners();
      }
    });
    if (Platform.isWindows) {
      _startAsServer();
    } else {
      status = 'Server not connected';
      clientStatus = 'Waiting for client...';
      notifyListeners();
    }
  }

  Future<void> _startAsServer() async {
    status = 'Starting server...';
    notifyListeners();

    String localIp = await Network.getLocalIp();
    await _tcp.startServer(localIp: localIp);
    status = 'Server running at $localIp\nConnect your client, to ip up above';

    isConnected = true;
    isConnectedWithClient = false;
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
      status = 'Connected to $serverIp:$port';
      clientStatus = 'Client connected';
      isConnected = true;
      isConnectedWithClient = true;
    } else {
      status = 'Failed to connect';
      clientStatus = 'Client could not connect';
      isConnected = false;
      isConnectedWithClient = false;
    }
    notifyListeners();
  }

  void addAudio(String url, {String? title, String? artist}) {
    final songTitle = title ?? url.split('/').last.split('?').first;
    final song = Audio(title: songTitle, url: url);
    audio.add(song);
    _tcp.sendMessage(
      'ADD:$url|${song.title}${artist != null ? '|$artist' : ''}',
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
