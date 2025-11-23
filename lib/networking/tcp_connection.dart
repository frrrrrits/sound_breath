import 'dart:async';
import 'dart:io';

import 'package:sound_breath/constants/app_constants.dart';
import 'package:sound_breath/utils/logger.dart';
import 'package:sound_breath/utils/message.dart';

class TcpConnection {
  ServerSocket? _server;
  Socket? _socket;

  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  Stream<Message> get messages => _messageController.stream;

  Future<void> startServer({
    int port = AppConstants.tcpPort,
    String? localIp,
  }) async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    Logger.add('[startServer] Server started on $localIp:$port');
    _server!.listen((client) {
      _socket = client;
      Logger.add(
        '[startServer] Client connected: ${client.remoteAddress.address}',
      );
      _messageController.add(Message(text: '200', isMe: false));
      client.listen(
        (data) {
          final msg = String.fromCharCodes(data).trim();
          _messageController.add(Message(text: msg, isMe: false));
        },
        onDone: () {
          Logger.add('[startServer] Client disconnected');
          _messageController.add(Message(text: '400', isMe: false));
          _socket = null;
        },
      );
    });
  }

  Future<bool> connectToServer(String ip, int port) async {
    try {
      _socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 6),
      );
      Logger.add('[startClient] Connected to server $ip:$port');
      _messageController.add(Message(text: '200', isMe: false));
      _socket!.listen(
        (data) {
          final msg = String.fromCharCodes(data).trim();
          _messageController.add(Message(text: msg, isMe: false));
        },
        onDone: () {
          Logger.add('[startClient] Server disconnected');
          _messageController.add(Message(text: '200', isMe: false));
          _socket = null;
        },
      );
      return true;
    } catch (e) {
      Logger.add('Connection failed: $e');
      return false;
    }
  }

  bool isConnected()  {
    return _socket != null;
  }

  void sendMessage(String text) {
    if (_socket == null) return;
    _socket!.write('$text\n');
    _messageController.add(Message(text: text, isMe: true));
  }

  void dispose() {
    _socket?.destroy();
    _server?.close();
    _messageController.close();
  }
}
