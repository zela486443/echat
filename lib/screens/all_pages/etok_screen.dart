import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../services/etok_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/etok_video.dart';

class EtokScreen extends ConsumerStatefulWidget {
  const EtokScreen({super.key});

  @override
  ConsumerState<EtokScreen> createState() => _EtokScreenState();
}

class _EtokScreenState extends ConsumerState<EtokScreen> {
  final PageController _pageController = PageController();
  List<EtokVideo> _videos = [];
  bool _loading = true;
  String _activeTab = 'fyp';

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final service = EtokService();
    final videos = await service.fetchFYPVideos();
    if (mounted) {
      setState(() {
        _videos = videos;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_videos.isEmpty)
            _buildEmptyState()
          else
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              itemBuilder: (context, index) => EtokVideoCard(video: _videos[index]),
            ),
          _buildHeader(),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No videos found', style: TextStyle(color: Colors.white)));
  }

  Widget _buildHeader() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTab('Following', _activeTab == 'following'),
          const SizedBox(width: 20),
          _buildTab('For You', _activeTab == 'fyp'),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _activeTab = label.toLowerCase().replaceAll(' ', '')),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 17, shadows: const [Shadow(blurRadius: 4, color: Colors.black)])),
          if (active) Container(margin: const EdgeInsets.only(top: 4), width: 24, height: 3, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
     return Positioned(
       bottom: 0,
       left: 0,
       right: 0,
       child: Container(
         height: 60,
         decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white12, width: 0.5))),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: [
             _buildNavIcon(LucideIcons.home, 'Home', true),
             _buildNavIcon(LucideIcons.users, 'Friends', false),
             _buildAddIcon(),
             _buildNavIcon(LucideIcons.messageCircle, 'Inbox', false),
             _buildNavIcon(LucideIcons.user, 'Profile', false),
           ],
         ),
       ),
     );
  }

  Widget _buildNavIcon(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? Colors.white : Colors.white54, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildAddIcon() {
    return Container(
      width: 45,
      height: 28,
      child: Stack(
        children: [
          Container(margin: const EdgeInsets.only(left: 10), decoration: BoxDecoration(color: const Color(0xFF20D5EC), borderRadius: BorderRadius.circular(7))),
          Container(margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: const Color(0xFFFF0050), borderRadius: BorderRadius.circular(7))),
          Center(
            child: Container(
              height: double.infinity,
              width: 38,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7)),
              child: const Icon(LucideIcons.plus, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class EtokVideoCard extends StatefulWidget {
  final EtokVideo video;
  const EtokVideoCard({super.key, required this.video});

  @override
  State<EtokVideoCard> createState() => _EtokVideoCardState();
}

class _EtokVideoCardState extends State<EtokVideoCard> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _initialized 
              ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
              : const Center(child: CircularProgressIndicator(color: Colors.white24)),
          ),
        ),
        _buildSidebar(),
        _buildBottomContent(),
      ],
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      bottom: 100,
      right: 12,
      child: Column(
        children: [
          _buildProfileAvatar(),
          const SizedBox(height: 20),
          _buildSidebarIcon(LucideIcons.heart, widget.video.likes.toString(), Colors.white),
          const SizedBox(height: 16),
          _buildSidebarIcon(LucideIcons.messageCircle, widget.video.comments.toString(), Colors.white),
          const SizedBox(height: 16),
          _buildSidebarIcon(LucideIcons.share2, widget.video.shares.toString(), Colors.white),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
     return Stack(
       alignment: Alignment.bottomCenter,
       clipBehavior: Clip.none,
       children: [
         Container(
           padding: const EdgeInsets.all(1),
           decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
           child: CircleAvatar(
             radius: 24,
             backgroundColor: Colors.black,
             backgroundImage: widget.video.author?.avatarUrl != null ? NetworkImage(widget.video.author!.avatarUrl!) : null,
           ),
         ),
         Positioned(
           bottom: -10,
           child: Container(
             padding: const EdgeInsets.all(2),
             decoration: BoxDecoration(color: Color(0xFFFF0050), shape: BoxShape.circle),
             child: const Icon(LucideIcons.plus, color: Colors.white, size: 12),
           ),
         ),
       ],
     );
  }

  Widget _buildSidebarIcon(IconData icon, String count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32, shadows: const [Shadow(blurRadius: 10, color: Colors.black54)]),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
      ],
    );
  }

  Widget _buildBottomContent() {
    return Positioned(
      bottom: 80,
      left: 12,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('@${widget.video.author?.username ?? "user"}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
          const SizedBox(height: 8),
          Text(widget.video.description, style: const TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.music, color: Colors.white, size: 14),
              const SizedBox(width: 8),
              Text(widget.video.soundName, style: const TextStyle(color: Colors.white, fontSize: 12, shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
            ],
          ),
        ],
      ),
    );
  }
}
