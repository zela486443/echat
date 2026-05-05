import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/call_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:intl/intl.dart';

class CallsScreen extends ConsumerWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final callLogsAsync = ref.watch(callLogsProvider);
    final currentUserId = ref.watch(authProvider).value?.id;

    // Listen to changes to refetch if needed
    ref.listen(callLogsStreamProvider, (_, __) {
      ref.invalidate(callLogsProvider);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add_call), onPressed: () {}),
        ],
      ),
      body: callLogsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No call history.'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.link, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Create Call Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Share a link for your Echats call', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Recent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = logs[index];
                    final isVideo = log.callType == 'video';
                    final isOutgoing = log.callerId == currentUserId;
                    final peerProfile = isOutgoing ? log.receiver : log.caller;
                    final isMissed = log.status == 'missed';

                    final timeStr = DateFormat.jm().format(log.createdAt.toLocal());
                    final dateStr = DateFormat.MMMd().format(log.createdAt.toLocal());

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.surface,
                        backgroundImage: peerProfile?['avatar_url'] != null 
                            ? NetworkImage(peerProfile!['avatar_url']) 
                            : null,
                        child: peerProfile?['avatar_url'] == null 
                            ? const Icon(Icons.person) 
                            : null,
                      ),
                      title: Text(
                        peerProfile?['name'] ?? peerProfile?['username'] ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMissed ? Colors.redAccent : theme.colorScheme.onBackground,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(
                            isOutgoing 
                              ? Icons.call_made 
                              : (isMissed ? Icons.call_missed : Icons.call_received),
                            size: 14,
                            color: isMissed ? Colors.redAccent : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text('${log.createdAt.day == DateTime.now().day ? 'Today' : dateStr}, $timeStr', 
                            style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
                        ],
                      ),
                      trailing: Icon(
                        isVideo ? Icons.videocam : Icons.call,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                  childCount: logs.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.gradientAurora,
          ),
          child: const Icon(Icons.add_ic_call, color: Colors.white),
        ),
      ),
    );
  }
}
