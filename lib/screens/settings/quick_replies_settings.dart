import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class QuickRepliesSettingsScreen extends StatelessWidget {
  const QuickRepliesSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Quick Replies', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: const Text('Type a shortcut like "/hello" in any chat to quickly paste the full message.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          _buildQuickReply(context, '/hello', 'Hello! Thanks for reaching out. How can we help you today?'),
          _buildQuickReply(context, '/thanks', 'Thank you for your business! Have a great day.'),
          _buildQuickReply(context, '/address', 'Our office is located at 123 Flutter St, Tech City.'),
        ],
      ),
    );
  }

  Widget _buildQuickReply(BuildContext context, String shortcut, String message) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(shortcut, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
      subtitle: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
