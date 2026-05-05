import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SystemSettingsScreen extends StatelessWidget {
  const SystemSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aggregates standard React settings screens (Privacy, Notifications, Data Storage)
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(title: 'Account', items: [
            _Item(icon: LucideIcons.lock, title: 'Privacy and Security', route: '/settings/privacy'),
            _Item(icon: LucideIcons.cloud, title: 'Data and Storage', route: '/settings/data'),
            _Item(icon: LucideIcons.bell, title: 'Notifications and Sounds', route: '/settings/notifications'),
            _Item(icon: LucideIcons.smartphone, title: 'Devices', route: '/settings/devices'),
          ]),
          const SizedBox(height: 24),
          _SettingsSection(title: 'Chat Settings', items: [
            _Item(icon: LucideIcons.image, title: 'Chat Wallpaper', route: '/settings/wallpaper'),
            _Item(icon: LucideIcons.messageSquare, title: 'Quick Replies', route: '/settings/quick-replies'),
            _Item(icon: LucideIcons.briefcase, title: 'Business Profile', route: '/settings/business-profile'),
          ]),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_Item> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
             children: items.map((i) => ListTile(
               leading: Icon(i.icon, color: Colors.grey),
               title: Text(i.title),
               trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
               onTap: () {}, // Navigate
             )).toList(),
          ),
        )
      ],
    );
  }
}

class _Item {
  final IconData icon;
  final String title;
  final String route;
  _Item({required this.icon, required this.title, required this.route});
}
