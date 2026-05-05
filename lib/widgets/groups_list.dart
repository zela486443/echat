import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/group_provider.dart';
import '../models/group.dart';
import 'chat_avatar.dart';
import 'package:timeago/timeago.dart' as timeago;

class GroupsList extends ConsumerWidget {
  final bool showChannels;
  const GroupsList({super.key, this.showChannels = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);

    return groupsAsync.when(
      data: (allGroups) {
        final groups = allGroups.where((g) => g.isChannel == showChannels).toList();
        
        if (groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(showChannels ? Icons.campaign_outlined : Icons.group_outlined, color: Colors.white24, size: 64),
                const SizedBox(height: 16),
                Text(showChannels ? 'No channels yet' : 'No groups yet', style: const TextStyle(color: Colors.white54)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              leading: ChatAvatar(
                name: group.name,
                src: group.avatarUrl,
                size: 'md',
              ),
              title: Text(
                group.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                group.description ?? 'No description',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              trailing: Text(
                timeago.format(group.updatedAt, locale: 'en_short'),
                style: const TextStyle(color: Colors.white24, fontSize: 11),
              ),
              onTap: () => context.push('/chat/group/${group.id}'),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white24))),
    );
  }
}
