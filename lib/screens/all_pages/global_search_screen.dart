import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  String _query = "";
  String _activeTab = "All";
  List<String> _recentSearches = ['Abebe', 'Development Group', 'Echats Official'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () => _focusNode.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Column(
        children: [
          _buildSearchHeader(),
          if (_query.isNotEmpty) _buildTabsBar(),
          Expanded(
            child: _query.isEmpty ? _buildEmptyOrRecent() : _buildSearchResults(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, color: Colors.white38, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (val) {
                        setState(() => _query = val);
                        ref.read(profileSearchQueryProvider.notifier).state = val;
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(hintText: 'Search people, chats, channels...', hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none),
                    ),
                  ),
                  if (_query.isNotEmpty) IconButton(icon: const Icon(LucideIcons.x, color: Colors.white38, size: 16), onPressed: () => setState(() { _query = ""; _searchController.clear(); })),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsBar() {
    final tabs = ['All', 'People', 'Chats', 'Channels'];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final t = tabs[index];
          final active = _activeTab == t;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: active ? const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]) : null,
                  color: active ? null : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: Text(t, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrRecent() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('RECENT SEARCHES', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            GestureDetector(onTap: () => setState(() => _recentSearches.clear()), child: const Text('Clear All', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 16),
        ..._recentSearches.map((s) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: const Icon(LucideIcons.clock, color: Colors.white38, size: 16)),
          title: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          trailing: IconButton(icon: const Icon(LucideIcons.x, color: Colors.white24, size: 14), onPressed: () => setState(() => _recentSearches.remove(s))),
          onTap: () => setState(() { _query = s; _searchController.text = s; }),
        )),
        if (_recentSearches.isEmpty) ...[
          const SizedBox(height: 60),
          const Icon(LucideIcons.search, color: Colors.white10, size: 64),
          const SizedBox(height: 16),
          const Text('Search Everything', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Find people, chats, groups, and channels all in one place.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _buildSearchResults(WidgetRef ref) {
    final searchResults = ref.watch(searchProfilesProvider);

    return searchResults.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
      data: (profiles) {
        if (profiles.isEmpty && _query.length >= 2) {
          return const Center(child: Text('No users found', style: TextStyle(color: Colors.white38)));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            if (_activeTab == "All" || _activeTab == "People") ...[
              _buildSectionHeader('PEOPLE'),
              ...profiles.map((p) => _buildResultItem(
                p.name ?? p.username, 
                '@${p.username}', 
                p.avatarUrl ?? 'https://ui-avatars.com/api/?name=${p.name ?? p.username}', 
                'person',
                onTap: () => context.push('/profile/${p.id}'),
              )),
            ],
            if (_activeTab == "All" || _activeTab == "Chats") ...[
               _buildSectionHeader('CHATS & GROUPS'),
               _buildResultItem('Development Group', '12 members', 'https://picsum.photos/202', 'group'),
            ],
            if (_activeTab == "All" || _activeTab == "Channels") ...[
              _buildSectionHeader('CHANNELS'),
              _buildResultItem('Echats Official', '45.2K subscribers', 'https://picsum.photos/203', 'channel'),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildResultItem(String name, String subtitle, String avatar, String type, {VoidCallback? onTap}) {
    IconData icon = LucideIcons.user;
    Color iconColor = const Color(0xFF7C3AED);
    if (type == 'group') { icon = LucideIcons.messageSquare; iconColor = const Color(0xFF10B981); }
    if (type == 'channel') { icon = LucideIcons.hash; iconColor = const Color(0xFFF59E0B); }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatar), radius: 24),
          Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Color(0xFF0D0A1A), shape: BoxShape.circle), child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 10)))),
        ],
      ),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      onTap: onTap,
    );
  }
}
