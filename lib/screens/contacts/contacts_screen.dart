import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchQuery = ref.watch(profileSearchQueryProvider);
    final resultsAsync = ref.watch(profileSearchResultsProvider);
    final suggestionsAsync = ref.watch(suggestionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: const Text('Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_alt_1), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => ref.read(profileSearchQueryProvider.notifier).state = val,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  
                ),
              ),
            ),
          ),
          
          if (searchQuery.isEmpty) ...[
            ListTile(
              leading: _buildActionIcon(Icons.location_on, Colors.blue),
              title: const Text('Find People Nearby', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
            ListTile(
              leading: _buildActionIcon(Icons.person_add, Colors.green),
              title: const Text('Invite Friends', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {},
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              color: theme.colorScheme.surface.withOpacity(0.5),
              child: Text('Suggested for you', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6), fontSize: 12)),
            ),
            
            Expanded(
              child: suggestionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (suggestions) => ListView.separated(
                  itemCount: suggestions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final profile = suggestions[index];
                    return _ContactTile(profile: profile);
                  },
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: resultsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (results) {
                  if (results.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }
                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                    itemBuilder: (context, index) {
                      final profile = results[index];
                      return _ContactTile(profile: profile);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _ContactTile extends ConsumerWidget {
  final Profile profile;
  const _ContactTile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOnline = profile.isOnline ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
        child: profile.avatarUrl == null
            ? Text(
                (profile.name ?? profile.username ?? 'U')[0].toUpperCase(),
                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
              )
            : null,
      ),
      title: Text(profile.name ?? profile.username ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        isOnline ? 'Online' : 'Last seen recently',
        style: TextStyle(color: isOnline ? AppTheme.statusOnline : theme.colorScheme.onBackground.withOpacity(0.6)),
      ),
      onTap: () async {
        final currentUserId = ref.read(authProvider).value?.id;
        if (currentUserId == null) return;
        
        final chatId = await ref.read(supabaseServiceProvider).findOrCreateChat(currentUserId, profile.id);
        if (chatId != null) {
          context.push('/chat/$chatId');
        }
      },
    );
  }
}

