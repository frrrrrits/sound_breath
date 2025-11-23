import 'package:flutter/material.dart';
import 'package:sound_breath/persistant/sb_viewmodel.dart';
import 'package:sound_breath/ui/screen/view/card_item_view.dart';

class ClientScreen extends StatelessWidget {
  final SbViewmodel vm;
  const ClientScreen({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: vm.audio.isEmpty
              ? const Center(child: Text('No audio yet. Add one above!'))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.audio.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: CardItemView(
                        label: vm.audio[i].title,
                        onTap: () {
                          final audio = vm.audio[i];
                          vm.playSong(audio);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
