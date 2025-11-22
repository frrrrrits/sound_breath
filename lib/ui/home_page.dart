import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  String localIp = "";
  bool isServer = Platform.isWindows;
  bool connected = false;
  
  final List<String> _logs = [];
  static const int port = 4040;

  ServerSocket? _server;
  final List<Socket> _clients = [];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    localIp = await getLocalIp();
    if (isServer) {
      await startServer();
    }
    setState(() {});
  }

  
  Future<void> startServer() async {
    try {
      final server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _server = server;
      
      _addLog('Server started on $localIp:$port');

      server.listen((client) {
        _clients.add(client);
        client.listen(
          (data) => _addLog('Client > ${utf8.decode(data).trim()}'),
          onDone: () => _clients.remove(client),
        );
      });
    } catch (e) {
      _addLog("Error starting server: $e");
    }
  }

  Future<String> getLocalIp() async {
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

  void _addLog(String text) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $text');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isServer ? "Server (Windows)" : "Client (iOS)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isServer ? _buildServerUI() : _buildClientUI(),
      ),
    );
  }

  Widget _buildServerUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Platform.isWindows ? Colors.blue[100] : Colors.green[100],
          child: Center(
            child: Text(
              Platform.isWindows
                  ? 'SERVER MODE (Windows)'
                  : 'CLIENT MODE (iOS)',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _logs.length,
            itemBuilder: (_, i) => Text(_logs[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildClientUI() {
    TextEditingController ipCtrl = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: ipCtrl,
          decoration: const InputDecoration(labelText: "Enter Server IP"),
        ),
      ],
    );
  }
}
