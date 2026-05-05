import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<String> storyUrls;
  final String username;
  const StoryViewerScreen({super.key, required this.storyUrls, required this.username});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(vsync: this);
    _startStory();
  }

  void _startStory() {
    _progressController.stop();
    _progressController.duration = const Duration(seconds: 5);
    _progressController.reset();
    _progressController.forward().whenComplete(() {
      if (_currentIndex < widget.storyUrls.length - 1) {
        _nextStory();
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _nextStory() {
    setState(() {
      _currentIndex++;
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
    _startStory();
  }

  void _prevStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
      _startStory();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          GestureDetector(
            onTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < width / 3) {
                _prevStory();
              } else {
                _nextStory();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.storyUrls.length,
              itemBuilder: (context, index) {
                return Image.network(widget.storyUrls[index], fit: BoxFit.cover);
              },
            ),
          ),

          // Header & Progress Bars
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: List.generate(widget.storyUrls.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              double value = 0;
                              if (index < _currentIndex) value = 1;
                              else if (index == _currentIndex) value = _progressController.value;
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                                minHeight: 2,
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 16, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 16)),
                      const SizedBox(width: 12),
                      Text(widget.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reply Area
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
                    child: const TextField(
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(hintText: 'Send message', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.favorite_border, color: Colors.white),
                const SizedBox(width: 12),
                const Icon(Icons.send, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
