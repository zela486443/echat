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

const _kBg   = Color(0xFF0D0A1A);
const _kCard = Color(0xFF150D28);
const _kP    = Color(0xFF7C3AED);

const _kReactions = ['👍', '❤️', '🔥', '🎉', '😮', '😢'];

String _formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
  return '$n';
}

Color _channelColor(String id) {
  const colors = [Color(0xFF7C3AED), Color(0xFF2196F3), Color(0xFFE91E63), Color(0xFF009688), Color(0xFFFF9800), Color(0xFF673AB7)];
  int h = 0;
  for (final c in id.runes) h = (c + ((h << 5) - h)) & 0xFFFFFFFF;
  return colors[h.abs() % colors.length];
}

// ─── Local data models ────────────────────────────────────────────────────────
class _ChannelPost {
  final String id;
  final String content;
  final String type; // text | announcement
  final DateTime createdAt;
  Map<String, List<String>> reactions; // emoji → [userId]
  int views;
  bool pinned;
  _ChannelPost({required this.id, required this.content, required this.type, required this.createdAt, Map<String, List<String>>? reactions, this.views = 0, this.pinned = false})
      : reactions = reactions ?? {};
}

class _ScheduledPost {
  final String id;
  final String content;
  final DateTime scheduledAt;
  final String type;
  _ScheduledPost({required this.id, required this.content, required this.scheduledAt, required this.type});
}

// ─── ChannelView Screen ───────────────────────────────────────────────────────
class ChannelViewScreen extends ConsumerStatefulWidget {
  final String channelId;
  const ChannelViewScreen({super.key, required this.channelId});

  @override
  ConsumerState<ChannelViewScreen> createState() => _ChannelViewScreenState();
}

class _ChannelViewScreenState extends ConsumerState<ChannelViewScreen> {
  Map<String, dynamic>? _channel;
  List<_ChannelPost> _posts = [];
  List<_ScheduledPost> _scheduled = [];
  bool _loading = true;
  bool _subscribed = false;
  bool _muted = false;
  bool _isOwner = false;
  int _subCount = 0;
  String _postType = 'text'; // text | announcement
  Color _channelClr = _kP;

  // UI
  bool _showInfo = false;
  bool _showScheduleDialog = false;
  bool _showScheduledPosts = false;
  bool _showEditDialog = false;
  _ChannelPost? _contextPost;

  final _msgCtrl = TextEditingController();
  final _editNameCtrl = TextEditingController();
  final _editDescCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Schedule
  DateTime? _scheduleDate;
  TimeOfDay? _scheduleTime;

  // Reactions picker
  String? _reactionPickerPostId;

  @override
  void initState() {
    super.initState();
    _loadChannel();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _editNameCtrl.dispose();
    _editDescCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadChannel() async {
    setState(() => _loading = true);
    try {
      final userId = ref.read(authProvider).value?.id ?? '';
      final ch = await Supabase.instance.client.from('channels').select('*').eq('id', widget.channelId).maybeSingle();
      if (ch == null) { if (mounted) context.go('/channels'); return; }

      final prefs = await SharedPreferences.getInstance();
      final subList = prefs.getStringList('channel_subs_$userId') ?? [];
      final mutedList = prefs.getStringList('channel_muted_$userId') ?? [];
      final subCount = (ch['subscriber_count'] as int?) ?? (subList.contains(widget.channelId) ? 1 : 0);

      final clr = _channelColor(widget.channelId);
      setState(() {
        _channel = ch;
        _channelClr = clr;
        _subscribed = subList.contains(widget.channelId);
        _muted = mutedList.contains(widget.channelId);
        _isOwner = ch['created_by'] == userId;
        _subCount = ch['subscriber_count'] as int? ?? 0;
        _loading = false;
      });
      _loadPosts();
      _loadScheduled();
    } catch (e) {
      setState(() => _loading = false);
      _snack('Failed to load: $e');
    }
  }

  Future<void> _loadPosts() async {
    try {
      final data = await Supabase.instance.client
          .from('channel_messages')
          .select('*')
          .eq('channel_id', widget.channelId)
          .order('created_at');
      setState(() {
        _posts = (data as List).map((d) => _ChannelPost(
          id: d['id'] as String,
          content: d['content'] as String? ?? '',
          type: d['message_type'] as String? ?? 'text',
          createdAt: DateTime.tryParse(d['created_at'] as String? ?? '') ?? DateTime.now(),
          views: d['views'] as int? ?? 0,
          pinned: d['is_pinned'] == true,
        )).toList();
      });
      _scrollToBottom();
    } catch (_) {}
  }

  Future<void> _loadScheduled() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('scheduled_${widget.channelId}') ?? [];
    setState(() {
      _scheduled = raw.map((s) {
        final parts = s.split('|');
        if (parts.length < 4) return null;
        return _ScheduledPost(
          id: parts[0], content: parts[1],
          scheduledAt: DateTime.tryParse(parts[2]) ?? DateTime.now(),
          type: parts[3],
        );
      }).whereType<_ScheduledPost>().toList();
    });
  }

