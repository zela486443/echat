import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

class LiveStoriesScreen extends ConsumerStatefulWidget {
  const LiveStoriesScreen({super.key});

  @override
  ConsumerState<LiveStoriesScreen> createState() => _LiveStoriesScreenState();
}

class _LiveStoriesScreenState extends ConsumerState<LiveStoriesScreen> with TickerProviderStateMixin {
  int? _selectedStoryIndex;
  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = ['Wow! 😍', 'This is amazing!', 'Ethiopia 🇪🇹'];
  final List<Widget> _reactionParticles = [];

  final List<Map<String, dynamic>> _stories = [
    {'id': '1', 'name': 'Kaleb Tesfaye', 'title': 'Morning Coding Session 💻', 'viewers': 120},
    {'id': '2', 'name': 'Abebe Bikila', 'title': 'Training in Sululta 🏃‍♂️', 'viewers': 450},
    {'id': '3', 'name': 'Zola Tech', 'title': 'Flutter Mastery Live', 'viewers': 32},
  ];

  void _addReaction(String emoji) {
    setState(() {
      _reactionParticles.add(_buildParticle(emoji));
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _reactionParticles.removeAt(0));
    });
  }

  Widget _buildParticle(String emoji) {
    final startX = math.Random().nextDouble() * 200 - 100;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Positioned(
          bottom: 100 + (value * 200),
          left: (MediaQuery.of(context).size.width / 2) + startX + (math.sin(value * 10) * 20),
          child: Opacity(opacity: 1 - value, child: Text(emoji, style: const TextStyle(fontSize: 32))),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _selectedStoryIndex == null ? _buildListView() : _buildStreamView(),
    );
  }

  Widget _buildListView() {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final story = _stories[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedStoryIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 2)), child: CircleAvatar(radius: 24, backgroundColor: Colors.white10, child: Icon(LucideIcons.user, color: Colors.white24))),
                            Positioned(bottom: -2, right: -2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(story['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(story['title'], style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(LucideIcons.eye, color: Colors.white24, size: 14),
                            const SizedBox(width: 4),
                            Text('${story['viewers']}', style: const TextStyle(color: Colors.white24, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _stories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.black.withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: const Text('Live Stories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.radio, color: Colors.white, size: 14), SizedBox(width: 8), Text('Go Live', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
          ),
        ),
      ],
    );
  }

  Widget _buildStreamView() {
    final story = _stories[_selectedStoryIndex!];
    return Stack(
      children: [
        // Background - Mock Video Placeholder
        Container(color: Colors.black, child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.radio, color: Colors.redAccent, size: 64), SizedBox(height: 16), Text('Live Stream Active', style: TextStyle(color: Colors.white38))]))),
        
        // UI Overlay
        SafeArea(
          child: Column(
            children: [
              _buildStreamHeader(story),
              const Spacer(),
              _buildCommentOverlay(),
              _buildReactionOverlay(),
              _buildStreamFooter(),
            ],
          ),
        ),
        
        // Reaction Particles
        ..._reactionParticles,
      ],
    );
  }

  Widget _buildStreamHeader(Map<String, dynamic> story) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(LucideIcons.radio, color: Colors.white, size: 12), SizedBox(width: 4), Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))])),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(LucideIcons.eye, color: Colors.white, size: 12), const SizedBox(width: 4), Text('${story['viewers']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))])),
          const Spacer(),
          IconButton(icon: const Icon(LucideIcons.x, color: Colors.white, size: 24), onPressed: () => setState(() => _selectedStoryIndex = null)),
        ],
      ),
    );
  }

  Widget _buildCommentOverlay() {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: _comments.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [const Text('User: ', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)), Text(_comments[index], style: const TextStyle(color: Colors.white, fontSize: 13))]),
        ),
      ),
    );
  }

  Widget _buildReactionOverlay() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['❤️', '😂', '😮', '😢', '🔥', '👏'].map((e) => GestureDetector(onTap: () => _addReaction(e), child: Padding(padding: const EdgeInsets.only(right: 16), child: Text(e, style: const TextStyle(fontSize: 24))))).toList(),
      ),
    );
  }

  Widget _buildStreamFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Comment...', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
                onSubmitted: (v) {
                   setState(() => _comments.add(v));
                   _commentController.clear();
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(icon: const Icon(LucideIcons.send, color: Colors.white, size: 20), onPressed: () {}),
        ],
      ),
    );
  }
}
