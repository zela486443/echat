import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/stars_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final accent = ref.watch(themeProvider);
    final balance = ref.watch(starsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(user, accent),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(user, balance),
                _buildSectionTitle('APPEARANCE'),
                _buildGroup([
                  _buildSettingsRow(
                    label: 'Dark Mode',
                    right: Switch(
                      value: true,
                      onChanged: (v) {},
                      activeColor: accent.color,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    label: 'Accent Color',
                    value: accent.name,
                    onTap: () => _showAccentPicker(context, ref),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    label: 'Chat Wallpaper',
                    value: 'Default',
                    onTap: () {},
                  ),
                ]),

                _buildSectionTitle('NOTIFICATIONS'),
                _buildGroup([
                  _buildSettingsRow(
                    label: 'Push Notifications',
                    right: Switch(
                      value: true,
                      onChanged: (v) {},
                      activeColor: accent.color,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    label: 'Notification Sound',
                    value: 'Default',
                    onTap: () => context.push('/notification-settings'),
                  ),
                ]),

                _buildSectionTitle('ACCOUNT'),
                _buildGroup([
                  _buildSettingsRow(
                    label: 'Username',
                    value: user?.userMetadata?['username'] ?? 'Not Set',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    label: 'Active Sessions',
                    value: '1 Device',
                    onTap: () => context.push('/active-sessions'),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    label: 'Privacy and Security',
                    onTap: () => context.push('/privacy-settings'),
                  ),
                  _buildDivider(),
                  _buildSettingsRow(
                    label: 'Data and Storage',
                    onTap: () => context.push('/data-storage-settings'),
                  ),
                ]),

                _buildSectionTitle('FEATURES'),
                _buildGroup([
                  _buildFeatureRow(LucideIcons.user, 'My Profile', '/profile'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.wallet, 'Wallet', '/wallet'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.star, 'Gifts & Stars', '/gifts'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.tv, 'Live Stories', '/live-stories'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.zap, 'Quick Replies', '/quick-replies'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.briefcase, 'Business Profile', '/business-profile'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.bell, 'Notifications', '/notification-settings'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.volume2, 'Custom Sounds', '/sound-settings'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.users, 'New Group', '/new-group'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.list, 'Broadcast List', '/broadcast'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.clock, 'Reminders', '/reminders'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.contact, 'Contacts', '/contacts'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.phone, 'Calls', '/calls'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.bookmark, 'Saved Messages', '/saved-messages'),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.share2, 'Invite Friends', null),
                  _buildDivider(),
                  _buildFeatureRow(LucideIcons.layout, 'Echat Features', '/features'),
                ]),

                _buildSectionTitle('ADMIN TOOLS'),
                _buildGroup([
                  _buildSettingsRow(
                    label: 'Grant Verification Badge',
                    onTap: () {},
                  ),
                ]),

                _buildGroup([
                  _buildSettingsRow(
                    label: 'Sign Out',
                    destructive: true,
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ]),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(User? user, AccentColor accent) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: const Color(0xFF0D0A1A),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.color.withOpacity(0.8),
                    accent.color.withOpacity(0.2),
                    const Color(0xFF0D0A1A),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: accent.color.withOpacity(0.2),
                      backgroundImage: user?.userMetadata?['avatar_url'] != null
                          ? NetworkImage(user!.userMetadata!['avatar_url'])
                          : null,
                      child: user?.userMetadata?['avatar_url'] == null
                          ? Text(
                              (user?.userMetadata?['name'] ?? 'U')
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.userMetadata?['name'] ?? 'Echat User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${user?.userMetadata?['username'] ?? 'user'}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildProfileCard(User? user, int balance) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF150D28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wallet Balance',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.star, color: Color(0xFFFFD700), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$balance Stars',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/wallet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF7C3AED),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF150D28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Colors.white.withOpacity(0.05),
    );
  }

  Widget _buildSettingsRow({
    required String label,
    String? value,
    Widget? right,
    VoidCallback? onTap,
    bool destructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        label,
        style: TextStyle(
          color: destructive ? Colors.redAccent : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: right ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF7C3AED),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
              ],
            ],
          ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, String? route) {
    return ListTile(
      onTap: route != null ? () => context.push(route) : null,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.white10, size: 16),
    );
  }

  void _showAccentPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF150D28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Choose Accent Color',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: availableAccents.length,
            itemBuilder: (context, index) {
              final color = availableAccents[index];
              final isSelected = ref.watch(themeProvider).id == color.id;
              return GestureDetector(
                onTap: () {
                  ref.read(themeProvider.notifier).setAccent(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color.color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
