import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class ChannelAdminScreen extends StatefulWidget {
  final String channelId;
  final String channelName;

  const ChannelAdminScreen({super.key, required this.channelId, required this.channelName});

  @override
  State<ChannelAdminScreen> createState() => _ChannelAdminScreenState();
}

class _ChannelAdminScreenState extends State<ChannelAdminScreen> {
  bool _isPublic = true;
  bool _showSignatures = false;
  bool _canMembersReact = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Channel Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSectionHeader('SETTINGS'),
          _buildAdminTile(
            icon: LucideIcons.globe,
            title: 'Channel Type',
            subtitle: _isPublic ? 'Public' : 'Private',
            onTap: () => setState(() => _isPublic = !_isPublic),
          ),
          _buildAdminTile(
            icon: LucideIcons.hash,
            title: 'Discussion Group',
            subtitle: 'Add a group for comments',
            onTap: () {},
          ),
          _buildAdminTile(
            icon: LucideIcons.userCheck,
            title: 'Sign Messages',
            subtitle: 'Show admin names on posts',
            trailing: Switch(value: _showSignatures, onChanged: (v) => setState(() => _showSignatures = v), activeColor: AppTheme.primary),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('MANAGEMENT'),
          _buildAdminTile(
            icon: LucideIcons.shield,
            title: 'Administrators',
            subtitle: '1 admin',
            onTap: () {},
          ),
          _buildAdminTile(
            icon: LucideIcons.users,
            title: 'Subscribers',
            subtitle: '1,245 people',
            onTap: () {},
          ),
          _buildAdminTile(
            icon: LucideIcons.ban,
            title: 'Removed Users',
            subtitle: '0 users',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('PERMISSIONS'),
          _buildAdminTile(
            icon: LucideIcons.smile,
            title: 'Enable Reactions',
            trailing: Switch(value: _canMembersReact, onChanged: (v) => setState(() => _canMembersReact = v), activeColor: AppTheme.primary),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18),
            label: const Text('Delete Channel', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(16)),
            child: Center(child: Text(widget.channelName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.channelName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('https://echat.chat/channel/id', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(LucideIcons.pencil, color: Colors.white38, size: 18), onPressed: () {}),
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

  Widget _buildAdminTile({required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: Colors.white.withOpacity(0.03),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)) : null,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.white24, size: 18) : null),
      ),
    );
  }
}
