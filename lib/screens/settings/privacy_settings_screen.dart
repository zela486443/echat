import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/privacy_provider.dart';
import '../../services/privacy_service.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(privacySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Privacy and Security', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: 'Security'),
            _Group(
              children: [
                _Row(
                  label: 'Two-Step Verification',
                  value: 'Off',
                  onTap: () {},
                ),
                const _Divider(),
                _Row(
                  label: 'Passcode Lock',
                  value: 'Off',
                  onTap: () {},
                ),
                const _Divider(),
                _Row(
                  label: 'Blocked Users',
                  value: '0',
                  onTap: () {},
                ),
              ],
            ),
            const _SectionNote(note: 'Review and manage your account security settings.'),

            const _SectionTitle(title: 'Privacy'),
            _Group(
              children: [
                _Row(
                  label: 'Phone Number',
                  value: _getLabel(settings.phoneNumberVisibility),
                  onTap: () => _showSelectDialog(
                    context, 
                    ref, 
                    'Phone Number', 
                    ['everyone', 'contacts', 'nobody'], 
                    settings.phoneNumberVisibility,
                    (val) => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(phoneNumberVisibility: val)),
                  ),
                ),
                const _Divider(),
                _Row(
                  label: 'Last Seen & Online',
                  value: _getLabel(settings.lastSeenVisibility),
                  onTap: () => _showSelectDialog(
                    context, 
                    ref, 
                    'Last Seen & Online', 
                    ['everyone', 'contacts', 'nobody'], 
                    settings.lastSeenVisibility,
                    (val) => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(lastSeenVisibility: val)),
                  ),
                ),
                const _Divider(),
                _Row(
                  label: 'Profile Photos',
                  value: _getLabel(settings.profilePhotoVisibility),
                  onTap: () => _showSelectDialog(
                    context, 
                    ref, 
                    'Profile Photos', 
                    ['everyone', 'contacts', 'nobody'], 
                    settings.profilePhotoVisibility,
                    (val) => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(profilePhotoVisibility: val)),
                  ),
                ),
                const _Divider(),
                _Row(
                  label: 'Forwarded Messages',
                  value: settings.forwardedMessages ? 'Everybody' : 'Nobody',
                  onTap: () => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(forwardedMessages: !s.forwardedMessages)),
                ),
                const _Divider(),
                _Row(
                  label: 'Online Status',
                  trailing: Switch(
                    value: settings.onlineStatus,
                    onChanged: (val) => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(onlineStatus: val)),
                  ),
                ),
                const _Divider(),
                _Row(
                  label: 'Groups & Channels',
                  value: _getLabel(settings.groupsAddPermission),
                  onTap: () => _showSelectDialog(
                    context, 
                    ref, 
                    'Who can add me', 
                    ['everyone', 'contacts', 'nobody'], 
                    settings.groupsAddPermission,
                    (val) => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(groupsAddPermission: val)),
                  ),
                ),
                const _Divider(),
                _Row(
                  label: 'Voice Calls',
                  value: _getLabel(settings.callsPrivacy),
                  onTap: () => _showSelectDialog(
                    context, 
                    ref, 
                    'Who can call me', 
                    ['everyone', 'contacts', 'nobody'], 
                    settings.callsPrivacy,
                    (val) => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(callsPrivacy: val)),
                  ),
                ),
              ],
            ),

            const _SectionTitle(title: 'Messaging'),
            _Group(
              children: [
                _Row(
                  label: 'Read Receipts',
                  trailing: Switch(
                    value: settings.readReceipts,
                    onChanged: (val) => ref.read(privacySettingsProvider.notifier).patch((s) => s.copyWith(readReceipts: val)),
                  ),
                ),
                const _Divider(),
                _Row(
                  label: 'Ghost Mode',
                  trailing: Switch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
            const _SectionNote(note: 'Ghost mode allows you to read messages without notifying the sender.'),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getLabel(String value) {
    switch (value) {
      case 'everyone': return 'Everybody';
      case 'contacts': return 'My Contacts';
      case 'nobody': return 'Nobody';
      default: return value;
    }
  }

  void _showSelectDialog(
    BuildContext context, 
    WidgetRef ref, 
    String title, 
    List<String> options, 
    String currentValue,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) => RadioListTile<String>(
            title: Text(_getLabel(opt)),
            value: opt,
            groupValue: currentValue,
            onChanged: (val) {
              if (val != null) onSelect(val);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SectionNote extends StatelessWidget {
  final String note;
  const _SectionNote({required this.note});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Text(
        note,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.18)),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 16, color: Theme.of(context).dividerColor.withOpacity(0.1));
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Row({required this.label, this.value, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
            ),
          if (trailing != null) trailing!,
          if (onTap != null && trailing == null)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
