import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class NewMessageScreen extends StatelessWidget {
  const NewMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('New Message', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true,
                fillColor: theme.colorScheme.surface,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          ListTile(
            leading: _buildIconFrame(context, Icons.group, Colors.blueAccent),
            title: const Text('New Group'),
            onTap: () => context.push('/new-group'),
          ),
          ListTile(
            leading: _buildIconFrame(context, Icons.person_add, Colors.green),
            title: const Text('New Contact'),
            onTap: () => context.push('/new-contact'),
          ),
          ListTile(
            leading: _buildIconFrame(context, Icons.campaign, Colors.orange),
            title: const Text('New Channel'),
            onTap: () {},
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: const Text('SORTED BY LAST SEEN', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: const Icon(Icons.person)),
                  title: Text('User $index', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Online'),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIconFrame(BuildContext context, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color),
    );
  }
}
