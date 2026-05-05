import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';

const _kBg   = Color(0xFF0D0A1A);
const _kCard = Color(0xFF150D28);
const _kP    = Color(0xFF7C3AED);

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final Set<String> _selected = {};
  bool _creating = false;
  List<Map<String, dynamic>> _contacts = [];
  bool _loadingContacts = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final userId = ref.read(authProvider).value?.id;
      if (userId == null) return;

      // Load chats to get contact IDs
      final chats = await Supabase.instance.client
          .from('chats')
          .select('user1_id, user2_id')
          .or('user1_id.eq.$userId,user2_id.eq.$userId');

      final contactIds = <String>{};
      for (final chat in chats) {
        final u1 = chat['user1_id'] as String;
        final u2 = chat['user2_id'] as String;
        if (u1 != userId) contactIds.add(u1);
        if (u2 != userId) contactIds.add(u2);
      }

      final profiles = await Future.wait(
        contactIds.map((id) => Supabase.instance.client.from('profiles').select('id, name, username, avatar_url, is_online').eq('id', id).maybeSingle()),
      );

      setState(() {
        _contacts = profiles.whereType<Map<String, dynamic>>().toList();
        _loadingContacts = false;
      });
    } catch (e) {
      setState(() => _loadingContacts = false);
    }
  }

  Future<void> _createGroup() async {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Please enter a group name'); return; }
    if (_selected.isEmpty) { _snack('Please select at least one member'); return; }

    setState(() => _creating = true);
    try {
      final userId = ref.read(authProvider).value?.id;
      if (userId == null) return;

      // Create group
      final group = await Supabase.instance.client.from('groups').insert({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'created_by': userId,
      }).select().single();

      // Add creator as admin
      await Supabase.instance.client.from('group_members').insert({'group_id': group['id'], 'user_id': userId, 'role': 'admin'});

      // Add selected members
      await Supabase.instance.client.from('group_members').insert([
        for (final id in _selected) {'group_id': group['id'], 'user_id': id, 'role': 'member'},
      ]);

      _snack('Group created!');
      if (mounted) context.go('/group/${group['id']}');
    } catch (e) {
      _snack('Failed to create group: $e');
    } finally {
      setState(() => _creating = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _kP));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 4, 12, 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.pop()),
              const Expanded(child: Text('New Group', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              GestureDetector(
                onTap: _creating ? null : _createGroup,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: _nameCtrl.text.trim().isNotEmpty && _selected.isNotEmpty
                        ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)])
                        : null,
                    color: _nameCtrl.text.trim().isEmpty || _selected.isEmpty ? Colors.white12 : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _creating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ]),
          ),

          // Group info section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar
              Stack(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08), border: Border.all(color: Colors.white12)),
                  child: const Icon(LucideIcons.users, color: Colors.white38, size: 28),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]), shape: BoxShape.circle, border: Border.all(color: _kBg, width: 2)),
                    child: const Icon(LucideIcons.camera, color: Colors.white, size: 12),
                  ),
                ),
              ]),
              const SizedBox(width: 16),
              Expanded(child: Column(children: [
                TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  maxLength: 100,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Group name *',
                    hintStyle: const TextStyle(color: Colors.white24),
                    counterText: '',
                    filled: true, fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kP)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  maxLength: 500,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Group description (optional)',
                    hintStyle: const TextStyle(color: Colors.white24),
                    counterText: '',
                    filled: true, fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kP)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ])),
            ]),
          ),

          // Selected badge
          if (_selected.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: _kP.withOpacity(0.07), border: Border(bottom: BorderSide(color: _kP.withOpacity(0.15)))),
              child: Row(children: [
                const Icon(LucideIcons.users, color: _kP, size: 14),
                const SizedBox(width: 8),
                Text('${_selected.length} member${_selected.length > 1 ? 's' : ''} selected', style: const TextStyle(color: _kP, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),

          // Contact list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('ADD MEMBERS', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5))),
          ),
          Expanded(
            child: _loadingContacts
                ? const Center(child: CircularProgressIndicator(color: _kP))
                : _contacts.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(LucideIcons.users, color: Colors.white12, size: 48),
                        const SizedBox(height: 12),
                        const Text('No contacts yet', style: TextStyle(color: Colors.white38, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('Start chatting with people first', style: TextStyle(color: Colors.white24, fontSize: 12)),
                      ]))
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (_, i) {
                          final c = _contacts[i];
                          final id = c['id'] as String;
                          final name = (c['name'] ?? c['username'] ?? 'User') as String;
                          final username = c['username'] as String? ?? '';
                          final isOnline = c['is_online'] == true;
                          final sel = _selected.contains(id);

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
                            trailing: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: sel ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]) : null,
                                border: Border.all(color: sel ? Colors.transparent : Colors.white24, width: 1.5),
                              ),
                              child: sel ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                            ),
                            onTap: () => setState(() { if (sel) _selected.remove(id); else _selected.add(id); }),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

Color _colorFor(String uid) {
  const colors = [Color(0xFFe91e63), Color(0xFF9c27b0), Color(0xFF673ab7), Color(0xFF3f51b5), Color(0xFF2196f3), Color(0xFF00bcd4), Color(0xFF009688), Color(0xFF4caf50), Color(0xFFff9800)];
  int h = 0;
  for (final c in uid.runes) h = (c + ((h << 5) - h)) & 0xFFFFFFFF;
  return colors[h.abs() % colors.length];
}
