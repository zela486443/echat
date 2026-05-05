import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/etok_provider.dart';
import '../../models/etok_video.dart';
import '../../widgets/etok_video_player.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../components/etok/etok_share_sheet.dart';

class EtokScreen extends ConsumerStatefulWidget {
  const EtokScreen({super.key});

  @override
  ConsumerState<EtokScreen> createState() => _EtokScreenState();
}

class _EtokScreenState extends ConsumerState<EtokScreen> {
  final PageController _pageController = PageController();
  int _focusedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(etokTabProvider);
    final videosAsync = activeTab == 1 
        ? ref.watch(fypVideosProvider) 
        : ref.watch(followingVideosProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          videosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
            data: (videos) {
              if (videos.isEmpty) {
                return _buildEmptyState(activeTab);
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: videos.length,
                onPageChanged: (index) => setState(() => _focusedIndex = index),
                itemBuilder: (context, index) {
                  return _VideoItem(
                    video: videos[index], 
                    isFocused: _focusedIndex == index,
                  );
                },
              );
            },
          ),
          
          // Top Overlay
          _buildTopTabs(activeTab),
          
          // Right Search Icon
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 10,
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white, size: 28),
              onPressed: () => context.push('/etok/search'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabs(int activeTab) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tabButton('Following', activeTab == 0, () => ref.read(etokTabProvider.notifier).state = 0),
              const SizedBox(width: 24),
              _tabButton('For You', activeTab == 1, () => ref.read(etokTabProvider.notifier).state = 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 16,
              fontWeight: active ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          if (active) Container(width: 20, height: 2, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildEmptyState(int activeTab) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_creation_outlined, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text(
            activeTab == 1 ? 'No videos found.' : 'Follow creators to see their videos.',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _VideoItem extends ConsumerStatefulWidget {
  final EtokVideo video;
  final bool isFocused;

  const _VideoItem({required this.video, required this.isFocused});

  @override
  ConsumerState<_VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends ConsumerState<_VideoItem> {
  bool _isLiked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.video.likes;
  }

  void _handleLike() async {
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;

    final result = await ref.read(etokServiceProvider).toggleLike(widget.video.id, userId);
    if (mounted) {
      setState(() {
        _isLiked = result;
        _likeCount += result ? 1 : (_likeCount > 0 ? -1 : 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        EtokVideoPlayer(
          videoUrl: widget.video.videoUrl,
          thumbnailUrl: widget.video.thumbnailUrl,
          play: widget.isFocused,
          onLike: _isLiked ? null : _handleLike,
        ),

        // Gradient Bottom Cover
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 300,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Information Overlay
        Positioned(
          bottom: 20,
          left: 16,
          right: 80, // Space for right sidebar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push('/etok/profile/${widget.video.authorId}'),
                child: Text(
                  '@${widget.video.author?.username ?? 'user'}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.video.description,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (widget.video.hashtags.isNotEmpty)
                Text(
                  widget.video.hashtags.map((h) => '#$h').join(' '),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              const SizedBox(height: 12),
              // Music scrolling emulation
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Original Sound - ${widget.video.soundName}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right Sidebar Actions
        Positioned(
          bottom: 40,
          right: 8,
          child: _SidebarActions(
            video: widget.video,
            isLiked: _isLiked,
            likeCount: _likeCount,
            onLike: _handleLike,
          ),
        ),
      ],
    );
  }
}

class _SidebarActions extends ConsumerStatefulWidget {
  final EtokVideo video;
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;
  
  const _SidebarActions({
    required this.video,
    required this.isLiked,
    required this.likeCount,
    required this.onLike,
  });

  @override
  ConsumerState<_SidebarActions> createState() => _SidebarActionsState();
}

class _SidebarActionsState extends ConsumerState<_SidebarActions> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleLike() async {
    widget.onLike();
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(video: widget.video),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const EtokShareSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAuthorAvatar(widget.video.author?.avatarUrl),
        const SizedBox(height: 25),
        _SidebarAction(
          icon: Icons.favorite, 
          label: _formatCount(widget.likeCount), 
          color: widget.isLiked ? Colors.red : Colors.white,
          onTap: _handleLike,
        ),
        _SidebarAction(
          icon: Icons.chat_bubble_rounded, 
          label: _formatCount(widget.video.comments),
          onTap: _showComments,
        ),
        const _SidebarAction(icon: Icons.card_giftcard, label: 'Gift', color: Colors.amber),
        _SidebarAction(icon: Icons.share, label: 'Share', onTap: _showShareSheet),
        const _MusicSpinningDisc(),
      ],
    );
  }

  Widget _buildAuthorAvatar(String? url) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => context.push('/etok/profile/${widget.video.authorId}'),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[900],
              backgroundImage: url != null ? NetworkImage(url) : null,
              child: url == null ? Text((widget.video.author?.name ?? widget.video.author?.username ?? 'U')[0]) : null,
            ),
          ),
        ),
        if (!_isFollowing)
          Positioned(
            bottom: -10,
            child: GestureDetector(
              onTap: () => setState(() => _isFollowing = true),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Color(0xFFFF0050), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
          ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _SidebarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SidebarAction({required this.icon, required this.label, this.color = Colors.white, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CommentsSheet extends ConsumerStatefulWidget {
  final EtokVideo video;
  const _CommentsSheet({required this.video});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = ref.read(etokServiceProvider).fetchComments(widget.video.id);
  }

  void _postComment() async {
    if (_commentController.text.isEmpty) return;
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;

    await ref.read(etokServiceProvider).addComment(widget.video.id, userId, _commentController.text);
    _commentController.clear();
    setState(() {
      _commentsFuture = ref.read(etokServiceProvider).fetchComments(widget.video.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('Comments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white24));
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet', style: TextStyle(color: Colors.white24)));
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    final author = c['author'] as Map<String, dynamic>?;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundImage: author?['avatar_url'] != null ? NetworkImage(author!['avatar_url']) : null,
                        child: author?['avatar_url'] == null ? Text(author?['name'][0] ?? 'U') : null,
                      ),
                      title: Text(author?['username'] ?? 'user', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(c['content'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 16, right: 16, top: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                IconButton(onPressed: _postComment, icon: const Icon(Icons.send, color: Color(0xFFFF0050))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MusicSpinningDisc extends StatefulWidget {
  const _MusicSpinningDisc();
  @override
  State<_MusicSpinningDisc> createState() => _MusicSpinningDiscState();
}

class _MusicSpinningDiscState extends State<_MusicSpinningDisc> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const RadialGradient(colors: [Colors.black, Colors.grey]),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 2),
        ),
        child: const Icon(Icons.music_note, color: Colors.white54, size: 16),
      ),
    );
  }
}
