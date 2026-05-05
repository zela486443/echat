import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Simulated Channels List
    final List<Map<String, dynamic>> channels = [
      {'name': 'Echats Official Announcements', 'subscribers': '1.2M', 'lastMessage': 'Welcome to the new update!'},
      {'name': 'Flutter Devs Ethiopia', 'subscribers': '24K', 'lastMessage': 'Riverpod tutorial starting soon.'},
      {'name': 'Sports Daily', 'subscribers': '850K', 'lastMessage': 'Final score: 2-1 in extra time.'},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Channels', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        itemCount: channels.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
        itemBuilder: (context, index) {
          final ch = channels[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppTheme.gradientAurora,
              ),
              child: const Icon(Icons.campaign, color: Colors.white),
            ),
            title: Text(ch['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${ch['subscribers']} subscribers', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  ch['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6)),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              child: Text(
                'Join',
                style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.gradientAurora,
          ),
          child: const Icon(Icons.add_comment, color: Colors.white),
        ),
      ),
    );
  }
}
