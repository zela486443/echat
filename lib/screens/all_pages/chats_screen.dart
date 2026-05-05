import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/chat.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';

// ─── Chat Folder Model ──────────────────────────────────────────────────────
class ChatFolder {
  final String id;
  final String name;
  final String icon; // 'folder', 'star', 'briefcase', 'heart', 'hash', 'users'
  final Color color;

  const ChatFolder({required this.id, required this.name, required this.icon, required this.color});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'icon': icon, 'color': color.value};
  factory ChatFolder.fromJson(Map<String, dynamic> j) => ChatFolder(
    id: j['id'], name: j['name'], icon: j['icon'], color: Color(j['color']));
}

// ─── Chat Tag Model ─────────────────────────────────────────────────────────
class ChatTag {
  final String id;
  final String label;
  final Color color;
  ChatTag({required this.id, required this.label, required this.color});
}

// ─── Local Prefs Helpers ────────────────────────────────────────────────────
class ChatLocalStore {
  static Future<Set<String>> _getSet(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return Set<String>.from(prefs.getStringList(key) ?? []);
  }
  static Future<void> _saveSet(String key, Set<String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, data.toList());
  }

  static Future<Set<String>> getPinned() => _getSet('echat_pinned');
  static Future<void> savePinned(Set<String> d) => _saveSet('echat_pinned', d);
  static Future<Set<String>> getArchived() => _getSet('echat_archived');
  static Future<void> saveArchived(Set<String> d) => _saveSet('echat_archived', d);
  static Future<Set<String>> getMuted() => _getSet('echat_muted');
  static Future<void> saveMuted(Set<String> d) => _saveSet('echat_muted', d);

  static Future<List<ChatFolder>> getFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('echat_folders');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => ChatFolder.fromJson(e as Map<String, dynamic>)).toList();
  }
  static Future<void> saveFolders(List<ChatFolder> folders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('echat_folders', jsonEncode(folders.map((f) => f.toJson()).toList()));
  }

  static Future<Map<String, String>> getFolderAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('echat_folder_assignments');
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw));
  }
  static Future<void> saveFolderAssignments(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('echat_folder_assignments', jsonEncode(data));
  }
}

// ─── Filter type ────────────────────────────────────────────────────────────
enum ChatFilter { all, unread, groups }

// ─── Folder Icon Helper ─────────────────────────────────────────────────────
IconData _folderIconData(String icon) {
  switch (icon) {
    case 'star': return LucideIcons.star;
    case 'briefcase': return LucideIcons.briefcase;
    case 'heart': return LucideIcons.heart;
    case 'hash': return LucideIcons.hash;
    case 'users': return LucideIcons.users;
    default: return LucideIcons.folderOpen;
  }
}

// ─── Folder Color Options ───────────────────────────────────────────────────
const List<Color> _folderColors = [
  Color(0xFF4A90D9), Color(0xFF2ECC71), Color(0xFFF4A92B), Color(0xFFE74C3C),
  Color(0xFF9B59B6), Color(0xFFFF6B9D), Color(0xFF26A69A), Color(0xFFFFD32A),
];

// ─── Format timestamp ────────────────────────────────────────────────────────
String _formatTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  final diff = now.difference(dt).inDays;
  if (diff == 0) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  } else if (diff == 1) {
    return 'Yesterday';
  } else if (diff < 7) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
  return '${dt.day}/${dt.month}/${dt.year}';
}

