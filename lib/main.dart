import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String serviceName = 'flutter-sb-server';
  static const String serviceType = '_realtimecomm._tcp';
  static const int port = 54321;

  final List<String> _logs = [];
  final TextEditingController _controller = TextEditingController();

  ServerSocket? _server;
  Socket? _socket;
  String? _connectedIp;

@override
  void initState() {
    super.initState();
    _addLog('Initializing...');
    if (Platform.isWindows) {
      _startServer();
    } else if (Platform.isIOS) {
      _startClient();
    } else {
      _addLog('Unsupported platform (use Windows or iOS)');
    }
  }

  Future<void> _startServer() async {
    try {
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      final ip = await _getMyIp();
      _addLog('TCP Server running on $ip:$port');

      // Start mDNS advertisement
      final MDnsClient mdnsClient = MDnsClient();
      await mdnsClient.start();
      _addLog('mDNS service "$serviceName" advertised');

      // Accept clients
      _server!.listen((client) {
        _socket = client;
        _connectedIp = client.remoteAddress.address;
        _addLog('Client connected: $_connectedIp');

        client.listen(
          (data) => _addLog('Client > ${utf8.decode(data).trim()}'),
          onDone: () {
            _addLog('Client disconnected');
            _socket = null;
            _connectedIp = null;
          },
        );
      });
    } catch (e) {
      _addLog('Server error: $e');
    }
  }

  // ==================== CLIENT (iOS) ====================
  Future<void> _startClient() async {
    _addLog('Searching for server via mDNS...');

    final MDnsClient client = MDnsClient();
    await client.start();

    // Look for our service
    await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.service(serviceType),
    )) {
      if (ptr.domainName != '$serviceName.$serviceType.local') continue;

      await for (final SrvResourceRecord srv
          in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName),
          )) {
        await for (final IPAddressResourceRecord ip
            in client.lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target),
            )) {
          final String serverIp = ip.address.address;
          final int serverPort = srv.port;

          client.stop();
          _addLog('Server found: $serverIp:$serverPort');
          _connectToServer(serverIp, serverPort);
          return;
        }
      }
    }
  }

  Future<void> _connectToServer(String ip, int port) async {
    try {
      _socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 6),
      );
      _connectedIp = ip;
      _addLog('Connected to server!');

      _socket!.listen(
        (data) => _addLog('Server > ${utf8.decode(data).trim()}'),
        onDone: () => _addLog('Server disconnected'),
      );
    } catch (e) {
      _addLog('Connection failed: $e');
    }
  }

  void _send(String message) {
    if (_socket == null) {
      _addLog('Not connected');
      return;
    }
    _socket!.write('$message\n');
    _addLog('You > $message');
    _controller.clear();
  }

  void _addLog(String text) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $text');
    });
  }

  Future<String> _getMyIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
    return 'unknown';
  }

  @override
  void dispose() {
    _socket?.destroy();
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isClient = Platform.isIOS;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Platform.isWindows ? Colors.blue[100] : Colors.green[100],
              child: Center(
                child: Text(
                  Platform.isWindows
                      ? 'SERVER MODE (Windows)'
                      : 'CLIENT MODE (iOS)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
            if (isClient)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                        ),
                        onSubmitted: (_) => _send(_controller.text),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _send(_controller.text),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startServer,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
