import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/device_provider.dart';
import '../../services/device_service.dart';
import '../../providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActiveSessionsScreen extends ConsumerWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(deviceSessionsProvider);
    final userProfile = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            sessionsAsync.when(
              data: (sessions) => Text('${sessions.length} devices', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (sessions) {
          final current = sessions.where((s) => s.isCurrent).toList();
          final others = sessions.where((s) => !s.isCurrent).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Manage your active sessions. Terminate any session you don\'t recognize immediately.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (current.isNotEmpty) ...[
                  const _SectionHeader(title: 'Current Session'),
                  _SessionCard(session: current.first),
                ],

                if (others.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Other Sessions (${others.length})'),
                  ...OthersList(others: others, ref: ref, userId: userProfile?.id),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (userProfile?.id != null) {
                          await ref.read(deviceServiceProvider).terminateAllOthers(userProfile!.id);
                          ref.invalidate(deviceSessionsProvider);
                        }
                      },
                      icon: const Icon(LucideIcons.trash2, size: 16),
                      label: const Text('Terminate All Other Sessions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
                
                if (others.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('No other active sessions', style: TextStyle(color: Colors.grey))),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> OthersList({required List<DeviceSession> others, required WidgetRef ref, String? userId}) {
    return others.map((s) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _SessionCard(
        session: s, 
        onTerminate: () async {
          if (userId != null) {
            await ref.read(deviceServiceProvider).terminateSession(userId, s.id);
            ref.invalidate(deviceSessionsProvider);
          }
        },
      ),
    )).toList();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final DeviceSession session;
  final VoidCallback? onTerminate;

  const _SessionCard({required this.session, this.onTerminate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = session.isCurrent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? theme.primaryColor.withOpacity(0.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? theme.primaryColor.withOpacity(0.2) : theme.dividerColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCurrent ? theme.primaryColor.withOpacity(0.1) : theme.dividerColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getIcon(session.deviceType),
              color: isCurrent ? theme.primaryColor : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        session.deviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.withOpacity(0.2)),
                        ),
                        child: const Text('This device', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(session.os, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.globe, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(session.ipAddress, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 12),
                    const Icon(LucideIcons.mapPin, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(session.location, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      isCurrent ? 'Active now' : 'Last active ${timeago.format(session.lastActive)}',
                      style: TextStyle(
                        color: isCurrent ? Colors.green : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isCurrent && onTerminate != null)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 18, color: Colors.redAccent),
              onPressed: onTerminate,
            ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'desktop': return LucideIcons.monitor;
      case 'mobile': return LucideIcons.smartphone;
      case 'tablet': return LucideIcons.tablet;
      default: return LucideIcons.globe;
    }
  }
}
