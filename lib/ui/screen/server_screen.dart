import 'package:flutter/material.dart';
import 'package:sound_breath/persistant/sb_viewmodel.dart';

class ServerScreen extends StatelessWidget {
  final SbViewmodel vm;
  const ServerScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: double.infinity,
              color: vm.isConnectedWithClient
                  ? Colors.grey[200]
                  : Colors.red[100],
              padding: const EdgeInsets.all(12),
              child: Text(
                vm.clientStatus,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: vm.isConnectedWithClient
                      ? Colors.green[700]
                      : Colors.red[700],
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
}
