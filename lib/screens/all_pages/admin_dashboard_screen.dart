import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String title;
  const AdminDashboardScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('$title Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AuroraGradientBg(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatsOverview(),
            const SizedBox(height: 24),
            _buildSectionHeader('Management'),
            _buildAdminAction(Icons.people, 'Participants', 'Manage members and admins', Colors.blue),
            _buildAdminAction(Icons.security, 'Permissions', 'Change what members can do', Colors.orange),
            _buildAdminAction(Icons.link, 'Invite Links', 'Manage and create join links', Colors.green),
            _buildAdminAction(Icons.block, 'Removed Users', 'See who is banned', Colors.red),
            const SizedBox(height: 24),
            _buildSectionHeader('Channel Settings'),
            _buildAdminAction(Icons.edit, 'Edit Info', 'Change name, desc and photo', Colors.white38),
            _buildAdminAction(Icons.slow_motion_video, 'Slow Mode', 'Limit message frequency', Colors.purple),
            const SizedBox(height: 32),
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatMini('Members', '12.4K', Icons.people),
          _buildStatMini('Online', '842', Icons.circle),
          _buildStatMini('New (24h)', '+45', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildStatMini(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 16),
        const SizedBox(height: 8),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildAdminAction(IconData icon, String title, String subtitle, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(4),
        child: ListTile(
          leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white12),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(4),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_forever, color: Colors.red, size: 20)),
        title: const Text('Delete Group', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text('Completely remove this group and all data', style: TextStyle(color: Colors.redAccent.withOpacity(0.5), fontSize: 10)),
        onTap: () {},
      ),
    );
  }
}
