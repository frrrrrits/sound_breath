import 'package:flutter/material.dart';
import 'package:sound_breath/persistant/sb_viewmodel.dart';

class ClientScreen extends StatelessWidget {
  final SbViewmodel vm;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  ClientScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Paste song URL (mp3)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Song title (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            if (_urlController.text.trim().isNotEmpty) {
              vm.addAudio(
                _urlController.text.trim(),
                title: _titleController.text.trim().isEmpty
                    ? null
                    : _titleController.text.trim(),
              );
              _urlController.clear();
              _titleController.clear();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Song'),
        ),
      ],
    );
  }
}