String _formatLastSeen(DateTime lastSeen, bool isOnline) {
  if (isOnline) return 'Online';
  final diff = DateTime.now().difference(lastSeen);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

// ═══════════════════════════════════════════════════════════════════════════
//  CHATS SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});
  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  // Filter
  ChatFilter _activeFilter = ChatFilter.all;
  // Folders
  List<ChatFolder> _folders = [];
  String? _activeFolderId;
  Map<String, String> _folderAssignments = {}; // chatId -> folderId
  // Local state
  Set<String> _pinned = {};
  Set<String> _archived = {};
  Set<String> _muted = {};
  bool _showArchived = false;
  // Search overlay
  bool _searchActive = false;
  String _searchQuery = '';
  String _searchTab = 'chats'; // chats, channels, people
  List<Profile> _peopleResults = [];
  bool _searchingPeople = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  // Speed dial
  bool _speedDialOpen = false;
  // Folder dialog
  bool _folderDialogOpen = false;
  bool _folderManageDialogOpen = false;
  bool _moveToFolderDialogOpen = false;
  ChatFolder? _editingFolder;
  ChatFolder? _managingFolder;
  String? _movingChatId;
  final TextEditingController _folderNameCtrl = TextEditingController();
  String _folderIcon = 'folder';
  Color _folderColor = const Color(0xFF4A90D9);

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalData() async {
    final pinned = await ChatLocalStore.getPinned();
    final archived = await ChatLocalStore.getArchived();
    final muted = await ChatLocalStore.getMuted();
    final folders = await ChatLocalStore.getFolders();
    final assignments = await ChatLocalStore.getFolderAssignments();
    if (mounted) setState(() {
      _pinned = pinned; _archived = archived; _muted = muted;
      _folders = folders; _folderAssignments = assignments;
    });
  }

  Future<void> _togglePin(String chatId) async {
    setState(() {
      if (_pinned.contains(chatId)) _pinned.remove(chatId);
      else _pinned.add(chatId);
    });
    await ChatLocalStore.savePinned(_pinned);
  }

  Future<void> _toggleArchive(String chatId) async {
    setState(() {
      if (_archived.contains(chatId)) _archived.remove(chatId);
      else _archived.add(chatId);
    });
    await ChatLocalStore.saveArchived(_archived);
    _showSnack(_archived.contains(chatId) ? 'Chat archived' : 'Chat unarchived');
  }

  Future<void> _toggleMute(String chatId) async {
    setState(() {
      if (_muted.contains(chatId)) _muted.remove(chatId);
      else _muted.add(chatId);
    });
    await ChatLocalStore.saveMuted(_muted);
    _showSnack(_muted.contains(chatId) ? 'Chat muted' : 'Chat unmuted');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1A1030),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _onSearchChanged(String q) {
    setState(() => _searchQuery = q);
    if (_searchTab == 'people') {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () => _searchPeople(q));
    }
  }

  Future<void> _searchPeople(String q) async {
    if (q.length < 2) { setState(() => _peopleResults = []); return; }
    setState(() => _searchingPeople = true);
    try {
      final service = ref.read(supabaseServiceProvider);
      final results = await service.searchProfiles(q.startsWith('@') ? q.substring(1) : q);
      if (mounted) setState(() => _peopleResults = results);
    } finally {
      if (mounted) setState(() => _searchingPeople = false);
    }
  }

  void _openSearch() {
    setState(() { _searchActive = true; _searchTab = 'chats'; });
    Future.delayed(const Duration(milliseconds: 100), () => _searchFocus.requestFocus());
  }

  void _closeSearch() {
    setState(() { _searchActive = false; _searchQuery = ''; _searchTab = 'chats'; _peopleResults = []; });
    _searchController.clear();
    _searchFocus.unfocus();
  }

  void _openFolderDialog({ChatFolder? editing}) {
    _editingFolder = editing;
    _folderNameCtrl.text = editing?.name ?? '';
    _folderIcon = editing?.icon ?? 'folder';
    _folderColor = editing?.color ?? const Color(0xFF4A90D9);
    setState(() => _folderDialogOpen = true);
  }

  Future<void> _saveFolder() async {
    final name = _folderNameCtrl.text.trim();
    if (name.isEmpty) { _showSnack('Folder name required'); return; }
    if (_editingFolder != null) {
      final idx = _folders.indexWhere((f) => f.id == _editingFolder!.id);
      if (idx != -1) {
        _folders[idx] = ChatFolder(id: _editingFolder!.id, name: name, icon: _folderIcon, color: _folderColor);
      }
    } else {
      _folders.add(ChatFolder(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, icon: _folderIcon, color: _folderColor));
    }
    await ChatLocalStore.saveFolders(_folders);
    setState(() => _folderDialogOpen = false);
    _showSnack(_editingFolder != null ? 'Folder updated' : 'Folder created');
  }

  Future<void> _deleteFolder(String folderId) async {
    _folders.removeWhere((f) => f.id == folderId);
    _folderAssignments.removeWhere((chatId, fid) => fid == folderId);
    if (_activeFolderId == folderId) _activeFolderId = null;
    await ChatLocalStore.saveFolders(_folders);
    await ChatLocalStore.saveFolderAssignments(_folderAssignments);
    setState(() => _folderManageDialogOpen = false);
    _showSnack('Folder deleted');
  }

  Future<void> _moveChatToFolder(String chatId, String folderId) async {
    _folderAssignments[chatId] = folderId;
    await ChatLocalStore.saveFolderAssignments(_folderAssignments);
    setState(() => _moveToFolderDialogOpen = false);
    _movingChatId = null;
    _showSnack('Chat moved to folder');
  }

  Future<void> _removeChatFromFolder(String chatId) async {
    _folderAssignments.remove(chatId);
    await ChatLocalStore.saveFolderAssignments(_folderAssignments);
    setState(() => _moveToFolderDialogOpen = false);
    _movingChatId = null;
    _showSnack('Removed from folder');
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(userChatsStreamProvider);
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(
        children: [
          // Aurora glows
          Positioned(top: -100, right: -80, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(width: 350, height: 350, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.09))),
          )),
          Positioned(bottom: 200, left: -60, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF0050).withOpacity(0.05))),
          )),

          // Main content
          CustomScrollView(
            slivers: [
              _buildHeader(user, chatsAsync),
              _buildFilterChips(chatsAsync),
              _buildFolderTabs(),
              _buildStoriesBar(),
              _buildChatList(chatsAsync, user),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Speed Dial FAB
          _buildSpeedDialFAB(),

          // Search overlay
          if (_searchActive) _buildSearchOverlay(chatsAsync, user),

          // Folder dialogs
          if (_folderDialogOpen) _buildFolderDialog(),
          if (_folderManageDialogOpen && _managingFolder != null) _buildFolderManageDialog(),
          if (_moveToFolderDialogOpen) _buildMoveToFolderDialog(),
        ],
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(dynamic user, AsyncValue<List<Chat>> chatsAsync) {
    final totalUnread = chatsAsync.value?.fold<int>(0, (sum, c) {
      if (user == null) return sum;
      return sum + (c.participant1 == user.id ? c.unreadCount1 : c.unreadCount2);
    }) ?? 0;

    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D0A1A).withOpacity(0.9),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 8),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Stack(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 12, spreadRadius: 1)],
                      ),
                      child: user?.avatarUrl != null
                        ? ClipOval(child: Image.network(user!.avatarUrl!, fit: BoxFit.cover))
                        : Center(child: Text((user?.name ?? user?.username ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                    ),
                    if (totalUnread > 0)
                      Positioned(top: -2, right: -2, child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D0A1A), width: 1.5)),
                        child: Text(totalUnread > 99 ? '99+' : '$totalUnread', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                      )),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ShaderMask(
                    shaderCallback: (b) => LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]).createShader(b),
                    child: const Text('Echat', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ),
                  Text(totalUnread > 0 ? '$totalUnread unread message${totalUnread > 1 ? "s" : ""}' : 'Messages & more',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w500)),
                ])),
                GestureDetector(
                  onTap: _openSearch,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                    child: Icon(LucideIcons.search, color: Colors.white.withOpacity(0.7), size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                    child: Icon(LucideIcons.moreVertical, color: Colors.white.withOpacity(0.7), size: 18),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _openSearch,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(children: [
                    Icon(LucideIcons.search, size: 16, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(width: 8),
                    Text('Search chats…', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
      expandedHeight: 130,
    );
  }

  // ─── FILTER CHIPS ─────────────────────────────────────────────────────────
  Widget _buildFilterChips(AsyncValue<List<Chat>> chatsAsync) {
    final unreadCount = chatsAsync.value?.fold<int>(0, (sum, c) {
      final user = ref.read(authProvider).value;
      if (user == null) return sum;
      final unread = c.participant1 == user.id ? c.unreadCount1 : c.unreadCount2;
      return sum + unread;
    }) ?? 0;

    return SliverToBoxAdapter(
      child: Container(
        height: 44,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          children: [
            _filterChip('All', ChatFilter.all),
            const SizedBox(width: 8),
            _filterChip('Unread', ChatFilter.unread, badge: unreadCount > 0 ? unreadCount : null),
            const SizedBox(width: 8),
            _filterChip('Groups', ChatFilter.groups),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, ChatFilter filter, {int? badge}) {
    final active = _activeFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          gradient: active ? LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]) : null,
          color: active ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          if (badge != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
              child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ],
        ]),
      ),
    );
  }

  // ─── FOLDER TABS ──────────────────────────────────────────────────────────
  Widget _buildFolderTabs() {
    return SliverToBoxAdapter(
      child: Container(
        height: 44,
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          children: [
            // All chats tab
            GestureDetector(
              onTap: () => setState(() => _activeFolderId = null),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _activeFolderId == null ? AppTheme.primary.withOpacity(0.15) : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: _activeFolderId == null ? Border.all(color: AppTheme.primary.withOpacity(0.3)) : null,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.messageCircle, size: 13, color: _activeFolderId == null ? AppTheme.primary : Colors.white54),
                  const SizedBox(width: 4),
                  Text('All Chats', style: TextStyle(color: _activeFolderId == null ? AppTheme.primary : Colors.white54, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            ...(_folders.map((f) {
              final active = _activeFolderId == f.id;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _activeFolderId = active ? null : f.id),
                  onLongPress: () { _managingFolder = f; setState(() => _folderManageDialogOpen = true); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? f.color.withOpacity(0.15) : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: active ? Border.all(color: f.color.withOpacity(0.35)) : null,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_folderIconData(f.icon), size: 13, color: active ? f.color : Colors.white54),
                      const SizedBox(width: 4),
                      Text(f.name, style: TextStyle(color: active ? f.color : Colors.white54, fontSize: 12, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              );
            })),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => _openFolderDialog(),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                  child: Icon(LucideIcons.plus, size: 16, color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STORIES BAR ──────────────────────────────────────────────────────────
  Widget _buildStoriesBar() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => context.push('/stories'),
        child: Container(
          height: 96,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              // Add story button
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.2), const Color(0xFF7C3AED).withOpacity(0.1)]),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                  ),
                  child: Icon(LucideIcons.plus, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(height: 4),
                Text('Add Story', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
              ]),
              const SizedBox(width: 12),
              // Story placeholders (will be real data when stories loaded)
              ...List.generate(5, (i) {
                final colors = [const Color(0xFF7C3AED), const Color(0xFFFF0050), const Color(0xFF00B4D8), const Color(0xFFFF9F1C), const Color(0xFF2EC4B6)];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => context.push('/stories'),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        width: 60, height: 60,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [colors[i % colors.length], colors[(i + 2) % colors.length]]),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0D0A1A)),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(backgroundColor: colors[i % colors.length].withOpacity(0.3), child: Text(String.fromCharCode(65 + i), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('User ${i + 1}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                    ]),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CHAT LIST ────────────────────────────────────────────────────────────
  Widget _buildChatList(AsyncValue<List<Chat>> chatsAsync, dynamic user) {
    return chatsAsync.when(
      loading: () => SliverList(
        delegate: SliverChildBuilderDelegate((ctx, i) => _buildShimmerItem(), childCount: 7),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Error: $e', style: const TextStyle(color: Colors.white30)))),
      ),
      data: (chats) {
        // Filter logic
        var filtered = chats.where((c) {
          final isArchived = _archived.contains(c.id);
          if (_showArchived) return isArchived;
          if (isArchived) return false;
          if (_activeFolderId != null && _folderAssignments[c.id] != _activeFolderId) return false;
          if (_activeFilter == ChatFilter.unread) {
            final unread = user != null ? (c.participant1 == user.id ? c.unreadCount1 : c.unreadCount2) : 0;
            return unread > 0;
          }
          if (_activeFilter == ChatFilter.groups) return false; // Groups are separate in this app
          return true;
        }).toList();

        // Sort: pinned first, then by time
        filtered.sort((a, b) {
          final aPinned = _pinned.contains(a.id);
          final bPinned = _pinned.contains(b.id);
          if (aPinned && !bPinned) return -1;
          if (!aPinned && bPinned) return 1;
          final aTime = a.lastMessageTime ?? a.createdAt;
          final bTime = b.lastMessageTime ?? b.createdAt;
          return bTime.compareTo(aTime);
        });

        final archivedCount = _archived.length;

        return SliverList(
          delegate: SliverChildBuilderDelegate((ctx, idx) {
            // AI Assistant pinned entry at top
            if (idx == 0 && !_showArchived && _searchQuery.isEmpty) {
              return _buildAIEntry();
            }
            final chatIdx = _searchQuery.isEmpty && !_showArchived ? idx - 1 : idx;

            if (chatIdx < 0 || chatIdx >= filtered.length) {
              // After list: archived row + back row
              if (!_showArchived && archivedCount > 0 && chatIdx == filtered.length) {
                return _buildArchivedRow(archivedCount);
              }
              if (_showArchived && chatIdx == filtered.length) {
                return _buildBackToChatsRow();
              }
              return null;
            }

            return _buildChatItem(filtered[chatIdx], user, chatIdx);
          },
          childCount: (_searchQuery.isEmpty && !_showArchived ? 1 : 0) + filtered.length + ((!_showArchived && archivedCount > 0) || _showArchived ? 1 : 0),
          ),
        );
      },
    );
  }

  Widget _buildAIEntry() {
    return GestureDetector(
      onTap: () => context.push('/ai-assistant'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 16, spreadRadius: 1)],
            ),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Echat AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(6)),
                child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('Online', style: TextStyle(color: Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ]),
            Text('Translate, write, summarize & ask anything…', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, overflow: TextOverflow.ellipsis)),
          ])),
          Icon(LucideIcons.sparkles, size: 16, color: AppTheme.primary.withOpacity(0.5)),
        ]),
      ),
    );
  }

  Widget _buildChatItem(Chat chat, dynamic user, int index) {
    final otherId = user != null ? (chat.participant1 == user.id ? chat.participant2 : chat.participant1) : chat.participant2;
    final unreadCount = user != null ? (chat.participant1 == user.id ? chat.unreadCount1 : chat.unreadCount2) : 0;
    final isPinned = _pinned.contains(chat.id);
    final isMuted = _muted.contains(chat.id);

    return FutureBuilder<Profile?>(
      future: ref.read(supabaseServiceProvider).getProfile(otherId),
      builder: (ctx, snap) {
        final profile = snap.data;
        final name = profile?.name ?? profile?.username ?? 'User';
        final avatarUrl = profile?.avatarUrl;
        final isOnline = profile?.isOnline ?? false;
        final lastSeenText = profile != null ? _formatLastSeen(profile.lastSeen, isOnline) : '';

        return _SwipeableItem(
          key: ValueKey(chat.id),
          onPin: () => _togglePin(chat.id),
          onMute: () => _toggleMute(chat.id),
          onArchive: () => _toggleArchive(chat.id),
          onMoveToFolder: () {
            _movingChatId = chat.id;
            setState(() => _moveToFolderDialogOpen = true);
          },
          isPinned: isPinned,
          isMuted: isMuted,
          isArchived: _showArchived,
          child: GestureDetector(
            onTap: () => context.push('/chat/${chat.id}'),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 50 + index * 30),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                // Avatar with online indicator
                Stack(children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: avatarUrl == null ? LinearGradient(colors: [AppTheme.primary.withOpacity(0.6), const Color(0xFF7C3AED).withOpacity(0.4)]) : null,
                    ),
                    child: avatarUrl != null
                      ? ClipOval(child: Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))))
                      : Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                  ),
                  if (isOnline)
                    Positioned(bottom: 2, right: 2, child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D0A1A), width: 2)),
                    )),
                ]),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    if (isPinned) Padding(padding: const EdgeInsets.only(right: 4), child: Icon(LucideIcons.pin, size: 11, color: AppTheme.primary)),
                    Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis)),
                    Text(_formatTime(chat.lastMessageTime), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  ]),
                  const SizedBox(height: 2),
                  if (lastSeenText.isNotEmpty)
                    Text(lastSeenText, style: TextStyle(fontSize: 11, color: isOnline ? const Color(0xFF10B981) : Colors.white.withOpacity(0.35))),
                  Row(children: [
                    if (isMuted) Padding(padding: const EdgeInsets.only(right: 4), child: Icon(LucideIcons.bellOff, size: 11, color: Colors.white38)),
                    Expanded(child: Text(
                      chat.lastMessage ?? 'No messages yet',
                      style: TextStyle(color: unreadCount > 0 ? Colors.white70 : Colors.white38, fontSize: 13, fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )),
                    if (unreadCount > 0)
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 6)],
                        ),
                        child: Center(child: Text(unreadCount > 99 ? '99+' : '$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900))),
                      ),
                  ]),
                ])),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArchivedRow(int count) {
    return GestureDetector(
      onTap: () => setState(() => _showArchived = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)), child: Icon(LucideIcons.archive, size: 18, color: Colors.white54)),
          const SizedBox(width: 14),
          Text('Archived Chats ($count)', style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildBackToChatsRow() {
    return GestureDetector(
      onTap: () => setState(() => _showArchived = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(LucideIcons.arrowLeft, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Text('Back to Chats', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 14, width: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(7))),
          const SizedBox(height: 6),
          Container(height: 11, width: 180, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6))),
        ])),
      ]),
    );
  }

  // ─── SPEED DIAL FAB ─────────────────────────────────────────────────────
  Widget _buildSpeedDialFAB() {
    const actions = [
      {'icon': LucideIcons.messageSquarePlus, 'label': 'New Message', 'route': '/new-message'},
      {'icon': LucideIcons.users, 'label': 'New Group', 'route': '/new-group'},
      {'icon': LucideIcons.radio, 'label': 'New Channel', 'route': '/new-channel'},
      {'icon': LucideIcons.userPlus, 'label': 'New Contact', 'route': '/new-contact'},
    ];

    return Positioned(
      bottom: 90, right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sub-actions (animated)
          AnimatedOpacity(
            opacity: _speedDialOpen ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedSlide(
              offset: _speedDialOpen ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: (actions as List<Map<String, dynamic>>).map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _speedDialOpen = false);
                      context.push(a['route'] as String);
                    },
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
                        child: Text(a['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.8), const Color(0xFF7C3AED).withOpacity(0.8)]), shape: BoxShape.circle),
                        child: Icon(a['icon'] as IconData, color: Colors.white, size: 18),
                      ),
                    ]),
                  ),
                )).toList(),
              ),
            ),
          ),
          // Main FAB
          GestureDetector(
            onTap: () => setState(() => _speedDialOpen = !_speedDialOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 16, spreadRadius: 2)],
              ),
              child: AnimatedRotation(
                turns: _speedDialOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SEARCH OVERLAY ──────────────────────────────────────────────────────
  Widget _buildSearchOverlay(AsyncValue<List<Chat>> chatsAsync, dynamic user) {
    return Positioned.fill(
      child: Material(
        color: const Color(0xFF0D0A1A),
        child: SafeArea(
          child: Column(children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06)))),
              child: Column(children: [
                Row(children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.09))),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search Chats',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          border: InputBorder.none,
                          prefixIcon: Icon(LucideIcons.search, size: 16, color: Colors.white.withOpacity(0.4)),
                          suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(icon: Icon(LucideIcons.x, size: 14, color: Colors.white54), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                            : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _closeSearch,
                    child: Text('Cancel', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 10),
                // Tabs
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['chats', 'channels', 'people'].map((tab) {
                      final labels = {'chats': 'Chats', 'channels': 'Channels', 'people': 'People'};
                      final active = _searchTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _searchTab = tab);
                            if (tab == 'people') _searchPeople(_searchQuery);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: active ? LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]) : null,
                              color: active ? null : Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(labels[tab]!, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
              ]),
            ),
            // Content
            Expanded(child: _buildSearchContent(chatsAsync, user)),
          ]),
        ),
      ),
    );
  }

  Widget _buildSearchContent(AsyncValue<List<Chat>> chatsAsync, dynamic user) {
    if (_searchTab == 'chats') {
      final chats = chatsAsync.value ?? [];
      final filtered = chats.where((c) {
        if (_searchQuery.isEmpty) return true;
        // filter by last message or we need profile name — show all for now
        return c.lastMessage?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      }).toList();

      if (_searchQuery.isEmpty) {
        // Recent contacts circles + list
        return ListView(children: [
          if (chats.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Recent', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
            SizedBox(
              height: 88,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: chats.take(8).length,
                itemBuilder: (_, i) {
                  final chat = chats[i];
                  final otherId = user != null ? (chat.participant1 == user.id ? chat.participant2 : chat.participant1) : chat.participant2;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () { _closeSearch(); context.push('/chat/${chat.id}'); },
                      child: FutureBuilder<Profile?>(
                        future: ref.read(supabaseServiceProvider).getProfile(otherId),
                        builder: (_, snap) {
                          final p = snap.data;
                          final n = p?.name ?? p?.username ?? 'User';
                          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.5), const Color(0xFF7C3AED).withOpacity(0.4)]),
                              ),
                              child: p?.avatarUrl != null
                                ? ClipOval(child: Image.network(p!.avatarUrl!, fit: BoxFit.cover))
                                : Center(child: Text(n[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(width: 52, child: Text(n, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
                          ]);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.05)),
          ],
          ...chats.take(20).map((c) => _buildChatItem(c, user, 0)),
        ]);
      }

      if (filtered.isEmpty) {
        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.search, size: 48, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 12),
          Text('No chats found', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
        ]));
      }

      return ListView(children: filtered.map((c) => _buildChatItem(c, user, 0)).toList());
    }

    if (_searchTab == 'channels') {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.radio, size: 48, color: Colors.white.withOpacity(0.15)),
        const SizedBox(height: 12),
        GestureDetector(onTap: () { _closeSearch(); context.push('/channels'); },
          child: Text('Browse Channels', style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w600))),
      ]));
    }

    // People tab
    if (_searchQuery.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.users, size: 48, color: Colors.white.withOpacity(0.15)),
        const SizedBox(height: 12),
        Text('Search by @username', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
      ]));
    }

    if (_searchingPeople) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2));
    }

    if (_peopleResults.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.users, size: 48, color: Colors.white.withOpacity(0.15)),
        const SizedBox(height: 12),
        Text('No users found for "$_searchQuery"', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
      ]));
    }

    return ListView.builder(
      itemCount: _peopleResults.length,
      itemBuilder: (_, i) {
        final p = _peopleResults[i];
        return ListTile(
          onTap: () async {
            final currentUser = ref.read(authProvider).value;
            if (currentUser == null) return;
            final svc = ref.read(supabaseServiceProvider);
            try {
              final chatId = await svc.findOrCreateChat(currentUser.id, p.id);
              if (mounted) { _closeSearch(); context.push('/chat/$chatId'); }
            } catch (_) {}
          },
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.2),
            backgroundImage: p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
            child: p.avatarUrl == null ? Text((p.name ?? p.username)[0].toUpperCase(), style: const TextStyle(color: Colors.white)) : null,
          ),
          title: Text(p.name ?? p.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Text('@${p.username}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
        );
      },
    );
  }

  // ─── FOLDER DIALOGS ──────────────────────────────────────────────────────
  Widget _buildFolderDialog() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_editingFolder != null ? 'Edit Folder' : 'Create Folder', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _folderNameCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Folder name',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true, fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Text('Icon', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: ['folder', 'star', 'briefcase', 'heart', 'hash', 'users'].map((ic) {
              final selected = _folderIcon == ic;
              return GestureDetector(
                onTap: () => setState(() { _folderIcon = ic; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary.withOpacity(0.2) : Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(8),
                    border: selected ? Border.all(color: AppTheme.primary.withOpacity(0.5)) : null,
                  ),
                  child: Icon(_folderIconData(ic), size: 16, color: selected ? AppTheme.primary : Colors.white54),
                ),
              );
            }).toList()),
            const SizedBox(height: 16),
            Text('Color', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _folderColors.map((c) {
              final selected = _folderColor == c;
              return GestureDetector(
                onTap: () => setState(() => _folderColor = c),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: c,
                    border: selected ? Border.all(color: Colors.white, width: 2.5) : null,
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => _folderDialogOpen = false), child: Container(height: 46, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.white60)))))),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(onTap: _saveFolder, child: Container(height: 46, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(_editingFolder != null ? 'Save' : 'Create', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildFolderManageDialog() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Icon(_folderIconData(_managingFolder!.icon), size: 18, color: _managingFolder!.color),
              const SizedBox(width: 8),
              Text(_managingFolder!.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            const SizedBox(height: 16),
            _dialogActionRow(LucideIcons.pencil, 'Edit Folder', Colors.white, () { setState(() => _folderManageDialogOpen = false); _openFolderDialog(editing: _managingFolder); }),
            _dialogActionRow(LucideIcons.trash2, 'Delete Folder', Colors.red, () => _deleteFolder(_managingFolder!.id)),
            const SizedBox(height: 8),
            GestureDetector(onTap: () => setState(() => _folderManageDialogOpen = false), child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13))),
          ]),
        ),
      ),
    );
  }

  Widget _buildMoveToFolderDialog() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Move to Folder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (_folders.isEmpty)
              Padding(padding: const EdgeInsets.all(12), child: GestureDetector(onTap: () { setState(() => _moveToFolderDialogOpen = false); _openFolderDialog(); }, child: Text('+ Create a folder first', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600))))
            else ...[
              ..._folders.map((f) {
                final isCurrent = _movingChatId != null && _folderAssignments[_movingChatId!] == f.id;
                return _dialogActionRow(_folderIconData(f.icon), f.name, isCurrent ? AppTheme.primary : Colors.white, () => _moveChatToFolder(_movingChatId!, f.id));
              }),
              if (_movingChatId != null && _folderAssignments.containsKey(_movingChatId!))
                _dialogActionRow(LucideIcons.trash2, 'Remove from Folder', Colors.red, () => _removeChatFromFolder(_movingChatId!)),
            ],
            const SizedBox(height: 8),
            GestureDetector(onTap: () => setState(() => _moveToFolderDialogOpen = false), child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13))),
          ]),
        ),
      ),
    );
  }

  Widget _dialogActionRow(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Icon(icon, size: 18, color: color.withOpacity(0.8)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SWIPEABLE ITEM (swipe-to-reveal: pin / mute / archive / move)
// ═══════════════════════════════════════════════════════════════════════════
class _SwipeableItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onPin, onMute, onArchive, onMoveToFolder;
  final bool isPinned, isMuted, isArchived;

  const _SwipeableItem({
    super.key,
    required this.child,
    required this.onPin,
    required this.onMute,
    required this.onArchive,
    required this.onMoveToFolder,
    required this.isPinned,
    required this.isMuted,
    required this.isArchived,
  });

  @override
  State<_SwipeableItem> createState() => _SwipeableItemState();
}

class _SwipeableItemState extends State<_SwipeableItem> {
  double _offset = 0;
  bool _actionsVisible = false;

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    setState(() {
      _offset = (_offset + d.delta.dx).clamp(-220.0, 0.0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    if (_offset < -80) {
      setState(() { _offset = -220; _actionsVisible = true; });
    } else {
      setState(() { _offset = 0; _actionsVisible = false; });
    }
  }

  void _close() => setState(() { _offset = 0; _actionsVisible = false; });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          // Action buttons behind
          if (_actionsVisible)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _ActionBtn(widget.isPinned ? LucideIcons.pinOff : LucideIcons.pin, widget.isPinned ? 'Unpin' : 'Pin', const Color(0xFF3B82F6), () { _close(); widget.onPin(); }),
                  _ActionBtn(widget.isMuted ? LucideIcons.bellRing : LucideIcons.bellOff, widget.isMuted ? 'Unmute' : 'Mute', AppTheme.primary, () { _close(); widget.onMute(); }),
                  _ActionBtn(LucideIcons.folderInput, 'Move', const Color(0xFF8B5CF6), () { _close(); widget.onMoveToFolder(); }),
                  _ActionBtn(widget.isArchived ? LucideIcons.archiveRestore : LucideIcons.archive, widget.isArchived ? 'Unarchive' : 'Archive', const Color(0xFFEF4444), () { _close(); widget.onArchive(); }),
                ]),
              ),
            ),
          // The actual chat item
          Transform.translate(
            offset: Offset(_offset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn(this.icon, this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        color: color,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
