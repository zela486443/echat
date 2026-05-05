import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

// Note: Requires "fl_chart" package in pubspec.yaml for the real React parity. I will mock the visual.
class ChatStatsScreen extends StatelessWidget {
  const ChatStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildMetric(context, 'Total Messages', '12.4K', Icons.chat)),
                const SizedBox(width: 16),
                Expanded(child: _buildMetric(context, 'Avg. Daily', '142', Icons.show_chart)),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Activity Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: const Center(child: Text('Bar Chart Placeholder (fl_chart)')),
            ),
            const SizedBox(height: 32),
            const Text('Top Contacts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            _buildTopContact(context, 'Sarah Connor', '4,231 messages'),
            _buildTopContact(context, 'Alex Smith', '2,109 messages'),
            _buildTopContact(context, 'Flutter Group', '1,834 messages'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopContact(BuildContext context, String name, String subtitle) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), child: const Icon(Icons.person)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}
