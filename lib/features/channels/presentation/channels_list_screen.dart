import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChannelsListScreen extends ConsumerWidget {
  const ChannelsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Using mock channels mapping Channels.tsx
    final channels = List.generate(10, (i) => {
      'id': 'chan_$i',
      'name': 'Echats Global Announce',
      'subscribers': 1200 + (i * 10),
      'is_verified': i == 0,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: channels.length,
        separatorBuilder: (context, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chan = channels[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Icon(LucideIcons.radio, color: Colors.white),
            ),
            title: Row(
              children: [
                Text(chan['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (chan['is_verified'] as bool) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.blue, size: 16),
                ]
              ],
            ),
            subtitle: Text('${chan['subscribers']} subscribers', style: const TextStyle(color: Colors.grey)),
            trailing: OutlinedButton(
              onPressed: () {}, // Deep link into ChannelView
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Join'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.primaryColor,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
