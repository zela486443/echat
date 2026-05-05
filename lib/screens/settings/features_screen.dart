import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Echats Features', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: AppTheme.gradientAurora, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Icon(Icons.star, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text('Echats 2.0 Native', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Fully migrated to Flutter + Supabase', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildFeatureRow(context, Icons.account_balance_wallet, 'Integrated Wallet', 'Send and receive money seamlessly.'),
          _buildFeatureRow(context, Icons.video_camera_front, 'Etok Live', 'Watch short videos and stream live.'),
          _buildFeatureRow(context, Icons.smart_toy, 'AI & Bots', 'Create your own command bots or use the advanced AI assistant.'),
          _buildFeatureRow(context, Icons.lock, 'Security', 'End-to-end secured data on Supabase servers.'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String desc) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
