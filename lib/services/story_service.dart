import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story.dart';
import 'package:path/path.dart' as p;

class StoryService {
  final _client = Supabase.instance.client;

  Future<List<UserStory>> getActiveStories() async {
    try {
      final response = await _client
          .from('user_stories')
          .select()
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false);

      return (response as List).map((s) => UserStory.fromJson(s)).toList();
    } catch (e) {
      print('Error fetching active stories: $e');
      return [];
    }
  }

  Future<bool> createTextStory(String content, String bgColor) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client.from('user_stories').insert({
        'user_id': userId,
        'content': content,
        'story_type': 'text',
        'background_color': bgColor,
        'expires_at': DateTime.now().add(const Duration(hours: 24)).toUtc().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error creating text story: $e');
      return false;
    }
  }

  Future<bool> createMediaStory(String mediaUrl, String type, {String? caption}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client.from('user_stories').insert({
        'user_id': userId,
        'media_url': mediaUrl,
        'content': caption,
        'story_type': type, // 'image' or 'video'
        'expires_at': DateTime.now().add(const Duration(hours: 24)).toUtc().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error creating media story: $e');
      return false;
    }
  }

  Future<void> viewStory(String storyId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.from('story_views').upsert({
        'story_id': storyId,
        'viewer_id': userId,
      });
    } catch (e) {
      print('Error viewing story: $e');
    }
  }

  Future<Set<String>> getMyViewedStories() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return {};

      final response = await _client
          .from('story_views')
          .select('story_id')
          .eq('viewer_id', userId);

      return (response as List).map((v) => v['story_id'] as String).toSet();
    } catch (e) {
      print('Error fetching viewed stories: $e');
      return {};
    }
  }

  Future<bool> deleteStory(String storyId) async {
    try {
      await _client.from('user_stories').delete().eq('id', storyId);
      return true;
    } catch (e) {
      print('Error deleting story: $e');
      return false;
    }
  }

  Future<Map<String, String>> uploadStoryMedia(File file) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not authenticated');

      final extension = p.extension(file.path).replaceAll('.', '');
      final isVideo = ['mp4', 'mov', 'webm'].contains(extension.toLowerCase());
      final type = isVideo ? 'video' : 'image';
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = 'stories/$userId/$fileName';

      await _client.storage.from('chat-media').upload(filePath, file);

      // Create signed URL (48h expiry)
      final signedUrl = await _client.storage
          .from('chat-media')
          .createSignedUrl(filePath, 172800);

      return {'url': signedUrl, 'type': type};
    } catch (e) {
      print('Error uploading story media: $e');
      rethrow;
    }
  }

  Future<List<StoryViewerInfo>> getStoryViewers(String storyId) async {
    try {
      final response = await _client
          .from('story_views')
          .select('viewer_id, viewed_at')
          .eq('story_id', storyId);

      final data = response as List;
      if (data.isEmpty) return [];

      final viewerIds = data.map((v) => v['viewer_id'] as String).toList();
      
      final profilesResponse = await _client
          .from('profiles')
          .select('id, username, name, avatar_url')
          .inFilter('id', viewerIds);

      final profiles = profilesResponse as List;
      final profileMap = {for (var p in profiles) p['id']: p};

      return data.map((v) {
        final p = profileMap[v['viewer_id']];
        return StoryViewerInfo(
          viewerId: v['viewer_id'],
          viewedAt: DateTime.parse(v['viewed_at']),
          username: p?['username'],
          name: p?['name'] ?? p?['username'],
          avatarUrl: p?['avatar_url'],
        );
      }).toList();
    } catch (e) {
      print('Error fetching story viewers: $e');
      return [];
    }
  }
}
