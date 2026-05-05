import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sounds = ['Aurora', 'Bambo', 'Chord', 'Complete', 'Hello', 'Input', 'Keys', 'Note', 'Pop', 'Synth'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Message Sound', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          final isSelected = index == 2;
          return ListTile(
            title: Text(sounds[index]),
            trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
            onTap: () {},
          );
        },
      ),
    );
  }
}
