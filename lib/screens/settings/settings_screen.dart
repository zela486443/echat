import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/glassmorphic_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(authProvider);
    final accent = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, profileAsync.value, accent),
          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              children: [
                _buildSectionHeader('Appearance'),
                _buildSettingsGroup([
                  _buildRow(
                    context,
                    icon: LucideIcons.moon,
                    iconColor: Colors.indigo,
                    label: 'Dark Mode',
                    trailing: Switch(value: true, onChanged: (v) {}, activeColor: accent.color),
                  ),
                  _buildRow(
                    context,
                    icon: LucideIcons.palette,
                    iconColor: Colors.pink,
                    label: 'Accent Color',
                    sub: accent.name,
                    onTap: () => context.push('/appearance-settings'),
                  ),
                  _buildRow(
                    context,
                    icon: LucideIcons.image,
                    iconColor: Colors.teal,
                    label: 'Chat Wallpaper',
                    onTap: () => context.push('/appearance-settings'),
                  ),
                ]),

                _buildSectionHeader('Notifications'),
                _buildSettingsGroup([
                  _buildRow(
                    context,
                    icon: LucideIcons.bell,
                    iconColor: Colors.blue,
                    label: 'Notifications',
                    onTap: () => context.push('/notification-settings'),
                  ),
                  _buildRow(
                    context,
                    icon: LucideIcons.volume2,
                    iconColor: Colors.orange,
                    label: 'Sound Settings',
                    onTap: () => context.push('/sound-settings'),
                  ),
                ]),

                _buildSectionHeader('Account & Security'),
                _buildSettingsGroup([
                  _buildRow(
                    context,
                    icon: LucideIcons.atSign,
                    iconColor: Colors.purple,
                    label: 'Username',
                    sub: '@${profileAsync.value?.username ?? "user"}',
                    onTap: () => context.push('/profile'),
                  ),
                  _buildRow(
                    context,
                    icon: LucideIcons.smartphone,
                    iconColor: Colors.lightBlue,
                    label: 'Active Sessions',
                    onTap: () => context.push('/active-sessions'),
                  ),
                  _buildRow(
                    context,
                    icon: LucideIcons.shield,
                    iconColor: Colors.green,
                    label: 'Privacy & Security',
                    onTap: () => context.push('/privacy-settings'),
                  ),
                  _buildRow(
                    context,
                    icon: LucideIcons.database,
                    iconColor: Colors.blueGrey,
                    label: 'Data and Storage',
                    onTap: () => context.push('/data-storage-settings'),
                  ),
                ]),

                _buildSectionHeader('Features'),
                _buildSettingsGroup([
                  _buildRow(context, icon: LucideIcons.user, iconColor: accent.color, label: 'My Profile', onTap: () => context.push('/profile')),
                  _buildRow(context, icon: LucideIcons.wallet, iconColor: Colors.green, label: 'Wallet', onTap: () => context.push('/wallet')),
                  _buildRow(context, icon: LucideIcons.gift, iconColor: Colors.pinkAccent, label: 'Gifts & Stars', onTap: () => context.push('/gifts')),
                  _buildRow(context, icon: LucideIcons.radio, iconColor: Colors.red, label: 'Live Stories', onTap: () => context.push('/live-stories')),
                  _buildRow(context, icon: LucideIcons.zap, iconColor: Colors.deepPurple, label: 'Quick Replies', onTap: () => context.push('/quick-replies')),
                  _buildRow(context, icon: LucideIcons.briefcase, iconColor: Colors.indigoAccent, label: 'Business Profile', onTap: () => context.push('/business-profile')),
                  _buildRow(context, icon: LucideIcons.users, iconColor: Colors.blueAccent, label: 'New Group', onTap: () => context.push('/new-group')),
                  _buildRow(context, icon: LucideIcons.star, iconColor: Colors.amber, label: 'Echat Features', onTap: () => context.push('/features')),
                ]),

                _buildSectionHeader('Support'),
                _buildSettingsGroup([
                  _buildRow(context, icon: LucideIcons.share, iconColor: Colors.cyan, label: 'Invite Friends', onTap: () {}),
                  _buildRow(context, icon: LucideIcons.helpCircle, iconColor: Colors.blueGrey, label: 'Help & FAQ', onTap: () {}),
                ]),

                const SizedBox(height: 32),
                _buildSignOutButton(ref),
                const SizedBox(height: 20),
                Center(child: Text('Echats v1.0.5 (Native Build)', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, dynamic profile, AccentColor accent) {
    return SliverAppBar(
      expandedHeight: 240,
      backgroundColor: const Color(0xFF0D0A1A),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Gradient Banner
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.color, accent.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: Opacity(opacity: 0.1, child: Icon(LucideIcons.sparkles, color: Colors.white, size: 200))),
                ],
              ),
            ),
            // Profile Info Overlay
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFF0D0A1A), shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFF1C1130),
                          backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                          child: profile?.avatarUrl == null ? Text(profile?.name?.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)) : null,
                        ),
                      ),
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D0A1A), width: 3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(profile?.name ?? 'Echats User', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  Text('@${profile?.username ?? "username"}', style: TextStyle(color: accent.color, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 12),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF150D28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildRow(BuildContext context, {required IconData icon, required Color iconColor, required String label, String? sub, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      subtitle: sub != null ? Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)) : null,
      trailing: trailing ?? const Icon(LucideIcons.chevronRight, color: Colors.white10, size: 16),
    );
  }

  Widget _buildSignOutButton(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: ListTile(
        onTap: () => ref.read(authProvider.notifier).signOut(),
        leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
        title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
