import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_persistence_service.dart';
import '../../widgets/stories_bar.dart';
import '../../widgets/groups_list.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedFolderId = 'all';

  final List<Map<String, String>> _mockFolders = [
    {'id': 'all', 'name': 'All Chats'},
    {'id': 'unread', 'name': 'Unread'},
    {'id': 'work', 'name': 'Work'},
    {'id': 'personal', 'name': 'Personal'},
    {'id': 'bots', 'name': 'Bots'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
       if (_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFoldersBar() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mockFolders.length,
        itemBuilder: (context, index) {
          final folder = _mockFolders[index];
          final isSelected = _selectedFolderId == folder['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedFolderId = folder['id']!),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? Colors.transparent : Colors.white10),
                ),
                alignment: Alignment.center,
                child: Text(
                  folder['name']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatsState = ref.watch(userChatsStreamProvider);
    final user = ref.watch(authProvider).value;
    final currentUserId = user?.id;
    
    if (currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final metadataState = ref.watch(chatMetadataProvider(currentUserId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _isSearching ? null : IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() {}),
              )
            : const Text(
                'Echat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            }),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/contacts'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Groups'),
            Tab(text: 'Channels'),
          ],
        ),
      ),
      body: AuroraGradientBg(
        child: SafeArea(
          child: metadataState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error: $err')),
            data: (metadata) {
              return chatsState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('Error: $err')),
                data: (allChats) {
                  // If we are in Groups or Channels tab, show the specific list
                  if (_tabController.index == 2) {
                    return const Padding(padding: EdgeInsets.only(top: 8), child: GroupsList(showChannels: false));
                  }
                  if (_tabController.index == 3) {
                    return const Padding(padding: EdgeInsets.only(top: 8), child: GroupsList(showChannels: true));
                  }

                  // Apply Filters for All/Unread
                  var filteredChats = allChats.where((chat) {
                    if (metadata.archived.contains(chat.id)) return false;
                    
                    // Folder Filtering
                    if (_selectedFolderId == 'unread') {
                      final unread = (chat.participant1 == currentUserId) ? (chat.unreadCount1 ?? 0) : (chat.unreadCount2 ?? 0);
                      if (unread <= 0) return false;
                    } else if (_selectedFolderId == 'work') {
                      // Mock: Chats with certain names or long history
                      if (!chat.id.contains('work') && (chat.lastMessage ?? '').length < 10) return false;
                    } else if (_selectedFolderId == 'personal') {
                      if (chat.id.contains('group')) return false;
                    } else if (_selectedFolderId == 'bots') {
                      if (!chat.id.contains('bot')) return false;
                    }

                    if (_tabController.index == 1) { // Unread Tab
                      final unread = (chat.participant1 == currentUserId) ? (chat.unreadCount1 ?? 0) : (chat.unreadCount2 ?? 0);
                      if (unread <= 0) return false;
                    }
                    
                    if (_isSearching && _searchController.text.isNotEmpty) {
                      // Note: Name-based filtering disabled here because profile data 
                      // is fetched asynchronously in each ChatItem tile.
                      // Global search or profile-joined stream recommended for full search parity.
                      // final query = _searchController.text.toLowerCase();
                      // final otherUser = (chat.participant1 == currentUserId) ? chat.user2 : chat.user1;
                      // final name = otherUser?.name?.toLowerCase() ?? '';
                      // final username = otherUser?.username?.toLowerCase() ?? '';
                      // return name.contains(query) || username.contains(query);
                    }
                    
                    return true;
                  }).toList();

                  // Sort: Pinned first, then by time
                  filteredChats.sort((a, b) {
                    final aPinned = metadata.pinned.contains(a.id);
                    final bPinned = metadata.pinned.contains(b.id);
                    if (aPinned != bPinned) return aPinned ? -1 : 1;
                    
                    final fallbackTime = DateTime(2000);
                    final aTime = a.lastMessageTime ?? a.createdAt ?? fallbackTime;
                    final bTime = b.lastMessageTime ?? b.createdAt ?? fallbackTime;
                    return bTime.compareTo(aTime);
                  });

                  return ListView.builder(
                    itemCount: filteredChats.length + 1,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: StoriesBar(),
                            ),
                            _buildFoldersBar(),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                      final chat = filteredChats[index - 1];
                      return _ChatItem(
                        chat: chat, 
                        currentUserId: currentUserId,
                        isPinned: metadata.pinned.contains(chat.id),
                        isMuted: metadata.muted.contains(chat.id),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.day == time.day && yesterday.month == time.month && yesterday.year == time.year) {
      return 'Yesterday';
    }
    return '${time.day}/${time.month}';
  }
}

class _ChatItem extends ConsumerWidget {
  final dynamic chat;
  final String currentUserId;
  final bool isPinned;
  final bool isMuted;

  const _ChatItem({
    required this.chat,
    required this.currentUserId,
    required this.isPinned,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherId = (chat.participant1 == currentUserId) ? chat.participant2 : chat.participant1;
    final profileAsync = ref.watch(profileProvider(otherId));
    final unread = (chat.participant1 == currentUserId) ? (chat.unreadCount1 ?? 0) : (chat.unreadCount2 ?? 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Slidable(
        key: ValueKey(chat.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => ref.read(chatMetadataProvider(currentUserId).notifier).togglePin(chat.id),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              label: isPinned ? 'Unpin' : 'Pin',
            ),
            SlidableAction(
              onPressed: (context) => ref.read(chatMetadataProvider(currentUserId).notifier).toggleArchive(chat.id),
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              icon: Icons.archive_outlined,
              label: 'Archive',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => ref.read(chatMetadataProvider(currentUserId).notifier).toggleMute(chat.id),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: isMuted ? Icons.volume_up : Icons.volume_off,
              label: isMuted ? 'Unmute' : 'Mute',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => context.push('/chat/${chat.id}'),
          child: GlassmorphicContainer(
            padding: const EdgeInsets.all(12),
            isStrong: isPinned,
            borderColor: isPinned ? AppTheme.primary.withOpacity(0.3) : null,
            child: Row(
              children: [
                Stack(
                  children: [
                    profileAsync.when(
                      data: (profile) => CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                        backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                        child: profile?.avatarUrl == null 
                            ? Text(
                                (profile?.name ?? 'U').substring(0, 1).toUpperCase(), 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ) 
                            : null,
                      ),
                      loading: () => CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (_, __) => CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.red.withOpacity(0.2),
                        child: const Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                    if (isPinned)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: const Icon(Icons.push_pin, size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          profileAsync.when(
                            data: (profile) => Text(
                              profile?.name ?? 'User',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                            ),
                            loading: () => Container(width: 100, height: 16, color: Colors.white10),
                            error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                          ),
                          if (chat.lastMessageTime != null)
                            Text(
                              _formatTime(chat.lastMessageTime!),
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (chat.lastSenderId == currentUserId)
                            const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(Icons.done_all, size: 14, color: Colors.blue),
                            ),
                          Expanded(
                            child: Text(
                              chat.lastMessage ?? 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: unread > 0 ? Colors.white : Colors.white60,
                                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (isMuted)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(Icons.volume_off, size: 14, color: Colors.white38),
                            ),
                          if (unread > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)
                                ]
                              ),
                              child: Text(
                                unread.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.day == time.day && yesterday.month == time.month && yesterday.year == time.year) {
      return 'Yesterday';
    }
    return '${time.day}/${time.month}';
  }
}
