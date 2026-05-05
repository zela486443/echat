import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/message.dart';
import '../../widgets/chat_bubble.dart';
import '../groups/group_info_screen.dart';
import '../../widgets/groups/group_admin_panel.dart';

// ─── Color Utilities ──────────────────────────────────────────────────────
const _kSenderColors = [
  Color(0xFFe91e63), Color(0xFF9c27b0), Color(0xFF673ab7), Color(0xFF3f51b5),
  Color(0xFF2196f3), Color(0xFF00bcd4), Color(0xFF009688), Color(0xFF4caf50),
  Color(0xFFff9800), Color(0xFFff5722),
];

Color _colorFor(String uid) {
  int h = 0;
  for (final c in uid.runes) h = (c + ((h << 5) - h)) & 0xFFFFFFFF;
  return _kSenderColors[h.abs() % _kSenderColors.length];
}

const _kPrimary = Color(0xFF7C3AED);
const _kBg      = Color(0xFF0D0A1A);
const _kCard    = Color(0xFF150D28);

// ─── Topic Colors ──────────────────────────────────────────────────────────
const _kTopicColors = [
  Color(0xFF7C3AED), Color(0xFF2196F3), Color(0xFF4CAF50),
  Color(0xFFFF9800), Color(0xFFE91E63), Color(0xFF00BCD4),
];

// ─── Data Models ─────────────────────────────────────────────────────────────
class _GroupMember {
  final String userId;
  final String role; // admin, moderator, member
  final String name;
  bool isMuted;
  bool isBanned;
  _GroupMember({required this.userId, required this.role, required this.name, this.isMuted = false, this.isBanned = false});
}

class _Topic {
  final String id;
  final String title;
  final Color color;
  final List<_TopicMsg> messages;
  _Topic({required this.id, required this.title, required this.color, this.messages = const []});
}

class _TopicMsg {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;
  _TopicMsg({required this.id, required this.senderId, required this.senderName, required this.content, required this.createdAt});
}

class _Poll {
  final String id;
  final String question;
  final List<String> options;
  final Map<String, List<String>> votes; // optionIdx → [userId]
  final bool isAnonymous;
  bool closed;
  _Poll({required this.id, required this.question, required this.options, required this.votes, this.isAnonymous = false, this.closed = false});
}

