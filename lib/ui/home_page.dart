import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_breath/persistant/sb_viewmodel.dart';

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
              child: Platform.isWindows ? _buildServerUI(viewModel) : _buildClientUI(),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildServerUI(SbViewmodel vm) {
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
