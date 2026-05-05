import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/story_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/story.dart';
import 'chat_avatar.dart';
import 'stories/story_creator_overlay.dart';
import 'stories/story_viewer_overlay.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoriesBar extends ConsumerWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);
    final userId = ref.watch(authProvider).value?.id;

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: storiesAsync.when(
        data: (groups) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length + 2, // My Story + Groups + See All
            itemBuilder: (context, index) {
              if (index == 0) {
                final myGroup = groups.firstWhere((g) => g.userId == userId, orElse: () => StoryGroup(userId: userId ?? '', name: 'Your Story', stories: [], hasUnviewed: false));
                return _buildMyStory(context, ref, myGroup);
              }
              if (index == groups.length + 1) {
                return _buildSeeAll(context);
              }
              
              // Skip my group in the main list as it's at index 0
              final group = groups[index - 1];
              if (group.userId == userId) return const SizedBox.shrink();
              
              return _buildStoryCircle(context, group, index - 1);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => const Center(child: Icon(LucideIcons.alertCircle, color: Colors.white24)),
      ),
    );
  }

  Widget _buildMyStory(BuildContext context, WidgetRef ref, StoryGroup group) {
    return GestureDetector(
      onTap: () => _openCreator(context, ref),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: group.stories.isNotEmpty 
                      ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)])
                      : null,
                    border: group.stories.isEmpty ? Border.all(color: Colors.white10, width: 1) : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: ChatAvatar(name: group.name, src: group.avatarUrl, size: 'md'),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)]),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(LucideIcons.plus, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('My Story', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ).animate().scale(delay: 50.ms, duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildStoryCircle(BuildContext context, StoryGroup group, int index) {
    return GestureDetector(
      onTap: () => _openViewer(context, group),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: group.hasUnviewed
                    ? const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEC4899), Color(0xFFF97316)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                border: !group.hasUnviewed ? Border.all(color: Colors.white10, width: 1) : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: ChatAvatar(name: group.name, src: group.avatarUrl, size: 'md'),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(
                group.name.split(' ')[0],
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: (index * 50).ms, duration: 300.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSeeAll(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(LucideIcons.chevronRight, color: Colors.white54),
          ),
          const SizedBox(height: 6),
          const Text('See All', style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  void _openCreator(BuildContext context, WidgetRef ref) {
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
