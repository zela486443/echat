import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool showPreview = true;
  bool groupAlerts = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Messages'),
          SwitchListTile(
            value: showPreview,
            onChanged: (val) => setState(() => showPreview = val),
            title: const Text('Show Preview'),
            subtitle: const Text('Preview message text inside new message notifications.'),
            activeColor: theme.colorScheme.primary,
          ),
          ListTile(title: const Text('Sound'), trailing: const Text('Default >'), onTap: () {}),
          
          _buildSectionHeader('Groups'),
          SwitchListTile(
            value: groupAlerts,
            onChanged: (val) => setState(() => groupAlerts = val),
            title: const Text('Show Notifications'),
            activeColor: theme.colorScheme.primary,
          ),
          
          _buildSectionHeader('Other'),
          ListTile(title: const Text('In-App Notifications'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          const ListTile(title: Text('Reset Notification Settings', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
