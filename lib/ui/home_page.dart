import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sound_breath/constants/app_constants.dart';
import 'package:sound_breath/persistant/sb_viewmodel.dart';
import 'package:sound_breath/ui/screen/client_screen.dart';
import 'package:sound_breath/ui/screen/server_screen.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SbViewmodel(),
      child: Consumer<SbViewmodel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor:
                AppConstants.isMobile && viewModel.isConnectedWithClient
                ? const Color.fromARGB(255, 0, 0, 0)
                : Colors.white,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Platform.isWindows
                  ? ServerScreen(vm: viewModel)
                  : ClientScreen(vm: viewModel),
            ),
            floatingActionButton: Platform.isWindows
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                        onPressed: () => _inputAudioDialog(
                          context,
                          'Add a audio',
                          viewModel,
                        ),
                        child: const Icon(Icons.add),
                      ),
                      SizedBox(height: 8),
                      FloatingActionButton(
                        onPressed: () => _inputIpDialog(
                          context,
                          'Input server ip',
                          viewModel,
                        ),
                        child: const Icon(Icons.connect_without_contact),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _inputIpDialog(
    BuildContext context,
    String title,
    SbViewmodel vm,
  ) async {
    TextEditingController controller = TextEditingController(
      text: AppConstants.defaultIpAddress,
    );
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _showMessageDialog(
          context,
          title: title,
          widget: [
            TextFormField(
              controller: controller,
              decoration: InputDecoration(border: const OutlineInputBorder()),
            ),
          ],
          actions: [
            TextButton(
              child: const Text('Connect'),
              onPressed: () {
                final ip = controller.text.trim();
                if (vm.isConnected == false) {
                  vm.connectToServer(ip);
                }
                controller.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _inputAudioDialog(
    BuildContext context,
    String title,
    SbViewmodel vm,
  ) async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _showMessageDialog(
          context,
          title: title,
          widget: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Paste sound URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          actions: [
            TextButton(
              child: const Text('Add audio'),
              onPressed: () {
                if (urlController.text.trim().isNotEmpty) {
                  vm.addAudio(
                    urlController.text.trim(),
                    title: titleController.text.trim().isEmpty
                        ? null
                        : titleController.text.trim(),
                  );
                  urlController.clear();
                  titleController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showMessageDialog(
    BuildContext context, {
    required String title,
    required List<Widget> widget,
    required List<Widget> actions,
  }) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: ListBody(children: widget)),
      actions: actions,
    );
  }
}
