import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_breath/constants/app_constants.dart';
import 'package:sound_breath/model/audio.dart';
import 'package:sound_breath/persistant/sb_viewmodel.dart';
import 'package:sound_breath/ui/view/client_screen.dart';

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
                    onPressed: () => _showAlert(context, 'Input server ip', viewModel),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: ClientScreen(vm: vm),
        ),
        Expanded(
          child: vm.audio.isEmpty
              ? const Center(child: Text('No audio yet. Add one above!'))
              : ListView.builder(
                  itemCount: vm.audio.length,
                  itemBuilder: (context, i) {
                    final audio = vm.audio[i];
                    final isPlaying = vm.nowPlaying?.url == audio.url;
                    return _buildItemCard(context, audio, isPlaying, vm);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    Audio audio,
    bool isPlaying,
    SbViewmodel vm,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(
          audio.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.play_circle_fill,
          color: isPlaying ? Colors.green : Colors.deepPurple,
          size: 32,
        ),
        onTap: () => vm.playSong(audio),
      ),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: AppConstants.defaultIpAddress,
                    border: OutlineInputBorder(),
                  ),
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
