import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story.dart';
import '../services/story_service.dart';
import '../providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final storyServiceProvider = Provider((ref) => StoryService());

final storiesProvider = StateNotifierProvider<StoriesNotifier, AsyncValue<List<StoryGroup>>>((ref) {
  return StoriesNotifier(ref.watch(storyServiceProvider), ref);
});

class StoriesNotifier extends StateNotifier<AsyncValue<List<StoryGroup>>> {
  final StoryService _service;
  final Ref _ref;
  final _client = Supabase.instance.client;

  StoriesNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    loadStories();
  }

  Future<void> loadStories() async {
    state = const AsyncValue.loading();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final stories = await _service.getActiveStories();
      final viewed = await _service.getMyViewedStories();

      final Map<String, List<UserStory>> grouped = {};
      for (final s in stories) {
        grouped.putIfAbsent(s.userId, () => []).add(s);
      }

      final userIds = grouped.keys.toList();
      final List<StoryGroup> allGroups = [];

      if (userIds.isNotEmpty) {
        final profilesResponse = await _client
            .from('profiles')
            .select('id, username, name, avatar_url')
            .inFilter('id', userIds);

        final profiles = profilesResponse as List;
        final profileMap = {for (var p in profiles) p['id']: p};

        // Handle my story first
        if (grouped.containsKey(userId)) {
          final ownStories = grouped[userId]!;
          final p = profileMap[userId];
          allGroups.add(StoryGroup(
            userId: userId,
            name: 'Your Story',
            avatarUrl: p?['avatar_url'],
            stories: ownStories,
            hasUnviewed: ownStories.any((s) => !viewed.contains(s.id)),
          ));
        }

        // Handle others
        for (final entry in grouped.entries) {
          if (entry.key == userId) continue;
          final p = profileMap[entry.key];
          allGroups.add(StoryGroup(
            userId: entry.key,
            name: p?['name'] ?? p?['username'] ?? 'User',
            avatarUrl: p?['avatar_url'],
            stories: entry.value,
            hasUnviewed: entry.value.any((s) => !viewed.contains(s.id)),
          ));
        }
      }

      state = AsyncValue.data(allGroups);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsViewed(String storyId) async {
    await _service.viewStory(storyId);
    // Optionally refresh or update local state
  }
}
