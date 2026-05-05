import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EtokFeed extends StatefulWidget {
  const EtokFeed({super.key});

  @override
  State<EtokFeed> createState() => _EtokFeedState();
}

class _EtokFeedState extends State<EtokFeed> {
  final PageController _pageController = PageController();

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Always dark for TikTok feel
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Following', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
            const SizedBox(width: 16),
            const Text('For You', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.camera, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: 10,
          itemBuilder: (context, index) {
            return _VideoPlayerMock(index: index);
          },
        ),
      ),
    );
  }
}

class _VideoPlayerMock extends StatelessWidget {
  final int index;
  const _VideoPlayerMock({required this.index});

  @override
  Widget build(BuildContext context) {
    // A mock representation of a video player taking full screen
    return Stack(
      fit: StackFit.expand,
      children: [
        // Simulated Video background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade900, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Icon(Icons.play_circle_outline, size: 80, color: Colors.white54),
          ),
        ),
        
        // Right Side Actions
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionBtn(LucideIcons.heart, '1.2M'),
                const SizedBox(height: 16),
                _ActionBtn(LucideIcons.messageCircle, '45K'),
                const SizedBox(height: 16),
                _ActionBtn(LucideIcons.share2, 'Share'),
              ],
            ),
          ),
        ),
        
        // Bottom Info
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@user_$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  'Check out this awesome new flutter layout! #flutter #dev #mobile',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(LucideIcons.music, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Original Sound - echats', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ActionBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
