import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;


class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // In a real app we'd watch a stream from Supabase here:
    // final chats = ref.watch(chatListProvider);
    
    // Using mock data for UI creation
    final mockChats = List.generate(20, (index) => {
      'id': 'chat_$index',
      'name': 'User $index',
      'last_message': 'Hey, this is a test message that might be long...',
      'updated_at': DateTime.now().subtract(Duration(minutes: index * 10)),
      'unread': index == 0 ? 2 : 0,
      'is_online': index % 3 == 0,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: mockChats.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No chats yet', style: theme.textTheme.titleLarge),
                ],
              ),
            )
          : ListView.builder(
              itemCount: mockChats.length,
              itemBuilder: (context, index) {
                final chat = mockChats[index];
                final isUnread = (chat['unread'] as int) > 0;
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.primaryColor,
                        child: Text(chat['name'].toString().substring(0, 1), 
                          style: const TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      if (chat['is_online'] == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14, height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(chat['name'] as String, style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      )),
                      Text(
                        timeago.format(chat['updated_at'] as DateTime, locale: 'en_short'), 
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isUnread ? theme.primaryColor : Colors.grey,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        )
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['last_message'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUnread ? theme.colorScheme.onSurface : Colors.grey,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat['unread'].toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to detail router
                    // context.push('/chat/${chat['id']}');
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

