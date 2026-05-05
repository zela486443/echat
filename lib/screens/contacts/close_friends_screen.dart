import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class CloseFriendsScreen extends StatefulWidget {
  const CloseFriendsScreen({super.key});

  @override
  State<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends State<CloseFriendsScreen> {
  final List<String> closeFriends = ['Alex', 'Sarah'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Close Friends', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            color: Colors.green.withOpacity(0.1),
            child: const Column(
              children: [
                Icon(Icons.star, color: Colors.green, size: 48),
                SizedBox(height: 16),
                Text('Share with Close Friends', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                SizedBox(height: 8),
                Text(
                  'Only these people will be able to see your private stories and Etok updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final isFriend = index < 2;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: const Icon(Icons.person),
                  ),
                  title: Text('Contact $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isFriend ? Colors.green.withOpacity(0.2) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isFriend ? Colors.green : theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Text(
                      isFriend ? 'Remove' : 'Add',
                      style: TextStyle(color: isFriend ? Colors.green : theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
