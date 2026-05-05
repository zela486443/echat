import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildSearchBarSliver(),
              _buildProfilesSliver(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: const Text('Search Users', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]), borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.userPlus, color: Colors.white, size: 16),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              const Icon(LucideIcons.search, color: Colors.white38, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Search by username...', hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilesSliver() {
    final service = ref.watch(supabaseServiceProvider);
    return FutureBuilder(
      future: service.searchProfiles(_searchQuery),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
        final profiles = snapshot.data!;
        if (profiles.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('No users found.', style: TextStyle(color: Colors.white38))));
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = profiles[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24, 
                          backgroundColor: Colors.white.withOpacity(0.05), 
                          backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                          child: profile.avatarUrl == null ? Text(profile.name?.substring(0, 1) ?? 'U', style: const TextStyle(color: Colors.white)) : null,
                        ),
                        if (profile.isOnline == true)
                          Positioned(bottom: 2, right: 2, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF151122), width: 2)))),
                      ],
                    ),
                    title: Row(
                      children: [
                        Text(profile.name ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.badgeCheck, color: Color(0xFF3B82F6), size: 14),
                      ],
                    ),
                    subtitle: Text('@${profile.username}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    trailing: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.messageCircle, color: Color(0xFF7C3AED), size: 16)),
                    onTap: () async {
                      final currentUserId = ref.read(authProvider).value?.id;
                      if (currentUserId == null) return;
                      
                      final chatId = await ref.read(supabaseServiceProvider).findOrCreateChat(currentUserId, profile.id);
                      if (chatId != null) {
                        context.push('/chat/$chatId');
                      }
                    },
                  ),
                );
              },
              childCount: profiles.length,
            ),
          ),
        );
      },
    );
  }
}
