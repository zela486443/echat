import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'dart:io';
import '../../services/story_service.dart';
import '../../providers/story_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/story.dart';
import '../../widgets/stories/story_creator_overlay.dart';
import '../../widgets/stories/story_viewer_overlay.dart';
import '../../widgets/chat_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storiesProvider);
    final currentUserId = ref.watch(authProvider).value?.id;

    return Scaffold(
      backgroundColor: const Color(0xFF03001C),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100, 
            left: -50, 
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), 
              child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF7C3AED).withOpacity(0.1))),
            ),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.pop()),
                title: const Text('Stories', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 24, letterSpacing: -0.5)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white38),
                    onPressed: () => ref.read(storiesProvider.notifier).loadStories(),
                  )
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: storiesAsync.when(
                  data: (groups) => SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) return _buildAddStoryCard(context);
                        final group = groups[index - 1];
                        return _buildStoryCard(context, group, index - 1);
                      },
                      childCount: groups.length + 1,
                    ),
                  ),
                  loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)))),
                  error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white24)))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddStoryCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCreator(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.add, color: Color(0xFF7C3AED), size: 32),
                ),
                const SizedBox(height: 16),
                const Text('Share yours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('Post a story', style: TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildStoryCard(BuildContext context, StoryGroup group, int index) {
    final lastStory = group.stories.last;
    return GestureDetector(
      onTap: () => _openViewer(context, group),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: group.hasUnviewed ? const Color(0xFF7C3AED).withOpacity(0.5) : Colors.white10,
            width: group.hasUnviewed ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Media or Background
              if (lastStory.mediaUrl != null)
                Positioned.fill(child: Image.network(lastStory.mediaUrl!, fit: BoxFit.cover))
              else
                Positioned.fill(child: _buildTextBackground(lastStory.backgroundColor)),
              
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                ),
              ),

              // Content Preview
              if (lastStory.storyType == StoryType.text)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      lastStory.content ?? '',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              // User Info
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Row(
                  children: [
                    ChatAvatar(name: group.name, src: group.avatarUrl, size: 'xs'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().scale(delay: (index * 50).ms, duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTextBackground(String? bg) {
    if (bg == null) return Container(color: Colors.black);
    if (bg.startsWith('linear-gradient')) {
      final colors = <Color>[];
      final hexRegex = RegExp(r'#[a-fA-F0-9]{6}');
      final matches = hexRegex.allMatches(bg);
      for (final m in matches) {
        colors.add(Color(int.parse('0xFF${m.group(0)!.substring(1)}')));
      }
      if (colors.isNotEmpty) return Container(decoration: BoxDecoration(gradient: LinearGradient(colors: colors)));
    }
    if (bg.startsWith('#')) return Container(color: Color(int.parse('0xFF${bg.substring(1)}')));
    return Container(color: Colors.black);
  }

  void _openCreator(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => StoryCreatorOverlay(
        onClose: () => Navigator.pop(context),
        onPost: (content, mediaPath, type, bgColor) async {
          final service = ref.read(storyServiceProvider);
          bool success = false;
          if (type == 'text') {
            success = await service.createTextStory(content!, bgColor!);
          } else if (mediaPath != null) {
            final media = await service.uploadStoryMedia(File(mediaPath));
            success = await service.createMediaStory(media['url']!, media['type']!, caption: content);
          }
          if (success) {
            ref.read(storiesProvider.notifier).loadStories();
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _openViewer(BuildContext context, StoryGroup group) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => StoryViewerOverlay(
        group: group,
        onClose: () => Navigator.pop(context),
      ),
    );
  }
}