  Future<void> _saveScheduled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('scheduled_${widget.channelId}', _scheduled.map((s) => '${s.id}|${s.content}|${s.scheduledAt.toIso8601String()}|${s.type}').toList());
  }

  Future<void> _sendPost({DateTime? scheduleAt}) async {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty) return;
    final userId = ref.read(authProvider).value?.id ?? '';

    if (scheduleAt != null) {
      final post = _ScheduledPost(id: DateTime.now().millisecondsSinceEpoch.toString(), content: content, scheduledAt: scheduleAt, type: _postType);
      setState(() { _scheduled.add(post); _msgCtrl.clear(); _showScheduleDialog = false; });
      await _saveScheduled();
      _snack('Post scheduled for ${DateFormat("MMM d 'at' h:mm a").format(scheduleAt)}');
      return;
    }

    try {
      await Supabase.instance.client.from('channel_messages').insert({
        'channel_id': widget.channelId, 'sender_id': userId,
        'content': content, 'message_type': _postType,
      });
      _msgCtrl.clear();
      await _loadPosts();
    } catch (e) { _snack('Failed to post: $e'); }
  }

  Future<void> _toggleSubscribe() async {
    final userId = ref.read(authProvider).value?.id ?? '';
    final prefs = await SharedPreferences.getInstance();
    final subList = List<String>.from(prefs.getStringList('channel_subs_$userId') ?? []);
    if (_subscribed) {
      subList.remove(widget.channelId);
      setState(() { _subscribed = false; _subCount = (_subCount - 1).clamp(0, 999999); });
      _snack('Unsubscribed');
    } else {
      subList.add(widget.channelId);
      setState(() { _subscribed = true; _subCount++; });
      _snack('Subscribed to ${_channel?['name'] ?? 'channel'}');
    }
    await prefs.setStringList('channel_subs_$userId', subList);
  }

  Future<void> _toggleMute() async {
    final userId = ref.read(authProvider).value?.id ?? '';
    final prefs = await SharedPreferences.getInstance();
    final mutedList = List<String>.from(prefs.getStringList('channel_muted_$userId') ?? []);
    if (_muted) { mutedList.remove(widget.channelId); setState(() => _muted = false); }
    else { mutedList.add(widget.channelId); setState(() => _muted = true); }
    await prefs.setStringList('channel_muted_$userId', mutedList);
  }

  void _pinPost(_ChannelPost post) {
    setState(() {
      final wasPin = post.pinned;
      for (final p in _posts) p.pinned = false;
      post.pinned = !wasPin;
    });
    _snack(post.pinned ? 'Post pinned' : 'Post unpinned');
  }

  void _deletePost(_ChannelPost post) async {
    try {
      await Supabase.instance.client.from('channel_messages').delete().eq('id', post.id);
      setState(() => _posts.removeWhere((p) => p.id == post.id));
    } catch (_) { setState(() => _posts.removeWhere((p) => p.id == post.id)); }
    _snack('Post deleted');
  }

  void _reactToPost(_ChannelPost post, String emoji) {
    final userId = ref.read(authProvider).value?.id ?? '';
    setState(() {
      post.reactions[emoji] ??= [];
      if (post.reactions[emoji]!.contains(userId)) post.reactions[emoji]!.remove(userId);
      else post.reactions[emoji]!.add(userId);
      _reactionPickerPostId = null;
    });
  }

  void _saveEditChannel() async {
    final name = _editNameCtrl.text.trim();
    if (name.isEmpty) { _snack('Name required'); return; }
    try {
      await Supabase.instance.client.from('channels').update({'name': name, 'description': _editDescCtrl.text.trim()}).eq('id', widget.channelId);
      setState(() { _channel!['name'] = name; _channel!['description'] = _editDescCtrl.text.trim(); _showEditDialog = false; });
      _snack('Channel updated');
    } catch (e) { _snack('Failed: $e'); }
  }

  void _deleteChannel() async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: _kCard,
      title: const Text('Delete Channel', style: TextStyle(color: Colors.white)),
      content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white70)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent)))],
    )) ?? false;
    if (!confirmed) return;
    await Supabase.instance.client.from('channels').delete().eq('id', widget.channelId);
    if (mounted) context.go('/channels');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _kP));
  }

  _ChannelPost? get _pinnedPost => _posts.where((p) => p.pinned).firstOrNull;

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(backgroundColor: _kBg, body: const Center(child: CircularProgressIndicator(color: _kP)));

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(children: [
        Column(children: [
          _buildHeader(),
          if (_pinnedPost != null) _buildPinnedBanner(_pinnedPost!),
          if (_isOwner && _scheduled.isNotEmpty) _buildScheduledBanner(),
          Expanded(child: _buildMessages()),
          if (!_isOwner) _buildSubscribeButton(),
          if (_isOwner) _buildOwnerInput(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ]),
        if (_showInfo) _buildInfoOverlay(),
        if (_contextPost != null) _buildContextMenu(_contextPost!),
        if (_showScheduleDialog) _buildScheduleDialog(),
        if (_showScheduledPosts) _buildScheduledPostsDialog(),
        if (_showEditDialog) _buildEditChannelDialog(),
        if (_reactionPickerPostId != null) _buildReactionOverlay(),
      ]),
    );
  }

  Widget _buildHeader() {
    final name = _channel?['name'] as String? ?? 'Channel';
    return Container(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 4, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_channelClr.withOpacity(0.8), _channelClr.withOpacity(0.3), Colors.transparent], end: Alignment.bottomCenter),
      ),
      child: Column(
        children: [
          Row(children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.go('/channels')),
            GestureDetector(
              onTap: () => setState(() => _showInfo = true),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: _channelClr, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)))),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Row(children: [
                    const Icon(LucideIcons.users, color: Colors.white60, size: 11),
                    const SizedBox(width: 4),
                    Text('${_formatCount(_subCount)} subscriber${_subCount != 1 ? 's' : ''}${_channel?['is_public'] == true ? ' · Public' : ''}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ]),
                ]),
              ]),
            ),
            const Spacer(),
            IconButton(icon: Icon(_muted ? LucideIcons.bellOff : LucideIcons.bell, color: Colors.white, size: 20), onPressed: _toggleMute),
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical, color: Colors.white),
              color: _kCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: _handleMenu,
              itemBuilder: (_) => [
                _mi('info', LucideIcons.info, 'Channel Info'),
                if (!_isOwner) _mi('subscribe', LucideIcons.megaphone, _subscribed ? 'Unsubscribe' : 'Subscribe'),
                _mi('share', LucideIcons.share2, 'Share Channel'),
                if (_isOwner && _scheduled.isNotEmpty) _mi('scheduled', LucideIcons.clock, 'Scheduled Posts (${_scheduled.length})'),
                if (_isOwner) ...[
                  const PopupMenuDivider(),
                  _mi('edit', LucideIcons.pencil, 'Edit Channel'),
                  _mi('delete', LucideIcons.trash2, 'Delete Channel', destructive: true),
                ],
              ],
            ),
          ]),
        ],
      ),
    );
  }

  PopupMenuItem<String> _mi(String v, IconData icon, String label, {bool destructive = false}) =>
      PopupMenuItem<String>(value: v, child: Row(children: [Icon(icon, size: 15, color: destructive ? Colors.redAccent : Colors.white54), const SizedBox(width: 10), Text(label, style: TextStyle(color: destructive ? Colors.redAccent : Colors.white70, fontSize: 13))]));

  void _handleMenu(String v) {
    switch (v) {
      case 'info':       setState(() => _showInfo = true); break;
      case 'subscribe':  _toggleSubscribe(); break;
      case 'share':      Clipboard.setData(ClipboardData(text: 'https://echat.chat/channel/${widget.channelId}')); _snack('Link copied!'); break;
      case 'scheduled':  setState(() => _showScheduledPosts = true); break;
      case 'edit':       _editNameCtrl.text = _channel?['name'] ?? ''; _editDescCtrl.text = _channel?['description'] ?? ''; setState(() => _showEditDialog = true); break;
      case 'delete':     _deleteChannel(); break;
    }
  }

  Widget _buildPinnedBanner(_ChannelPost post) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(color: _kP.withOpacity(0.07), border: Border(bottom: BorderSide(color: _kP.withOpacity(0.15)))),
    child: Row(children: [
      Icon(LucideIcons.pin, color: _kP, size: 13),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Pinned Post', style: TextStyle(color: _kP, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(post.content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ])),
      if (_isOwner) GestureDetector(onTap: () => _pinPost(post), child: const Icon(LucideIcons.pinOff, color: Colors.white38, size: 14)),
    ]),
  );

  Widget _buildScheduledBanner() => GestureDetector(
    onTap: () => setState(() => _showScheduledPosts = true),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.08), border: Border(bottom: BorderSide(color: Colors.amber.withOpacity(0.2)))),
      child: Row(children: [
        const Icon(LucideIcons.clock, color: Colors.amber, size: 13),
        const SizedBox(width: 8),
        Expanded(child: Text('${_scheduled.length} scheduled post${_scheduled.length != 1 ? 's' : ''}', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600))),
        const Icon(Icons.chevron_right, color: Colors.amber, size: 16),
      ]),
    ),
  );

  Widget _buildMessages() {
    if (_posts.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 80, height: 80, decoration: BoxDecoration(color: _channelClr.withOpacity(0.12), borderRadius: BorderRadius.circular(24)), child: Icon(LucideIcons.megaphone, color: _channelClr, size: 36)),
      const SizedBox(height: 16),
      const Text('No posts yet', style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w600)),
      if (_isOwner) const Text('Broadcast your first message', style: TextStyle(color: Colors.white24, fontSize: 13)),
    ]));

    final userId = ref.read(authProvider).value?.id ?? '';
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      itemCount: _posts.length,
      itemBuilder: (_, i) => _buildPostCard(_posts[i], userId),
    );
  }

  Widget _buildPostCard(_ChannelPost post, String userId) {
    final name = _channel?['name'] as String? ?? 'Channel';
    final dateStr = DateFormat("MMM d · h:mm a").format(post.createdAt);
    final reactions = post.reactions.entries.where((e) => e.value.isNotEmpty).toList();

    return GestureDetector(
      onLongPress: () => setState(() => _contextPost = post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.07))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: _channelClr, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  if (post.type == 'announcement') Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: _kP.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: const Text('📢', style: TextStyle(fontSize: 10))),
                ]),
                Text(dateStr, style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ])),
              GestureDetector(onTap: () => setState(() => _contextPost = post), child: const Icon(LucideIcons.moreVertical, color: Colors.white38, size: 18)),
            ]),
          ),
          // Body
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text(post.content, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5))),
          // Reactions
          if (reactions.isNotEmpty) Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(spacing: 6, children: [
              ...reactions.map((e) => GestureDetector(
                onTap: () => _reactToPost(post, e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: e.value.contains(userId) ? _kP.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: e.value.contains(userId) ? _kP.withOpacity(0.4) : Colors.white12),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(e.key, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text('${e.value.length}', style: TextStyle(color: e.value.contains(userId) ? _kP : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
                ),
              )),
              GestureDetector(
                onTap: () => setState(() => _reactionPickerPostId = _reactionPickerPostId == post.id ? null : post.id),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
                  child: const Center(child: Text('+', style: TextStyle(color: Colors.white38, fontSize: 15))),
                ),
              ),
            ]),
          ),
          // Meta bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              const Icon(LucideIcons.eye, size: 12, color: Colors.white24),
              const SizedBox(width: 4),
              Text(_formatCount(post.views), style: const TextStyle(color: Colors.white24, fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(LucideIcons.messageCircle, size: 12, color: Colors.white24),
              const SizedBox(width: 4),
              const Text('0', style: TextStyle(color: Colors.white24, fontSize: 11)),
              const Spacer(),
              GestureDetector(
                onTap: () { Clipboard.setData(ClipboardData(text: post.content)); _snack('Copied'); },
                child: Row(children: const [Icon(Icons.forward, color: Colors.white24, size: 14), SizedBox(width: 4), Text('Forward', style: TextStyle(color: Colors.white24, fontSize: 11))]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildSubscribeButton() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
    child: GestureDetector(
      onTap: _toggleSubscribe,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: _subscribed ? null : const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
          color: _subscribed ? Colors.white.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(20),
          border: _subscribed ? Border.all(color: Colors.white12) : null,
        ),
        child: Center(child: Text(_subscribed ? '✓ Subscribed' : 'Subscribe to Channel', style: TextStyle(color: _subscribed ? Colors.white54 : Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
      ),
    ),
  );

  Widget _buildOwnerInput() => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06)))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Post type toggle
      Row(children: [
        for (final t in ['text', 'announcement']) GestureDetector(
          onTap: () => setState(() => _postType = t),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: _postType == t ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]) : null,
              color: _postType == t ? null : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _postType == t ? Colors.transparent : Colors.white12),
            ),
            child: Text(t == 'text' ? '📝 Post' : '📢 Announcement', style: TextStyle(color: _postType == t ? Colors.white : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
      const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
          child: TextField(
            controller: _msgCtrl,
            maxLines: null,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(hintText: 'Write a message to your subscribers…', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
          ),
        )),
        const SizedBox(width: 8),
        Column(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: () { if (_msgCtrl.text.trim().isNotEmpty) setState(() => _showScheduleDialog = true); },
            child: Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)), child: const Icon(LucideIcons.clock, color: Colors.white38, size: 16)),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _sendPost(),
            child: Container(width: 38, height: 38, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.send, color: Colors.white, size: 18)),
          ),
        ]),
      ]),
    ]),
  );

  // ─── Overlays ─────────────────────────────────────────────────────────────
  Widget _buildInfoOverlay() {
    final name = _channel?['name'] as String? ?? 'Channel';
    final desc = _channel?['description'] as String? ?? '';
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showInfo = false),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width * 0.83,
                height: double.infinity,
                color: _kBg,
                child: Column(
                  children: [
                    Container(
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_channelClr.withOpacity(0.8), _channelClr.withOpacity(0.3)]),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8, right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _showInfo = false),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52, height: 52,
                                    decoration: BoxDecoration(color: _channelClr, borderRadius: BorderRadius.circular(16)),
                                    child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24))),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                                      Text('${_formatCount(_subCount)} subscribers', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (desc.isNotEmpty) ...[
                            const Text('ABOUT', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            const SizedBox(height: 6),
                            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                            const SizedBox(height: 16),
                          ],
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                            child: Column(
                              children: [
                                _infoTile(LucideIcons.users, '${_formatCount(_subCount)} Subscribers', _channel?['is_public'] == true ? 'Public channel' : 'Private channel'),
                                const Divider(color: Colors.white12, height: 1),
                                _infoTile(LucideIcons.megaphone, '${_posts.length} Posts', 'Total published'),
                                if (_isOwner && _scheduled.isNotEmpty) ...[
                                  const Divider(color: Colors.white12, height: 1),
                                  GestureDetector(
                                    onTap: () { setState(() { _showInfo = false; _showScheduledPosts = true; }); },
                                    child: _infoTile(LucideIcons.clock, '${_scheduled.length} Scheduled', 'Upcoming posts', isAmber: true, showChevron: true),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!_isOwner) GestureDetector(
                            onTap: () { _toggleSubscribe(); setState(() => _showInfo = false); },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: _subscribed ? null : const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
                                color: _subscribed ? Colors.white.withOpacity(0.07) : null,
                                borderRadius: BorderRadius.circular(16),
                                border: _subscribed ? Border.all(color: Colors.white12) : null,
                              ),
                              child: Center(child: Text(_subscribed ? 'Unsubscribe' : 'Subscribe', style: TextStyle(color: _subscribed ? Colors.white54 : Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                            ),
                          ),
                          if (_isOwner) GestureDetector(
                            onTap: () { _editNameCtrl.text = _channel?['name'] ?? ''; _editDescCtrl.text = _channel?['description'] ?? ''; setState(() { _showInfo = false; _showEditDialog = true; }); },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.pencil, color: Colors.white60, size: 16), SizedBox(width: 8), Text('Edit Channel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14))]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Widget _infoTile(IconData icon, String title, String sub, {bool isAmber = false, bool showChevron = false}) {
    final c = isAmber ? Colors.amber : _kP;
    return Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: c, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ])),
      if (showChevron) const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
    ]));
  }

  Widget _buildContextMenu(_ChannelPost post) {
    return GestureDetector(
      onTap: () => setState(() => _contextPost = null),
      child: Container(
        color: Colors.black.withOpacity(0.55),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(onTap: () {}, child: Container(
          decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: _kP, width: 3))),
              child: Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12))),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4, childAspectRatio: 0.85, mainAxisSpacing: 8,
              children: [
                _ctxBtn(Icons.copy, 'Copy', () { Clipboard.setData(ClipboardData(text: post.content)); _snack('Copied'); setState(() => _contextPost = null); }),
                _ctxBtn(Icons.forward, 'Forward', () { Clipboard.setData(ClipboardData(text: post.content)); _snack('Copied for forwarding'); setState(() => _contextPost = null); }),
                _ctxBtn(Icons.bookmark_border, 'Save', () { _snack('Saved to bookmarks'); setState(() => _contextPost = null); }),
                if (_isOwner) _ctxBtn(post.pinned ? LucideIcons.pinOff : LucideIcons.pin, post.pinned ? 'Unpin' : 'Pin', () { _pinPost(post); setState(() => _contextPost = null); }),
                if (_isOwner) _ctxBtn(Icons.delete, 'Delete', () { _deletePost(post); setState(() => _contextPost = null); }, isDestructive: true),
              ],
            ),
          ]),
        )),
      ),
    );
  }

  Widget _ctxBtn(IconData icon, String label, VoidCallback fn, {bool isDestructive = false}) => GestureDetector(onTap: fn, child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 50, height: 50, decoration: BoxDecoration(color: isDestructive ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.07), shape: BoxShape.circle, border: Border.all(color: isDestructive ? Colors.redAccent.withOpacity(0.25) : Colors.white12)),
      child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white60, size: 20)),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white54, fontSize: 10), textAlign: TextAlign.center),
  ]));

  Widget _buildReactionOverlay() {
    final post = _posts.firstWhere((p) => p.id == _reactionPickerPostId, orElse: () => _posts.first);
    return GestureDetector(
      onTap: () => setState(() => _reactionPickerPostId = null),
      child: Container(color: Colors.black.withOpacity(0.4), alignment: Alignment.center, child: GestureDetector(onTap: () {},
        child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
          child: Wrap(spacing: 8, children: _kReactions.map((e) => GestureDetector(onTap: () => _reactToPost(post, e), child: Text(e, style: const TextStyle(fontSize: 30)))).toList())))),
    );
  }

  Widget _buildScheduleDialog() {
    return GestureDetector(
      onTap: () => setState(() => _showScheduleDialog = false),
      child: Container(color: Colors.black.withOpacity(0.55), alignment: Alignment.bottomCenter, child: GestureDetector(onTap: () {}, child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Row(children: [Icon(LucideIcons.calendar, color: _kP, size: 18), SizedBox(width: 8), Text('Schedule Post', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: _kP, width: 3))),
            child: Text(_msgCtrl.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365))); if (d != null) setState(() => _scheduleDate = d); },
              child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                child: Text(_scheduleDate != null ? DateFormat('MMM d, yyyy').format(_scheduleDate!) : 'Select Date', style: TextStyle(color: _scheduleDate != null ? Colors.white : Colors.white38, fontSize: 13))),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () async { final t = await showTimePicker(context: context, initialTime: TimeOfDay.now()); if (t != null) setState(() => _scheduleTime = t); },
              child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                child: Text(_scheduleTime != null ? _scheduleTime!.format(context) : 'Select Time', style: TextStyle(color: _scheduleTime != null ? Colors.white : Colors.white38, fontSize: 13))),
            )),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _showScheduleDialog = false), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _kP), onPressed: () {
              if (_scheduleDate == null || _scheduleTime == null) { _snack('Pick date and time'); return; }
              final dt = DateTime(_scheduleDate!.year, _scheduleDate!.month, _scheduleDate!.day, _scheduleTime!.hour, _scheduleTime!.minute);
              _sendPost(scheduleAt: dt);
            }, child: const Text('Schedule'))),
          ]),
        ]),
      ))),
    );
  }

  Widget _buildScheduledPostsDialog() {
    return GestureDetector(
      onTap: () => setState(() => _showScheduledPosts = false),
      child: Container(color: Colors.black.withOpacity(0.55), alignment: Alignment.bottomCenter, child: GestureDetector(onTap: () {}, child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Row(children: [Icon(LucideIcons.clock, color: Colors.amber, size: 18), SizedBox(width: 8), Text('Scheduled Posts', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          Flexible(child: _scheduled.isEmpty
              ? const Center(child: Text('No scheduled posts', style: TextStyle(color: Colors.white38, fontSize: 13)))
              : ListView.builder(shrinkWrap: true, itemCount: _scheduled.length, itemBuilder: (_, i) {
                  final sp = _scheduled[i];
                  return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)), child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(sp.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('📅 ${DateFormat("MMM d 'at' h:mm a").format(sp.scheduledAt)}', style: const TextStyle(color: Colors.amber, fontSize: 11)),
                    ])),
                    GestureDetector(onTap: () { setState(() { _scheduled.removeAt(i); }); _saveScheduled(); }, child: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 18)),
                  ]));
                })),
        ]),
      ))),
    );
  }

  Widget _buildEditChannelDialog() {
    return GestureDetector(
      onTap: () => setState(() => _showEditDialog = false),
      child: Container(color: Colors.black.withOpacity(0.55), alignment: Alignment.bottomCenter, child: GestureDetector(onTap: () {}, child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit Channel', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _editNameCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Channel Name *')),
          const SizedBox(height: 12),
          TextField(controller: _editDescCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Description')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _showEditDialog = false), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _kP), onPressed: _saveEditChannel, child: const Text('Save'))),
          ]),
        ]),
      ))),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Colors.white24),
    filled: true, fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kP)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  );
}
