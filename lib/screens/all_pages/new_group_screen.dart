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

  // Permissions & Privacy
  bool _isPublic = false;
  bool _pSendMsgs = true;
  bool _pSendMedia = true;
  bool _pAddMembers = true;
  bool _pPinMsgs = false;
  bool _pChangeInfo = false;

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

              ])),
            ]),
          ),

          // Privacy & Permissions
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSectionHeader('PRIVACY'),
                _buildSwitchTile(
                  icon: LucideIcons.globe,
                  title: 'Public Group',
                  subtitle: 'Anyone can find and join via search',
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
                _buildSectionHeader('MEMBER PERMISSIONS'),
                _buildSwitchTile(
                  icon: LucideIcons.messageSquare,
                  title: 'Send Messages',
                  value: _pSendMsgs,
                  onChanged: (v) => setState(() => _pSendMsgs = v),
                ),
                _buildSwitchTile(
                  icon: LucideIcons.image,
                  title: 'Send Media',
                  value: _pSendMedia,
                  onChanged: (v) => setState(() => _pSendMedia = v),
                ),
                _buildSwitchTile(
                  icon: LucideIcons.userPlus,
                  title: 'Add Members',
                  value: _pAddMembers,
                  onChanged: (v) => setState(() => _pAddMembers = v),
                ),
                _buildSwitchTile(
                  icon: LucideIcons.pin,
                  title: 'Pin Messages',
                  value: _pPinMsgs,
                  onChanged: (v) => setState(() => _pPinMsgs = v),
                ),
                _buildSwitchTile(
                  icon: LucideIcons.edit3,
                  title: 'Change Group Info',
                  value: _pChangeInfo,
                  onChanged: (v) => setState(() => _pChangeInfo = v),
                ),

                // Selected badge
                if (_selected.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(color: _kP.withOpacity(0.07), border: Border(bottom: BorderSide(color: _kP.withOpacity(0.15)))),
                    child: Row(children: [
                      const Icon(LucideIcons.users, color: _kP, size: 14),
                      const SizedBox(width: 8),
                      Text('${_selected.length} member${_selected.length > 1 ? 's' : ''} selected', style: const TextStyle(color: _kP, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),

                _buildSectionHeader('ADD MEMBERS'),
                _buildContactList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Icon(icon, color: value ? _kP : Colors.white38, size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 11)) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _kP,
        activeTrackColor: _kP.withOpacity(0.3),
      ),
    );
  }

  Widget _buildContactList() {
    if (_loadingContacts) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: _kP)));
    if (_contacts.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No contacts found', style: TextStyle(color: Colors.white24))));

    return Column(
      children: _contacts.map((c) {
        final id = c['id'] as String;
        final name = (c['name'] ?? c['username'] ?? 'User') as String;
        final username = c['username'] as String? ?? '';
        final sel = _selected.contains(id);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: _colorFor(id),
            child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text('@$username', style: const TextStyle(color: Colors.white38, fontSize: 11)),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: sel ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]) : null,
              border: Border.all(color: sel ? Colors.transparent : Colors.white24, width: 1.5),
            ),
            child: sel ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
          ),
          onTap: () => setState(() { if (sel) _selected.remove(id); else _selected.add(id); }),
        );
      }).toList(),
    );
  }
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
