import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('ACCOUNT INFO'),
          _settingsTile(
            icon: LucideIcons.phone,
            title: 'Phone Number',
            subtitle: '+251 911 223 344',
            onTap: () {},
          ),
          _settingsTile(
            icon: LucideIcons.mail,
            title: 'Email Address',
            subtitle: 'user@example.com',
            onTap: () {},
          ),
          _settingsTile(
            icon: LucideIcons.userCircle,
            title: 'Username',
            subtitle: '@zola_dev',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('SECURITY'),
          _settingsTile(
            icon: LucideIcons.lock,
            title: 'Two-Step Verification',
            subtitle: 'On',
            onTap: () {},
          ),
          _settingsTile(
            icon: LucideIcons.smartphone,
            title: 'Active Sessions',
            subtitle: '3 devices',
            onTap: () {},
          ),
          _settingsTile(
            icon: LucideIcons.trash2,
            title: 'Delete Account',
            isDestructive: true,
            onTap: () {},
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _settingsTile({required IconData icon, required String title, String? subtitle, bool isDestructive = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.white.withOpacity(0.03),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: isDestructive ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70, size: 20),
        ),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
      ),
    );
  }
}