// ─── GroupChat Screen ─────────────────────────────────────────────────────────
class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  const GroupChatScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  // Group data
  String _groupName = '';
  String _groupDescription = '';
  List<_GroupMember> _members = [];
  bool _userIsAdmin = false;
  bool _loading = true;

  // Messaging
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;

  // Features
  int _slowModeSeconds = 0;
  int _slowModeCooldown = 0;
  Timer? _slowTimer;
  String? _pinnedMsgId;
  String? _pinnedMsgText;

  // Topics
  List<_Topic> _topics = [];
  _Topic? _selectedTopic;

  // Polls
  List<_Poll> _polls = [];
  bool _showPollCreator = false;
  final _pollQuestionCtrl = TextEditingController();
  final List<TextEditingController> _pollOptionCtrls = [
    TextEditingController(text: 'Option 1'), TextEditingController(text: 'Option 2'),
  ];
  bool _pollAnonymous = false;

  // Reactions: messageId → emoji → [userId]
  Map<String, Map<String, List<String>>> _reactions = {};

  // Edits: messageId → new content
  Map<String, String> _edits = {};

  // UI toggles
  bool _showInfoSheet = false;
  bool _showAdminPanel = false;
  bool _showTopicCreator = false;
  String _memberSearch = '';
  final _topicTitleCtrl = TextEditingController();
  Color _newTopicColor = _kTopicColors[0];

  // Permissions (Fetched from group settings)
  bool _pSendMsgs = true;
  bool _pSendMedia = true;
  bool _pAddMembers = true;
  bool _pPinMsgs = false;
  bool _pChangeInfo = false;

  // Reply/edit
  Message? _replyingTo;
  Message? _editingMsg;

  // Invite link
  String _inviteLink = '';

  // Forward
  Message? _forwardTarget;

  // Topic message input
  final _topicMsgCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _pollQuestionCtrl.dispose();
    _topicTitleCtrl.dispose();
    _topicMsgCtrl.dispose();
    for (final c in _pollOptionCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _loadGroup() async {
    setState(() => _loading = true);
    try {
      // Load group from Supabase
      final data = await Supabase.instance.client
          .from('groups').select('*, group_members(*)').eq('id', widget.groupId).single();
      final userId = ref.read(authProvider).value?.id ?? '';
      final membersRaw = (data['group_members'] as List<dynamic>?) ?? [];
      final members = await Future.wait(membersRaw.map((m) async {
        final profile = await Supabase.instance.client.from('profiles').select('name, username').eq('id', m['user_id']).maybeSingle();
        return _GroupMember(
          userId: m['user_id'], role: m['role'] ?? 'member',
          name: profile?['name'] ?? profile?['username'] ?? 'User',
        );
      }));

      setState(() {
        _groupName = data['name'] ?? 'Group';
        _groupDescription = data['description'] ?? '';
        _members = members;
        _userIsAdmin = members.any((m) => m.userId == userId && m.role == 'admin');
        _inviteLink = 'https://echat.chat/join/${widget.groupId.substring(0, 8)}';
        _loading = false;
      });

      // Load pinned message from prefs
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _pinnedMsgId = prefs.getString('grp_pinned_id_${widget.groupId}');
        _pinnedMsgText = prefs.getString('grp_pinned_txt_${widget.groupId}');
        _slowModeSeconds = prefs.getInt('grp_slow_${widget.groupId}') ?? 0;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Failed to load group: $e');
    }
  }

  void _startSlowTimer() {
    _slowTimer?.cancel();
    setState(() => _slowModeCooldown = _slowModeSeconds);
    _slowTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_slowModeCooldown <= 0) { t.cancel(); return; }
      setState(() => _slowModeCooldown--);
    });
  }

  Future<void> _sendMessage() async {
    final content = _msgCtrl.text.trim();
    if (content.isEmpty) return;
    if (_slowModeCooldown > 0) { _showSnack('Wait ${_slowModeCooldown}s (slow mode)'); return; }

    setState(() => _sending = true);
    try {
      final userId = ref.read(authProvider).value?.id;
      await Supabase.instance.client.from('group_messages').insert({
        'group_id': widget.groupId,
        'sender_id': userId,
        'content': content,
        'reply_to_id': _replyingTo?.id,
      });
      _msgCtrl.clear();
      setState(() { _replyingTo = null; _editingMsg = null; });
      if (_slowModeSeconds > 0) _startSlowTimer();
      _scrollToBottom();
    } catch (e) { _showSnack('Failed to send: $e'); }
    finally { setState(() => _sending = false); }
  }

  Future<void> _pinMessage(Message msg) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _pinnedMsgId = msg.id; _pinnedMsgText = msg.content ?? ''; });
    await prefs.setString('grp_pinned_id_${widget.groupId}', msg.id);
    await prefs.setString('grp_pinned_txt_${widget.groupId}', msg.content ?? '');
    _showSnack('Message pinned');
  }

  Future<void> _unpinMessage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _pinnedMsgId = null; _pinnedMsgText = null; });
    await prefs.remove('grp_pinned_id_${widget.groupId}');
    await prefs.remove('grp_pinned_txt_${widget.groupId}');
  }

  void _reactToMessage(Message msg, String emoji) {
    final userId = ref.read(authProvider).value?.id ?? '';
    setState(() {
      _reactions[msg.id] ??= {};
      _reactions[msg.id]![emoji] ??= [];
      if (_reactions[msg.id]![emoji]!.contains(userId)) {
        _reactions[msg.id]![emoji]!.remove(userId);
      } else {
        _reactions[msg.id]![emoji]!.add(userId);
      }
    });
  }

  void _createPoll() {
    final q = _pollQuestionCtrl.text.trim();
    final opts = _pollOptionCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (q.isEmpty || opts.length < 2) { _showSnack('Add question and at least 2 options'); return; }
    setState(() {
      _polls.add(_Poll(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: q, options: opts,
        votes: {for (final o in opts) o: []},
        isAnonymous: _pollAnonymous,
      ));
      _showPollCreator = false;
      _pollQuestionCtrl.clear();
    });
    _showSnack('Poll created');
  }

  void _votePoll(String pollId, String option) {
    final userId = ref.read(authProvider).value?.id ?? '';
    setState(() {
      final poll = _polls.firstWhere((p) => p.id == pollId);
      if (poll.closed) return;
      // Remove previous vote
      for (final k in poll.votes.keys) poll.votes[k]!.remove(userId);
      poll.votes[option] ??= [];
      poll.votes[option]!.add(userId);
    });
  }

  void _createTopic() {
    final title = _topicTitleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() {
      _topics.add(_Topic(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title, color: _newTopicColor,
      ));
      _showTopicCreator = false;
      _topicTitleCtrl.clear();
    });
    _showSnack('Topic created');
  }

  void _sendTopicMessage() {
    if (_selectedTopic == null || _topicMsgCtrl.text.trim().isEmpty) return;
    final userId = ref.read(authProvider).value?.id ?? '';
    final senderName = _getMemberName(userId);
    setState(() {
      final idx = _topics.indexWhere((t) => t.id == _selectedTopic!.id);
      if (idx < 0) return;
      final msg = _TopicMsg(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: userId, senderName: senderName,
        content: _topicMsgCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      _topics[idx] = _Topic(id: _topics[idx].id, title: _topics[idx].title, color: _topics[idx].color, messages: [..._topics[idx].messages, msg]);
      _selectedTopic = _topics[idx];
      _topicMsgCtrl.clear();
    });
  }

  String _getMemberName(String uid) {
    try { return _members.firstWhere((m) => m.userId == uid).name; } catch (_) { return 'User'; }
  }

  void _setSlowMode(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _slowModeSeconds = seconds);
    await prefs.setInt('grp_slow_${widget.groupId}', seconds);
    _showSnack(seconds == 0 ? 'Slow mode off' : 'Slow mode: ${_slowLabel(seconds)}');
  }

  String _slowLabel(int s) {
    if (s == 0) return 'Off';
    if (s < 60) return '${s}s';
    if (s < 3600) return '${s ~/ 60}m';
    return '${s ~/ 3600}h';
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _kPrimary));
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();

    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.groupId));
    final userId = ref.watch(authProvider).value?.id ?? '';

    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(userId),
              if (_slowModeSeconds > 0) _buildSlowModeBanner(),
              if (_pinnedMsgText != null) _buildPinnedBanner(),
              _buildTopicsBar(),
              Expanded(
                child: _selectedTopic != null
                    ? _buildTopicMessages(userId)
                    : _buildMainMessages(messagesAsync, userId),
              ),
              if (_replyingTo != null) _buildReplyPreview(),
              if (_editingMsg != null) _buildEditPreview(),
              _buildInputArea(userId),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
              _buildInputArea(userId),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
          // Poll Creator Overlay
          if (_showPollCreator) _buildPollCreatorOverlay(),
          // Topic Creator
          if (_showTopicCreator) _buildTopicCreatorOverlay(),
          // Forward Dialog
          if (_forwardTarget != null) _buildForwardOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoading() => Scaffold(
    backgroundColor: _kBg,
    body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: _kPrimary.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: _kPrimary.withOpacity(0.3))),
            child: const Icon(LucideIcons.loader, color: _kPrimary, size: 28)),
        const SizedBox(height: 16),
        const Text('Loading group…', style: TextStyle(color: Colors.white38, fontSize: 13)),
      ]),
    ),
  );

  Widget _buildHeader(String userId) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 4, 4, 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.go('/chats')),
          GestureDetector(
            onTap: _showGroupInfo,
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: _colorFor(_groupName), child: Text(_groupName.isEmpty ? 'G' : _groupName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_groupName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('${_members.length} member${_members.length == 1 ? '' : 's'}${_slowModeSeconds > 0 ? ' · slow mode' : ''}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(icon: const Icon(LucideIcons.phone, color: Colors.white70, size: 20), onPressed: () => context.push('/group-call/${widget.groupId}')),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical, color: Colors.white),
            color: _kCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (v) => _onHeaderMenu(v, userId),
            itemBuilder: (_) => [
              _mItem('info', LucideIcons.users, 'Group Info'),
              if (_userIsAdmin) _mItem('add_members', LucideIcons.userPlus, 'Add Members'),
              if (_userIsAdmin) _mItem('admin', LucideIcons.shield, 'Admin Panel'),
              _mItem('poll', LucideIcons.barChart2, 'Create Poll'),
              _mItem('invite', LucideIcons.link2, 'Copy Invite Link'),
              const PopupMenuDivider(),
              _mItem('voice', LucideIcons.mic2, 'Voice Channel'),
              const PopupMenuDivider(),
              _mItem('leave', LucideIcons.logOut, 'Leave Group', isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _mItem(String v, IconData icon, String label, {bool isDestructive = false}) =>
    PopupMenuItem<String>(value: v, child: Row(children: [
      Icon(icon, size: 16, color: isDestructive ? Colors.redAccent : Colors.white60),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white70, fontSize: 13)),
    ]));

  void _onHeaderMenu(String v, String userId) {
    switch (v) {
      case 'info': _showGroupInfo(); break;
      case 'add_members': context.push('/group/${widget.groupId}/add-members'); break;
      case 'admin': _showAdminPanelSheet(); break;
      case 'poll': setState(() => _showPollCreator = true); break;
      case 'invite': Clipboard.setData(ClipboardData(text: _inviteLink)); _showSnack('Invite link copied!'); break;
      case 'voice': _showSnack('Voice channel starting...'); break;
      case 'leave': _leaveGroup(userId); break;
    }
  }

  Future<void> _leaveGroup(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kCard,
        title: const Text('Leave Group', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to leave?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    ) ?? false;
    if (!confirmed) return;
    try {
      await Supabase.instance.client.from('group_members').delete().match({'group_id': widget.groupId, 'user_id': userId});
      if (mounted) context.go('/chats');
    } catch (e) { _showSnack('Failed to leave: $e'); }
  }

  Widget _buildSlowModeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      color: Colors.amber.withOpacity(0.1),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(LucideIcons.timer, color: Colors.amber, size: 13),
        const SizedBox(width: 6),
        Text(
          'Slow mode · ${_slowLabel(_slowModeSeconds)}${_slowModeCooldown > 0 ? '  ${_slowModeCooldown}s remaining' : ''}',
          style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }

  Widget _buildPinnedBanner() {
    return GestureDetector(
      onTap: () {
        // Find the index of the pinned message and scroll to it
        if (_pinnedMsgId != null) {
          _scrollToMessage(_pinnedMsgId!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _kPrimary.withOpacity(0.1),
          border: Border(bottom: BorderSide(color: _kPrimary.withOpacity(0.2))),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: _kPrimary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(LucideIcons.pin, color: _kPrimary, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pinned Message', style: TextStyle(color: _kPrimary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            Text(_pinnedMsgText ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          if (_userIsAdmin)
            IconButton(
              onPressed: _unpinMessage,
              icon: const Icon(Icons.close, color: Colors.white38, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ]),
      ),
    );
  }

  void _scrollToMessage(String msgId) {
    // Logic to find the message in the list and scroll to its index
    // For now, show a toast or jump to top
    _showSnack('Jumping to message $msgId...');
  }

  void _showReactionPicker(Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF150D28),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add Reaction', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: ['👍', '❤️', '😂', '😮', '😢', '🔥', '👏', '🎉', '🚀', '💯'].map((emoji) => GestureDetector(
                onTap: () {
                  _reactToMessage(msg, emoji);
                  Navigator.pop(ctx);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsBar() {
    if (_topics.isEmpty && !_userIsAdmin) return const SizedBox.shrink();
    return Container(
      height: 44,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          // General
          GestureDetector(
            onTap: () => setState(() => _selectedTopic = null),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: _selectedTopic == null ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]) : null,
                color: _selectedTopic == null ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedTopic == null ? Colors.transparent : Colors.white12),
              ),
              alignment: Alignment.center,
              child: Text('# General', style: TextStyle(color: _selectedTopic == null ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          ..._topics.map((t) => GestureDetector(
            onTap: () => setState(() => _selectedTopic = t),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _selectedTopic?.id == t.id ? t.color : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _selectedTopic?.id == t.id ? Colors.transparent : Colors.white12),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Text('# ', style: TextStyle(color: _selectedTopic?.id == t.id ? Colors.white : t.color, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(t.title, style: TextStyle(color: _selectedTopic?.id == t.id ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Text('${t.messages.length}', style: TextStyle(color: _selectedTopic?.id == t.id ? Colors.white60 : Colors.white24, fontSize: 10)),
                ],
              ),
            ),
          )),
          if (_userIsAdmin)
            GestureDetector(
              onTap: () => setState(() => _showTopicCreator = true),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24, style: BorderStyle.solid)),
                alignment: Alignment.center,
                child: const Row(children: [Icon(Icons.add, color: Colors.white38, size: 14), SizedBox(width: 2), Text('Topic', style: TextStyle(color: Colors.white38, fontSize: 11))]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicMessages(String userId) {
    final topic = _selectedTopic!;
    if (topic.messages.isEmpty) return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.hash, color: topic.color.withOpacity(0.3), size: 48),
        const SizedBox(height: 12),
        Text('#${topic.title}', style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('No messages yet', style: TextStyle(color: Colors.white24, fontSize: 12)),
      ]),
    );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: topic.messages.length,
      itemBuilder: (_, i) {
        final m = topic.messages[i];
        final isMe = m.senderId == userId;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(backgroundColor: _colorFor(m.senderId), radius: 14, child: Text(m.senderName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11))),
                const SizedBox(width: 8),
              ],
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isMe ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]) : null,
                  color: isMe ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16).copyWith(bottomRight: isMe ? const Radius.circular(4) : null, bottomLeft: isMe ? null : const Radius.circular(4)),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe) Text(m.senderName, style: TextStyle(color: topic.color, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(m.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    Text('${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainMessages(AsyncValue<List<Message>> async, String userId) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _kPrimary)),
      error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
      data: (messages) {
        // Interleave polls chronologically
        // For simplicity, show polls at the end
        if (messages.isEmpty && _polls.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_colorFor(widget.groupId), _colorFor(widget.groupId).withOpacity(0.4)]),
                shape: BoxShape.circle),
                child: Icon(LucideIcons.users, color: Colors.white.withOpacity(0.5), size: 36)),
            const SizedBox(height: 16),
            const Text('No messages yet', style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Say hello! 👋', style: TextStyle(color: Colors.white24, fontSize: 13)),
          ]));
        }

        return ListView.builder(
          controller: _scrollCtrl,
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: messages.length + _polls.length,
          itemBuilder: (_, i) {
            if (i < _polls.length) {
              return _buildPollCard(_polls[_polls.length - 1 - i], userId);
            }
            final msg = messages[i - _polls.length];
            final isMe = msg.senderId == userId;
            final memberColor = _colorFor(msg.senderId);
            final senderName = _getMemberName(msg.senderId);
            final showAvatar = i == messages.length - 1 + _polls.length || messages[(i - _polls.length) + 1 < messages.length ? i - _polls.length + 1 : i - _polls.length].senderId != msg.senderId;
            final msgReactions = _reactions[msg.id] ?? {};

            return GestureDetector(
              onLongPress: () => _showReactionPicker(msg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMe) SizedBox(width: 36, child: showAvatar
                        ? CircleAvatar(backgroundColor: memberColor, radius: 16, child: Text(senderName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))
                        : null),
                    Flexible(child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe && showAvatar) Padding(padding: const EdgeInsets.only(left: 4, bottom: 2), child: Text(senderName, style: TextStyle(color: memberColor, fontSize: 11, fontWeight: FontWeight.bold))),
                        Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isMe ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]) : null,
                            color: isMe ? null : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16).copyWith(
                              bottomRight: isMe ? const Radius.circular(4) : null,
                              bottomLeft: isMe ? null : const Radius.circular(4),
                            ),
                            border: _pinnedMsgId == msg.id ? Border.all(color: Colors.amber.withOpacity(0.5)) : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_edits[msg.id] ?? msg.content ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                              if (_edits.containsKey(msg.id))
                                const Text('(edited)', style: TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic)),
                              Align(alignment: Alignment.bottomRight, child: Text(
                                '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              )),
                            ],
                          ),
                        ),
                        // Reactions
                        if (msgReactions.isNotEmpty) Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(spacing: 4, children: msgReactions.entries.where((e) => e.value.isNotEmpty).map((e) => GestureDetector(
                            onTap: () => _reactToMessage(msg, e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: e.value.contains(userId) ? _kPrimary.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: e.value.contains(userId) ? _kPrimary.withOpacity(0.4) : Colors.white12),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(e.key, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 3),
                                Text('${e.value.length}', style: TextStyle(color: e.value.contains(userId) ? _kPrimary : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          )).toList()),
                        ),
                      ],
                    )),
                    if (isMe) const SizedBox(width: 4),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPollCard(_Poll poll, String userId) {
    final totalVotes = poll.votes.values.fold<int>(0, (s, l) => s + l.length);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: _kPrimary.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(LucideIcons.barChart2, color: _kPrimary, size: 14)),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(poll.question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${poll.isAnonymous ? 'Anonymous' : 'Public'} poll · $totalVotes vote${totalVotes != 1 ? 's' : ''}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ])),
            if (!poll.closed) GestureDetector(
              onTap: () => setState(() => poll.closed = true),
              child: const Text('Close', style: TextStyle(color: Colors.white38, fontSize: 11, decoration: TextDecoration.underline)),
            ),
          ]),
          const SizedBox(height: 12),
          ...poll.options.map((opt) {
            final votes = poll.votes[opt]?.length ?? 0;
            final pct = totalVotes > 0 ? (votes / totalVotes) : 0.0;
            final voted = poll.votes[opt]?.contains(userId) ?? false;
            return GestureDetector(
              onTap: poll.closed ? null : () => _votePoll(poll.id, opt),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: voted ? _kPrimary.withOpacity(0.4) : Colors.white12)),
                clipBehavior: Clip.antiAlias,
                child: Stack(children: [
                  FractionallySizedBox(widthFactor: pct, child: Container(color: voted ? _kPrimary.withOpacity(0.15) : Colors.white.withOpacity(0.05))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(opt, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    Row(children: [
                      if (voted) Container(width: 16, height: 16, decoration: BoxDecoration(color: _kPrimary, shape: BoxShape.circle), child: const Center(child: Text('✓', style: TextStyle(color: Colors.white, fontSize: 9)))),
                      const SizedBox(width: 4),
                      Text('${(pct * 100).round()}%', style: TextStyle(color: voted ? _kPrimary : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ])),
                ]),
              ),
            );
          }),
          if (poll.closed) const Center(child: Text('Poll closed', style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _showContextMenu(Message msg, bool isMe, String userId) {
    const reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '🎉'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            // Emoji reaction row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: reactions.map((e) => GestureDetector(
                onTap: () { Navigator.pop(context); _reactToMessage(msg, e); },
                child: Text(e, style: const TextStyle(fontSize: 24)),
              )).toList(),
            ),
            const SizedBox(height: 8),
            // Message preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: _kPrimary, width: 3))),
              child: Text((msg.content ?? '').length > 80 ? '${(msg.content ?? '').substring(0, 80)}...' : (msg.content ?? ''), style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ),
            // Action grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              mainAxisSpacing: 8,
              children: [
                _ctxBtn(Icons.reply, 'Reply', () { Navigator.pop(context); setState(() => _replyingTo = msg); }),
                _ctxBtn(Icons.copy, 'Copy', () { Navigator.pop(context); Clipboard.setData(ClipboardData(text: msg.content ?? '')); _showSnack('Copied'); }),
                _ctxBtn(Icons.forward, 'Forward', () { Navigator.pop(context); setState(() => _forwardTarget = msg); }),
                _ctxBtn(Icons.bookmark_border, 'Save', () { Navigator.pop(context); _showSnack('Saved to bookmarks'); }),
                if (isMe) _ctxBtn(Icons.edit, 'Edit', () { Navigator.pop(context); setState(() { _editingMsg = msg; _msgCtrl.text = msg.content ?? ''; }); }),
                _ctxBtn(Icons.push_pin, _pinnedMsgId == msg.id ? 'Unpin' : 'Pin', () { Navigator.pop(context); if (_pinnedMsgId == msg.id) _unpinMessage(); else _pinMessage(msg); }),
                if (isMe || _userIsAdmin) _ctxBtn(Icons.delete, 'Delete', () async {
                  Navigator.pop(context);
                  await Supabase.instance.client.from('group_messages').delete().eq('id', msg.id);
                  _showSnack('Deleted');
                }, isDestructive: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctxBtn(IconData icon, String label, VoidCallback fn, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: fn,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: isDestructive ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.07),
            shape: BoxShape.circle,
            border: Border.all(color: isDestructive ? Colors.redAccent.withOpacity(0.25) : Colors.white12),
          ),
          child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white60, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white54, fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildReplyPreview() => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06)), left: BorderSide(color: _kPrimary, width: 3)),
    ),
    child: Row(children: [
      const Icon(Icons.reply, color: _kPrimary, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Replying', style: TextStyle(color: _kPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
        Text(_replyingTo?.content ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ])),
      GestureDetector(onTap: () => setState(() => _replyingTo = null), child: const Icon(Icons.close, color: Colors.white24, size: 16)),
    ]),
  );

  Widget _buildEditPreview() => Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
    decoration: BoxDecoration(
      color: Colors.amber.withOpacity(0.07),
      border: Border(top: BorderSide(color: Colors.amber.withOpacity(0.2)), left: const BorderSide(color: Colors.amber, width: 3)),
    ),
    child: Row(children: [
      const Icon(Icons.edit, color: Colors.amber, size: 14),
      const SizedBox(width: 8),
      Expanded(child: Text(_editingMsg?.content ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 11))),
      GestureDetector(onTap: () => setState(() { _editingMsg = null; _msgCtrl.clear(); }), child: const Icon(Icons.close, color: Colors.white24, size: 16)),
    ]),
  );

  Widget _buildInputArea(String userId) {
    final isEditing = _editingMsg != null;
    final inTopic = _selectedTopic != null;
    final canSend = _userIsAdmin || _pSendMsgs;
    final canSendMedia = _userIsAdmin || _pSendMedia;

    if (!canSend && !isEditing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0A1A),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
        ),
        child: Center(
          child: Text(
            'Only admins can send messages here',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0A1A).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isEditing && canSendMedia)
            IconButton(
              icon: const Icon(LucideIcons.barChart2, size: 22, color: Colors.white38),
              onPressed: () => setState(() => _showPollCreator = true),
            ),
          if (!isEditing && !canSendMedia)
            const SizedBox(width: 12),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: inTopic ? _topicMsgCtrl : _msgCtrl,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: inTopic ? '# ${_selectedTopic!.title}…' : (isEditing ? 'Edit message…' : 'Message…'),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                  border: InputBorder.none,
                  suffixIcon: const Icon(LucideIcons.smile, color: Colors.white24, size: 18),
                ),
                onSubmitted: (_) => inTopic ? _sendTopicMessage() : (isEditing ? _saveEdit() : _sendMessage()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: inTopic ? _sendTopicMessage : (isEditing ? _saveEdit : _sendMessage),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.4), blurRadius: 12)],
              ),
              child: _sending
                  ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                  : Icon(isEditing ? Icons.check : Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEdit() async {
    if (_editingMsg == null || _msgCtrl.text.trim().isEmpty) return;
    final newContent = _msgCtrl.text.trim();
    setState(() { _edits[_editingMsg!.id] = newContent; _editingMsg = null; _msgCtrl.clear(); });
    _showSnack('Message edited');
  }

  void _showAdminPanelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupAdminPanel(
        groupId: widget.groupId,
        currentSlowMode: _slowModeSeconds,
        members: _members,
        onSlowModeChanged: _setSlowMode,
      ),
    );
  }

  void _showGroupInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupInfoScreen(
          groupId: widget.groupId,
          groupName: _groupName,
          groupDescription: _groupDescription,
          members: _members,
          isAdmin: _userIsAdmin,
        ),
      ),
    );
  }

  // ─── Poll Creator Overlay ─────────────────────────────────────────────────────
  Widget _buildPollCreatorOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showPollCreator = false),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(LucideIcons.barChart2, color: _kPrimary, size: 18), SizedBox(width: 8), Text('Create Poll', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                TextField(controller: _pollQuestionCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Ask something…')),
                const SizedBox(height: 12),
                ...List.generate(_pollOptionCtrls.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(child: TextField(controller: _pollOptionCtrls[i], style: const TextStyle(color: Colors.white), decoration: _inputDec('Option ${i + 1}'))),
                    if (_pollOptionCtrls.length > 2) GestureDetector(onTap: () => setState(() => _pollOptionCtrls.removeAt(i)), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.close, color: Colors.redAccent, size: 18))),
                  ]),
                )),
                if (_pollOptionCtrls.length < 6)
                  GestureDetector(
                    onTap: () => setState(() => _pollOptionCtrls.add(TextEditingController())),
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24, style: BorderStyle.solid)),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add, color: Colors.white38, size: 16), SizedBox(width: 4), Text('Add option', style: TextStyle(color: Colors.white38, fontSize: 13))]),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Anonymous voting', style: TextStyle(color: Colors.white, fontSize: 13)),
                  Switch(value: _pollAnonymous, onChanged: (v) => setState(() => _pollAnonymous = v), activeColor: _kPrimary),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => setState(() => _showPollCreator = false), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _kPrimary), onPressed: _createPoll, child: const Text('Create Poll'))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Topic Creator Overlay ────────────────────────────────────────────────────
  Widget _buildTopicCreatorOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showTopicCreator = false),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(LucideIcons.hash, color: _kPrimary, size: 18), SizedBox(width: 8), Text('Create Topic', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                TextField(controller: _topicTitleCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('e.g. Announcements')),
                const SizedBox(height: 16),
                const Text('Color', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(spacing: 12, children: _kTopicColors.map((c) => GestureDetector(
                  onTap: () => setState(() => _newTopicColor = c),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                        border: Border.all(color: _newTopicColor == c ? Colors.white : Colors.transparent, width: 2.5),
                        boxShadow: _newTopicColor == c ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 10)] : null),
                  ),
                )).toList()),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => setState(() => _showTopicCreator = false), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _kPrimary), onPressed: _createTopic, child: const Text('Create'))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Forward Overlay ──────────────────────────────────────────────────────────
  Widget _buildForwardOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _forwardTarget = null),
      child: Container(
        color: Colors.black.withOpacity(0.6),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.forward, color: _kPrimary, size: 18), SizedBox(width: 8), Text('Forward Message', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: _kPrimary, width: 3))),
                child: Text(_forwardTarget?.content ?? '', style: const TextStyle(color: Colors.white60, fontSize: 13), maxLines: 3, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.copy, size: 16), label: const Text('Copy'), onPressed: () { Clipboard.setData(ClipboardData(text: _forwardTarget?.content ?? '')); _showSnack('Copied!'); setState(() => _forwardTarget = null); })),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.bookmark, size: 16), label: const Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: _kPrimary), onPressed: () { _showSnack('Saved to Bookmarks'); setState(() => _forwardTarget = null); })),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Colors.white24),
    filled: true, fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _kPrimary)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  );
}
