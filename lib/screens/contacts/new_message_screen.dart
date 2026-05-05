import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';
import 'dart:async';

class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({super.key});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;
  List<PublicProfile> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _isLoading = true);
    final service = ref.read(supabaseServiceProvider);
    final profiles = await service.searchProfiles('');
    if (mounted) {
      setState(() {
        _results = profiles;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        setState(() => _isLoading = true);
        final service = ref.read(supabaseServiceProvider);
        final results = await service.searchProfiles(query);
        if (mounted) {
          setState(() {
            _results = results;
            _isLoading = false;
          });
        }
      } else {
        _loadInitial();
      }
    });
  }

  void _handleSelectContact(PublicProfile profile) async {
    final currentUserId = ref.read(authProvider).value?.id;
    if (currentUserId == null) return;

    final service = ref.read(supabaseServiceProvider);
    final chatId = await service.findOrCreateChat(currentUserId, profile.id);
    if (chatId != null && mounted) {
      context.pushReplacement('/chat/$chatId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildSearchField(),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildActionOption(LucideIcons.users, 'New Group', () => context.push('/new-group')),
                _buildActionOption(LucideIcons.userPlus, 'Find Users', () {}),
                _buildActionOption(LucideIcons.hash, 'New Channel', () => context.push('/new-channel')),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Align(child: Text('AVAILABLE CONTACTS', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)), alignment: Alignment.centerLeft),
                ),
              ],
            ),
          ),
          if (_isLoading && _results.isEmpty) 
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF7C3AED)))))
          else
            _buildContactsList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
      title: const Text('New Message', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: const Icon(LucideIcons.search, color: Colors.white38, size: 20),
          hintText: 'Search by username...',
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: _isLoading ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2))) : null,
        ),
        onChanged: (val) {
          setState(() => _isSearching = val.isNotEmpty);
          _onSearchChanged(val);
        },
      ),
    );
  }

  Widget _buildActionOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(radius: 20, backgroundColor: const Color(0xFF151122), child: Icon(icon, color: Colors.white70, size: 20)),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.white12, size: 18),
    );
  }

  Widget _buildContactsList() {
    if (_results.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No users found.', style: TextStyle(color: Colors.white24)))));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final user = _results[index];

          return ListTile(
            onTap: () => _handleSelectContact(user),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24, 
                  backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                  child: user.avatarUrl == null ? Text(user.name?.substring(0, 1) ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null,
                ),
                if (user.isOnline == true) Positioned(bottom: 0, right: 0, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D0A1A), width: 2)))),
              ],
            ),
            title: Text(user.name ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            subtitle: Text('@${user.username}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
          );
        },
        childCount: _results.length,
      ),
    );
  }
}
