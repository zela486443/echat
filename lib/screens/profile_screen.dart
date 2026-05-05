import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {},
          ) // Settings
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Head Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.primaryColor,
                      backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                      child: profile?.avatarUrl == null
                        ? Text(
                            (profile?.name ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          )
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                        ),
                        child: const Icon(LucideIcons.camera, color: Colors.white, size: 16),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(profile?.name ?? 'No Name', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('@${profile?.username ?? 'username'}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              
              const SizedBox(height: 32),
              
              // Menu Cards
              _SettingsGroup(
                theme: theme,
                title: 'Account',
                items: [
                  _SettingsItem(icon: LucideIcons.user, label: 'Personal Information'),
                  _SettingsItem(icon: LucideIcons.shield, label: 'Security & Privacy'),
                  _SettingsItem(icon: LucideIcons.creditCard, label: 'Payment Methods'),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _SettingsGroup(
                theme: theme,
                title: 'Preferences',
                items: [
                  _SettingsItem(icon: LucideIcons.bell, label: 'Notifications'),
                  _SettingsItem(icon: LucideIcons.globe, label: 'Language'),
                  _SettingsItem(icon: LucideIcons.moon, label: 'Dark Mode', isSwitch: true, value: true),
                ],
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
                icon: const Icon(LucideIcons.logOut),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.theme, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: theme.primaryColor),
                    title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: item.isSwitch
                        ? Switch(value: item.value, onChanged: (v) {}, activeColor: theme.primaryColor)
                        : const Icon(LucideIcons.chevronRight, size: 20, color: Colors.grey),
                    onTap: item.isSwitch ? null : () {},
                  ),
                  if (idx < items.length - 1) Divider(height: 1, indent: 50, color: Colors.grey.withOpacity(0.1)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final bool isSwitch;
  final bool value;

  _SettingsItem({required this.icon, required this.label, this.isSwitch = false, this.value = false});
}
