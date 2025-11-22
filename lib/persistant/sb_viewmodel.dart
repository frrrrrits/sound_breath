import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sound_breath/networking/tcp_connection.dart';
import 'package:sound_breath/utils/message.dart';

class SbViewmodel extends ChangeNotifier {
  final TcpConnection _tcp = TcpConnection();
  List<Message> messages = [];
  String status = 'Initializing...';

  bool isConnected = false;
  bool isConnectedWithClient = false;

  SbViewmodel() {
    _tcp.messages.listen((msg) {
      messages.add(msg);
      notifyListeners();
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

    String localIp = await getLocalIp();
    await _tcp.startServer(localIp: localIp);

    status = 'Server running at $localIp:4040';
    isConnected = true;
    notifyListeners();
  }

  Future<void> _startAsClient(String serverIp, {int port = 4040}) async {
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
      isConnected = true;
      isConnectedWithClient = true;
    } else {
      status = 'Failed to connect';
      isConnected = false;
      isConnectedWithClient = false;
    }
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _tcp.sendMessage(text.trim());
  }

  void connectToServer(String serverIp, {int port = 4040}) {
    _startAsClient(serverIp, port: port);
  }

  @override
  void dispose() {
    _tcp.dispose();
    super.dispose();
  }

  static Future<String> getLocalIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.address.startsWith("169")) {
          return addr.address;
        }
      }
    }
    return "0.0.0.0";
  }
}
