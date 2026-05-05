import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stars_provider.dart';
import '../../core/constants.dart';

const _kBg   = Color(0xFF0D0A1A);
const _kCard = Color(0xFF150D28);
const _kP    = Color(0xFF7C3AED);

Color _colorFor(String uid) {
  const colors = [Color(0xFFe91e63), Color(0xFF9c27b0), Color(0xFF673ab7), Color(0xFF3f51b5), Color(0xFF2196f3), Color(0xFF00bcd4), Color(0xFF009688), Color(0xFF4caf50), Color(0xFFff9800)];
  int h = 0;
  for (final c in uid.runes) h = (c + ((h << 5) - h)) & 0xFFFFFFFF;
  return colors[h.abs() % colors.length];
}

class ContactProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const ContactProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends ConsumerState<ContactProfileScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _isMuted = false;
  bool _isBlocked = false;
  String? _chatId;
  String _activeTab = 'media'; // media | files | notes
  late TabController _tabCtrl;

  // Shared media/files
  List<Map<String, dynamic>> _sharedMedia = [];
  List<Map<String, dynamic>> _sharedFiles = [];

  // Notes
  final _noteCtrl = TextEditingController();
  bool _savingNote = false;

  bool _showGiftPicker = false;

  // Block dialog
  bool _showBlockDialog = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final profile = await Supabase.instance.client.from('profiles').select('*').eq('id', widget.userId).maybeSingle();
      if (profile == null && mounted) { context.pop(); return; }

      final prefs = await SharedPreferences.getInstance();
      final blockedList = prefs.getStringList('echat_blocked_users') ?? [];
      final mutedList = prefs.getStringList('echat_muted_chats') ?? [];
      final note = prefs.getString('contact_note_${widget.userId}') ?? '';

      // Find chat ID
      final myId = ref.read(authProvider).value?.id ?? '';
      final chat = await Supabase.instance.client.from('chats').select('id')
          .or('and(user1_id.eq.$myId,user2_id.eq.${widget.userId}),and(user1_id.eq.${widget.userId},user2_id.eq.$myId)')
          .maybeSingle();

      setState(() {
        _profile = profile;
        _isBlocked = blockedList.contains(widget.userId);
        _isMuted = chat != null && mutedList.contains(chat['id'] as String);
        _chatId = chat?['id'] as String?;
        _noteCtrl.text = note;
        _loading = false;
      });

      if (chat != null) {
        _loadSharedMedia(chat['id'] as String);
        _loadSharedFiles(chat['id'] as String);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadSharedMedia(String cId) async {
    final data = await Supabase.instance.client.from('messages').select('id, media_url, message_type, created_at').eq('chat_id', cId).inFilter('message_type', ['image', 'video']).not('media_url', 'is', null).order('created_at', ascending: false).limit(30);
    setState(() => _sharedMedia = List<Map<String, dynamic>>.from(data ?? []));
  }

  Future<void> _loadSharedFiles(String cId) async {
    final data = await Supabase.instance.client.from('messages').select('id, file_name, media_url, created_at').eq('chat_id', cId).eq('message_type', 'file').not('media_url', 'is', null).order('created_at', ascending: false).limit(30);
    setState(() => _sharedFiles = List<Map<String, dynamic>>.from(data ?? []));
  }

  Future<void> _toggleMute() async {
    if (_chatId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final mutedList = List<String>.from(prefs.getStringList('echat_muted_chats') ?? []);
    if (_isMuted) { mutedList.remove(_chatId); setState(() => _isMuted = false); _snack('Chat unmuted'); }
    else { mutedList.add(_chatId!); setState(() => _isMuted = true); _snack('Chat muted'); }
    await prefs.setStringList('echat_muted_chats', mutedList);
  }

  Future<void> _blockUser() async {
    final prefs = await SharedPreferences.getInstance();
    final blockedList = List<String>.from(prefs.getStringList('echat_blocked_users') ?? []);
    blockedList.add(widget.userId);
    await prefs.setStringList('echat_blocked_users', blockedList);
    setState(() { _isBlocked = true; _showBlockDialog = false; });
    _snack('${_displayName} blocked');
  }

  Future<void> _unblockUser() async {
    final prefs = await SharedPreferences.getInstance();
    final blockedList = List<String>.from(prefs.getStringList('echat_blocked_users') ?? []);
    blockedList.remove(widget.userId);
    await prefs.setStringList('echat_blocked_users', blockedList);
    setState(() => _isBlocked = false);
    _snack('${_displayName} unblocked');
  }

  Future<void> _handleMessage() async {
    if (_chatId != null) { context.go('/chat/$_chatId'); return; }
    context.go('/new-message');
  }

  Future<void> _saveNote() async {
    setState(() => _savingNote = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('contact_note_${widget.userId}', _noteCtrl.text);
    setState(() => _savingNote = false);
    _snack('Note saved');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _kP));
  }

  String get _displayName => (_profile?['name'] ?? _profile?['username'] ?? 'User') as String;
  bool get _isOnline => _profile?['is_online'] == true;

  String _formatLastSeen() {
    if (_isOnline) return 'online';
    final ls = _profile?['last_seen'] as String?;
    if (ls == null) return 'offline';
    final dt = DateTime.tryParse(ls);
    if (dt == null) return 'offline';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 5) return 'last seen just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'last seen ${diff.inHours}h ago';
    return 'last seen ${DateFormat('MMM d').format(dt)}';
  }

  bool get _todayIsBirthday {
    final bday = _profile?['birthday'] as String?;
    if (bday == null) return false;
    try {
      final d = DateTime.parse(bday);
      final now = DateTime.now();
      return d.month == now.month && d.day == now.day;
    } catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: _kBg, body: const Center(child: CircularProgressIndicator(color: _kP)));
    if (_profile == null) return Scaffold(backgroundColor: _kBg, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('User not found', style: TextStyle(color: Colors.white38)), const SizedBox(height: 12), TextButton(onPressed: () => context.pop(), child: const Text('Go Back'))])));

    final color = _colorFor(widget.userId);
    final bio = _profile?['bio'] as String?;
    final phone = _profile?['phone_number'] as String?;
    final username = _profile?['username'] as String? ?? '';
    final bday = _profile?['birthday'] as String?;
    String? bdayFormatted;
    if (bday != null) {
      try { bdayFormatted = DateFormat('MMMM d').format(DateTime.parse(bday)); } catch (_) {}
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Column(children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 4, 4, 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.pop()),
                const Spacer(),
                // Stars / Gift button
                GestureDetector(
                  onTap: () => setState(() => _showGiftPicker = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.star, color: Colors.amber, size: 13),
                      const SizedBox(width: 4),
                      Text('${ref.watch(starsProvider)} · Gift', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 20),
                  color: _kCard,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (v) {
                    if (v == 'share') { Clipboard.setData(ClipboardData(text: 'https://echat.chat/u/$username')); _snack('Profile link copied'); }
                    if (v == 'report') _snack('Report submitted'); 
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'share', child: Text('Share Profile', style: TextStyle(color: Colors.white70))),
                    const PopupMenuItem(value: 'report', child: Text('Report', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ]),
            ),

            Expanded(child: SingleChildScrollView(child: Column(children: [
          // Avatar + name
          Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Column(children: [
            Stack(children: [
              CircleAvatar(
                radius: 56, backgroundColor: color,
                backgroundImage: _profile?['avatar_url'] != null ? NetworkImage(_profile!['avatar_url'] as String) : null,
                child: _profile?['avatar_url'] == null ? Text(_displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)) : null,
              ),
              if (_todayIsBirthday) const Positioned(top: 0, right: 0, child: Text('🎂', style: TextStyle(fontSize: 24))),
              if (_isOnline) Positioned(bottom: 2, right: 2, child: Container(width: 18, height: 18, decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: _kBg, width: 2.5)))),
            ]),
            const SizedBox(height: 12),
            Text(_displayName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_formatLastSeen(), style: const TextStyle(color: Colors.white38, fontSize: 13)),
            if (_todayIsBirthday) ...[
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(LucideIcons.cake, color: Colors.pinkAccent, size: 14), const SizedBox(width: 6), Text('🎉 Today is $_displayName\'s birthday!', style: const TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.w600))])),
            ],
          ])),

          // Action buttons
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 12, children: [
            _actionBtn(LucideIcons.messageSquare, 'Message', () => _handleMessage()),
            _actionBtn(_isMuted ? LucideIcons.bell : LucideIcons.bellOff, _isMuted ? 'Unmute' : 'Mute', _toggleMute),
            _actionBtn(LucideIcons.phone, 'Call', () => _snack('Calling $_displayName…')),
            _actionBtn(LucideIcons.video, 'Video', () => _snack('Video calling $_displayName…')),
            _actionBtn(LucideIcons.userX, _isBlocked ? 'Unblock' : 'Block', () => _isBlocked ? _unblockUser() : setState(() => _showBlockDialog = true), isDestructive: true),
          ])),

          // Info rows
          if (phone != null) _infoRow(phone, 'Mobile'),
          if (bio != null && bio.isNotEmpty) _infoRow(bio, 'Bio'),
          _infoRow('@$username', 'Username', trailing: const Icon(LucideIcons.qrCode, color: Colors.white38, size: 18)),
          if (bdayFormatted != null) _infoRow(bdayFormatted, 'Birthday', leading: const Icon(LucideIcons.cake, color: Colors.pinkAccent, size: 16)),

          // Tabs
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06)))),
            child: TabBar(
              controller: _tabCtrl,
              onTap: (i) => setState(() => _activeTab = ['media', 'files', 'notes'][i]),
              indicatorColor: _kP,
              labelColor: _kP,
              unselectedLabelColor: Colors.white38,
              tabs: [
                const Tab(text: 'Media'),
                const Tab(text: 'Files'),
                Tab(child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(LucideIcons.stickyNote, size: 13), SizedBox(width: 4), Text('Notes')])),
              ],
            ),
          ),

          // Tab content
          SizedBox(height: 300, child: IndexedStack(index: ['media', 'files', 'notes'].indexOf(_activeTab), children: [
            // Media
            _sharedMedia.isEmpty
                ? const Center(child: Text('No shared media yet', style: TextStyle(color: Colors.white38, fontSize: 13)))
                : GridView.builder(padding: const EdgeInsets.all(1), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1), itemCount: _sharedMedia.length, itemBuilder: (_, i) {
                    final url = _sharedMedia[i]['media_url'] as String?;
                    return url != null ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.white.withOpacity(0.05))) : Container(color: Colors.white.withOpacity(0.05));
                  }),

            // Files
            _sharedFiles.isEmpty
                ? const Center(child: Text('No shared files yet', style: TextStyle(color: Colors.white38, fontSize: 13)))
                : ListView.builder(itemCount: _sharedFiles.length, itemBuilder: (_, i) {
                    final f = _sharedFiles[i];
                    return ListTile(
                      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: _kP.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.fileText, color: _kP, size: 20)),
                      title: Text(f['file_name'] as String? ?? 'File', style: const TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: Text(f['created_at'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(f['created_at'] as String)) : '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      onTap: () => _snack('Opening file…'),
                    );
                  }),

            // Notes
            Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [Icon(LucideIcons.stickyNote, color: Colors.amber, size: 14), SizedBox(width: 6), Expanded(child: Text('Private notes about this contact. Only you can see these.', style: TextStyle(color: Colors.white38, fontSize: 12)))]),
              const SizedBox(height: 12),
              Expanded(child: TextField(
                controller: _noteCtrl,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add a private note about $_displayName…', hintStyle: const TextStyle(color: Colors.white24),
                  filled: true, fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _kP)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              )),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _kP, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _savingNote ? null : _saveNote,
                child: _savingNote ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Note', style: TextStyle(color: Colors.white)),
              )),
            ])),
          ])),

          const SizedBox(height: 32),
        ]))),
          ]),
          // Block dialog overlay
          if (_showBlockDialog) _buildBlockDialog(),
          if (_showGiftPicker) _buildGiftPicker(),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback fn, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: fn,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: isDestructive && !_isBlocked && label == 'Block' ? Colors.redAccent.withOpacity(0.08) : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDestructive ? Colors.redAccent.withOpacity(0.2) : Colors.white12),
          ),
          child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white54, size: 22),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white54, fontSize: 11)),
      ]),
    );
  }

  Widget _infoRow(String value, String label, {Widget? leading, Widget? trailing}) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(children: [
        if (leading != null) ...[leading, const SizedBox(width: 8)],
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ])),
        if (trailing != null) trailing,
      ]),
    ),
  );

  Widget _buildBlockDialog() => GestureDetector(
    onTap: () => setState(() => _showBlockDialog = false),
    child: Container(
      color: Colors.black.withOpacity(0.6),
      alignment: Alignment.center,
      child: GestureDetector(onTap: () {}, child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Block $_displayName?', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("They won't be able to message you.", style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _showBlockDialog = false), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: _blockUser, child: const Text('Block'))),
          ]),
        ]),
      )),
    ),
  );

  Widget _buildGiftPicker() {
    final balance = ref.watch(starsProvider);
    
    return GestureDetector(
      onTap: () => setState(() => _showGiftPicker = false),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Send a Gift 🎁', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    Row(children: [
                      const Icon(LucideIcons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('$balance', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 16, crossAxisSpacing: 12, childAspectRatio: 0.8),
                    itemCount: virtualGifts.length,
                    itemBuilder: (context, index) {
                      final gift = virtualGifts[index];
                      final canAfford = balance >= gift.stars;
                      return GestureDetector(
                        onTap: () async {
                          if (canAfford) {
                            final success = await ref.read(starsProvider.notifier).deductStars(gift.stars);
                            if (success && mounted) {
                              setState(() => _showGiftPicker = false);
                              _snack('Sent ${gift.name} to $_displayName! 🎁');
                            }
                          } else {
                            _snack('Not enough Stars!');
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: canAfford ? Colors.white10 : Colors.redAccent.withOpacity(0.1))),
                              alignment: Alignment.center,
                              child: Text(gift.emoji, style: const TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(height: 4),
                            Text('${gift.stars}', style: TextStyle(color: canAfford ? Colors.amber : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.star, color: Colors.amber, size: 16),
                  label: const Text('Buy More Stars'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.withOpacity(0.15), foregroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  onPressed: () { setState(() => _showGiftPicker = false); context.push('/buy-stars'); },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
