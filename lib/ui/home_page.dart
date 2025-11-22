import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sound_breath/persistant/sb_viewmodel.dart';
import 'package:sound_breath/utils/logger.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SbViewmodel(),
      child: Consumer<SbViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                Platform.isWindows ? 'Server (Windows)' : 'Client (iOS)',
              ),
              backgroundColor: Platform.isWindows
                  ? Colors.blue[700]
                  : Colors.green[700],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Platform.isWindows
                  ? _buildServerUI(viewModel)
                  : _buildClientUI(context, viewModel),
            ),
            floatingActionButton: Platform.isWindows
                ? null
                : FloatingActionButton(
                    onPressed: () => _showAlert(context, 'Info', viewModel),
                    child: const Icon(Icons.connect_without_contact),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildServerUI(SbViewmodel vm) {
    return Column(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: const EdgeInsets.all(12),
              child: Text(
                vm.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: vm.isConnected
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              padding: const EdgeInsets.all(12),
              child: Text(
                vm.isConnectedWithClient
                    ? 'Client connected'
                    : 'Waiting for client...',
                style: TextStyle(
                  fontSize: 16,
                  color: vm.isConnectedWithClient
                      ? Colors.green[700]
                      : Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: vm.messages.length,
            itemBuilder: (_, i) {
              final msg = vm.messages[i];
              return Align(
                alignment: msg.isMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: msg.isMe ? Colors.blue[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: msg.isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClientUI(BuildContext context, SbViewmodel vm) {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[200],
          padding: const EdgeInsets.all(12),
          child: Text(
            vm.status,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: vm.isConnected ? Colors.green[700] : Colors.orange[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  if (vm.isConnected) {
                    vm.sendMessage(controller.text);
                    controller.clear();
                    Logger.add("Not connected to server");
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Not connected to server')),
                    );
                    Logger.add("Not connected to server");
                  }
                },
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showAlert(
    BuildContext context,
    String title,
    SbViewmodel vm,
  ) async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Input server ip address',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Connect'),
              onPressed: () {
                final ip = controller.text.trim();
                if (vm.isConnected == false) {
                  vm.connectToServer(ip);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
