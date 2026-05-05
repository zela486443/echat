import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class BotsScreen extends StatelessWidget {
  const BotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mocking the getBots() visually to show integration parity
    final List<Map<String, dynamic>> defaultBots = [
      {'id': '1', 'name': 'Helper Bot', 'username': 'helper', 'desc': 'Your friendly assistant. Ask me anything!', 'color': Colors.blue},
      {'id': '2', 'name': 'Reminder Bot', 'username': 'reminder', 'desc': 'Set reminders and never forget important tasks.', 'color': Colors.green},
      {'id': '3', 'name': 'Quiz Bot', 'username': 'quiz', 'desc': 'Test your knowledge with fun trivia questions!', 'color': Colors.orange},
      {'id': '4', 'name': 'News Bot', 'username': 'news', 'desc': 'Stay updated with the latest headlines.', 'color': Colors.red},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Echats Bots', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: defaultBots.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final bot = defaultBots[index];
          return ListTile(
            onTap: () {
              // Navigate to specific bot logic
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${bot['name']}...')));
            },
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: (bot['color'] as Color).withOpacity(0.2),
              child: Icon(Icons.smart_toy, color: bot['color']),
            ),
            title: Text(bot['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${bot['username']}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  bot['desc'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.7)),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text('Start', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
