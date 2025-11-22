import 'dart:async';
import 'dart:io';

import 'package:sound_breath/utils/logger.dart';
import 'package:sound_breath/utils/message.dart';

class TcpConnection {
  ServerSocket? _server;
  Socket? _socket;

  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  Stream<Message> get messages => _messageController.stream;

  Future<void> startServer({int port = 4040, String? localIp}) async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    Logger.add('Server started on $localIp:$port');
    _server!.listen((client) {
      _socket = client;
      Logger.add('Client connected: ${client.remoteAddress.address}');
      client.listen(
        (data) {
          final msg = String.fromCharCodes(data).trim();
          _messageController.add(Message(text: msg, isMe: false));
        },
        onDone: () {
          Logger.add('Client disconnected');
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
      Logger.add('Connected to server $ip:$port');
      _socket!.listen((data) {
        final msg = String.fromCharCodes(data).trim();
        _messageController.add(Message(text: msg, isMe: false));
      }, onDone: () => Logger.add('Server disconnected'));
      return true;
    } catch (e) {
      Logger.add('Connection failed: $e');
      return false;
    }
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
