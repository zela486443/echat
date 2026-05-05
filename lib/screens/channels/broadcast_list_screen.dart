import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class BroadcastListScreen extends StatelessWidget {
  const BroadcastListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('New Broadcast', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Create', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: const Row(
              children: [
                Icon(Icons.campaign, color: Colors.grey),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Only contacts with your number in their address book will receive your broadcast messages.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: index % 2 == 0,
                  onChanged: (val) {},
                  secondary: CircleAvatar(
                    backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
                    child: const Icon(Icons.person),
                  ),
                  title: Text('Contact $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                  activeColor: theme.colorScheme.primary,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
