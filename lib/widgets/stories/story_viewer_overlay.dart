import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/story.dart';
import '../../services/story_service.dart';
import '../../providers/story_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../chat_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

class StoryViewerOverlay extends ConsumerStatefulWidget {
  final StoryGroup group;
  final VoidCallback onClose;

  const StoryViewerOverlay({
    super.key,
    required this.group,
    required this.onClose,
  });

  @override
  ConsumerState<StoryViewerOverlay> createState() => _StoryViewerOverlayState();
}

class _StoryViewerOverlayState extends ConsumerState<StoryViewerOverlay> {
  late int _currentIndex;
  double _progress = 0;
  bool _isPaused = false;
  Timer? _timer;
  VideoPlayerController? _videoController;
  final int _durationPerStory = 5000; // 5 seconds
  
  final List<Map<String, dynamic>> _flyingEmojis = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _startTimer();
    _markCurrentAsViewed();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPaused) {
        setState(() {
          _progress += 50 / _durationPerStory;
          if (_progress >= 1.0) {
            _nextStory();
          }
        });
      }
    });
  }

  void _markCurrentAsViewed() {
    final story = widget.group.stories[_currentIndex];
    ref.read(storyServiceProvider).viewStory(story.id);

    // Initialize video if needed
    _videoController?.dispose();
    _videoController = null;
    
    if (story.storyType == StoryType.video && story.mediaUrl != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(story.mediaUrl!))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
          }
        });
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.group.stories.length - 1) {
      setState(() {
        _currentIndex++;
        _progress = 0;
      });
      _markCurrentAsViewed();
    } else {
      widget.onClose();
    }
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _progress = 0;
      });
      _markCurrentAsViewed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.group.stories[_currentIndex];
    final userId = ref.watch(authProvider).value?.id;
    final isOwn = story.userId == userId;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) {
          setState(() => _isPaused = true);
          _videoController?.pause();
        },
        onLongPressEnd: (_) {
          setState(() => _isPaused = false);
          _videoController?.play();
        },
        onTapUp: (details) {
          final x = details.globalPosition.dx;
          final width = MediaQuery.of(context).size.width;
          if (x < width / 3) {
            _prevStory();
          } else if (x > width * 2 / 3) {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Story Content
            _buildStoryContent(story),

            // Progress Bars
            _buildProgressBars(),

            // Header
            _buildHeader(story, isOwn),

            // Reactions & Reply
            if (!isOwn) _buildBottomControls(),

            // Flying Emojis
            ..._flyingEmojis.map((e) => _buildFlyingEmoji(e)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent(UserStory story) {
    if (story.storyType == StoryType.text) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: _parseBackground(story.backgroundColor),
        child: Center(
          child: Text(
            story.content ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
        ),
      );
    }
    
    if (story.storyType == StoryType.video && _videoController != null) {
      return Center(
        child: _videoController!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            : const CircularProgressIndicator(color: Colors.white24),
      );
    }

    return Center(
      child: story.mediaUrl != null 
        ? Image.network(
            story.mediaUrl!, 
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white24));
            },
          ) 
        : const SizedBox.shrink(),
    );
  }

  BoxDecoration _parseBackground(String? bg) {
    if (bg == null) return const BoxDecoration(color: Colors.black);
    
    if (bg.startsWith('linear-gradient')) {
      // Basic extraction of colors from 'linear-gradient(135deg, #f97316, #ec4899)'
      final colors = <Color>[];
      final hexRegex = RegExp(r'#[a-fA-F0-9]{6}');
      final matches = hexRegex.allMatches(bg);
      for (final m in matches) {
        colors.add(Color(int.parse('0xFF${m.group(0)!.substring(1)}')));
      }
      if (colors.isNotEmpty) {
        return BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      }
    } else if (bg.startsWith('#')) {
      return BoxDecoration(color: Color(int.parse('0xFF${bg.substring(1)}')));
    }
    
    return const BoxDecoration(color: Colors.black);
  }

  Widget _buildProgressBars() {
    return Positioned(
      top: 60, left: 12, right: 12,
      child: Row(
        children: List.generate(widget.group.stories.length, (index) {
          return Expanded(
            child: Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(1)),
              child: index < _currentIndex
                  ? Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)))
                  : index == _currentIndex
                      ? FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progress,
                          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1))),
                        )
                      : const SizedBox.shrink(),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(UserStory story, bool isOwn) {
    return Positioned(
      top: 76, left: 16, right: 16,
      child: Row(
        children: [
          ChatAvatar(name: widget.group.name, src: widget.group.avatarUrl, size: 'xs'),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOwn ? 'Your Story' : widget.group.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                _getTimeAgo(story.createdAt),
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
              ),
            ],
          ),
          const Spacer(),
          if (isOwn)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.white70, size: 20),
              onPressed: () => _confirmDelete(story.id),
            ),
          IconButton(
            icon: const Icon(LucideIcons.x, color: Colors.white, size: 24),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '1d ago';
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40, left: 16, right: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['❤️', '🔥', '😂', '😮', '👏', '💯'].map((emoji) => GestureDetector(
              onTap: () {
                _addFlyingEmoji(emoji);
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(emoji, style: const TextStyle(fontSize: 26)).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const TextField(
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Send message...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String storyId) {
    _isPaused = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Delete Story?', style: TextStyle(color: Colors.white)),
        content: const Text('This will permanently remove this story.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); _isPaused = false; }, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(storyServiceProvider).deleteStory(storyId);
              ref.read(storiesProvider.notifier).loadStories();
              _nextStory();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addFlyingEmoji(String emoji) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _flyingEmojis.add({'id': id, 'emoji': emoji, 'x': 0.1 + (0.8 * (id.hashCode % 100) / 100)});
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _flyingEmojis.removeWhere((e) => e['id'] == id));
      }
    });
  }

  Widget _buildFlyingEmoji(Map<String, dynamic> e) {
    return _FlyingEmoji(emoji: e['emoji'], startX: e['x'] * MediaQuery.of(context).size.width);
  }
}

class _FlyingEmoji extends StatefulWidget {
  final String emoji;
  final double startX;
  const _FlyingEmoji({required this.emoji, required this.startX});

  @override
  State<_FlyingEmoji> createState() => _FlyingEmojiState();
}

class _FlyingEmojiState extends State<_FlyingEmoji> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _yAnim = Tween<double>(begin: 0, end: -400).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacityAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0), weight: 20),
    ]).animate(_controller);
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 120,
      left: widget.startX,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: Offset(0, _yAnim.value),
            child: Transform.scale(scale: _scaleAnim.value, child: Text(widget.emoji, style: const TextStyle(fontSize: 40))),
          ),
        ),
      ),
    );
  }
}
