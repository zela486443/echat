import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

const _kBg   = Color(0xFF0D0A1A);
const _kCard = Color(0xFF150D28);
const _kP    = Color(0xFF7C3AED);

Color _colorFor(String uid) {
  const colors = [Color(0xFFe91e63), Color(0xFF9c27b0), Color(0xFF673ab7), Color(0xFF3f51b5), Color(0xFF2196f3), Color(0xFF00bcd4), Color(0xFF009688), Color(0xFF4caf50), Color(0xFFff9800)];
  int h = 0;
  for (final c in uid.runes) h = (c + ((h << 5) - h)) & 0xFFFFFFFF;
  return colors[h.abs() % colors.length];
}

class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({super.key});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _contacts = [];
  bool _searching = false;
  bool _loadingContacts = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    if (_searchCtrl.text.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  Future<void> _search() async {
    setState(() => _searching = true);
    try {
      final userId = ref.read(authProvider).value?.id;
      final q = _searchCtrl.text.trim();
      final results = await Supabase.instance.client
          .from('profiles')
          .select('id, name, username, avatar_url, is_online')
          .or('username.ilike.%$q%,name.ilike.%$q%')
          .neq('id', userId ?? '')
          .limit(20);
      setState(() => _searchResults = List<Map<String, dynamic>>.from(results));
    } catch (_) {} finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _loadContacts() async {
    try {
      final userId = ref.read(authProvider).value?.id;
      if (userId == null) return;

      final chats = await Supabase.instance.client
          .from('chats')
          .select('user1_id, user2_id')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .limit(20);

      final contactIds = <String>[];
      for (final chat in chats) {
        final u1 = chat['user1_id'] as String;
        final u2 = chat['user2_id'] as String;
        if (u1 != userId && !contactIds.contains(u1)) contactIds.add(u1);
        if (u2 != userId && !contactIds.contains(u2)) contactIds.add(u2);
      }

      final profiles = await Future.wait(
        contactIds.map((id) => Supabase.instance.client.from('profiles').select('id, name, username, avatar_url, is_online').eq('id', id).maybeSingle()),
      );

      setState(() {
        _contacts = profiles.whereType<Map<String, dynamic>>().toList();
        _loadingContacts = false;
      });
    } catch (_) {
      setState(() => _loadingContacts = false);
    }
  }

  Future<void> _startChat(String otherUserId, String username) async {
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;

    try {
      // Check existing chat
      final existing = await Supabase.instance.client
          .from('chats')
          .select('id')
          .or('and(user1_id.eq.$userId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$userId)')
          .maybeSingle();

      String chatId;
      if (existing != null) {
        chatId = existing['id'] as String;
      } else {
        final created = await Supabase.instance.client.from('chats').insert({'user1_id': userId, 'user2_id': otherUserId}).select().single();
        chatId = created['id'] as String;
      }

      if (mounted) {
        context.go('/chat/$chatId');
        _snack('Chat with @$username opened');
      }
    } catch (e) {
      _snack('Failed to start chat: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _kP));
  }

  bool get _showSearch => _searchCtrl.text.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 4, 12, 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Column(children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.go('/chats')),
                const Expanded(child: Text('New Message', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 10),
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(children: [
                  const Icon(Icons.search, color: Colors.white38, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(hintText: 'Search by username…', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
                  )),
                  if (_searching) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _kP)),
                ]),
              ),
            ]),
          ),

          Expanded(child: _showSearch ? _buildSearchView() : _buildDefaultView()),
        ],
      ),
    );
  }

  Widget _buildDefaultView() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Action shortcuts
        const SizedBox(height: 8),
        _actionItem(LucideIcons.users, 'New Group', 'Create a group chat', () => context.go('/new-group')),
        _actionItem(LucideIcons.userPlus, 'Find Users', 'Search by username to start a chat', () { _snack('Search for users by username above'); }),
        _actionItem(LucideIcons.hash, 'New Channel', 'Broadcast to an audience', () => context.go('/channels')),
        const SizedBox(height: 16),

        // Recent contacts
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text('RECENT CONTACTS (${_contacts.length})', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        if (_loadingContacts)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: _kP)))
        else if (_contacts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('Search for users to start a conversation', style: TextStyle(color: Colors.white38, fontSize: 13), textAlign: TextAlign.center)),
          )
        else
          ..._contacts.take(10).map((c) => _contactTile(c)),
      ],
    );
  }

  Widget _buildSearchView() {
    if (_searching) return const Center(child: CircularProgressIndicator(color: _kP));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('SEARCH RESULTS', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        if (_searchResults.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('No users found for "${_searchCtrl.text}"', style: const TextStyle(color: Colors.white38, fontSize: 13))),
          )
        else
          ..._searchResults.map((c) => _contactTile(c)),
      ],
    );
  }

  Widget _actionItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white54, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      onTap: onTap,
    );
  }

  Widget _contactTile(Map<String, dynamic> c) {
    final id = c['id'] as String;
    final name = (c['name'] ?? c['username'] ?? 'User') as String;
    final username = (c['username'] ?? '') as String;
    final isOnline = c['is_online'] == true;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Stack(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _colorFor(id),
          child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        if (isOnline) Positioned(bottom: 1, right: 1, child: Container(width: 11, height: 11, decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: _kBg, width: 1.5)))),
      ]),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text('@$username', style: const TextStyle(color: Colors.white38, fontSize: 12)),
      onTap: () => _startChat(id, username),
    );
  }
}
