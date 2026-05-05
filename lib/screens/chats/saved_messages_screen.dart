import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/saved_messages_provider.dart';
import '../../models/saved_message.dart';
import 'package:intl/intl.dart';

class SavedMessagesScreen extends ConsumerWidget {
  const SavedMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedAsync = ref.watch(savedMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.bookmark, color: theme.primaryColor, size: 20),
            const SizedBox(width: 12),
            const Text('Saved Messages', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: savedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (messages) {
          if (messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bookmark, size: 64, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  const Text('No saved messages', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Long press on any message in a chat and tap "Save" to bookmark it here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final sm = messages[index];
              final msgData = sm.message;
              final content = msgData?['content'] ?? 'Media/File';
              
              return ListTile(
                onTap: () => context.push('/chat/${sm.chatId}?highlight=${sm.messageId}'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: Row(
                  children: [
                    const Text('Sender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d, h:mm a').format(sm.savedAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (sm.note != null) ...[
                      const SizedBox(height: 4),
                      Text('Note: ${sm.note}', style: TextStyle(color: theme.primaryColor, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                  onPressed: () {},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
