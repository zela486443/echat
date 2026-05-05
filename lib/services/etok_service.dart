import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/etok_video.dart';
import '../models/profile.dart';

class EtokService {
  final _client = Supabase.instance.client;

  Future<List<EtokVideo>> fetchFYPVideos() async {
    try {
      final res = await _client
          .from('etok_videos')
          .select('*, author:profiles(*)')
          .order('created_at', ascending: false)
          .limit(10);
      return (res as List).map((v) => EtokVideo.fromJson(v)).toList();
    } catch (e) {
      print('Etok fetch error: $e');
      return [];
    }
  }

  Future<List<EtokVideo>> fetchFollowingVideos(String userId) async {
    try {
      final res = await _client
          .from('etok_videos')
          .select('*, author:profiles!inner(*), follow:etok_follows!inner(*)')
          .eq('follow.follower_id', userId)
          .order('created_at', ascending: false)
          .limit(10);
      return (res as List).map((v) => EtokVideo.fromJson(v)).toList();
    } catch (e) {
      print('Etok following fetch error: $e');
      return fetchFYPVideos(); // Fallback to FYP
    }
  }

  Future<bool> toggleLike(String videoId, String userId) async {
    try {
      final existing = await _client.from('etok_likes').select().eq('video_id', videoId).eq('user_id', userId).maybeSingle();
      if (existing != null) {
        await _client.from('etok_likes').delete().eq('video_id', videoId).eq('user_id', userId);
        return false;
      } else {
        await _client.from('etok_likes').insert({'video_id': videoId, 'user_id': userId});
        return true;
      }
    } catch (e) {
      print('Like error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments(String videoId) async {
    try {
      final res = await _client
          .from('etok_comments')
          .select('*, author:profiles(*)')
          .eq('video_id', videoId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('Fetch comments error: $e');
      return [];
    }
  }

  Future<void> addComment(String videoId, String userId, String content) async {
    try {
      await _client.from('etok_comments').insert({
        'video_id': videoId,
        'user_id': userId,
        'content': content,
      });
    } catch (e) {
      print('Add comment error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchProfileStats(String userId) async {
    try {
      final likesRes = await _client.from('etok_likes').select('id').eq('video_id', userId); // Simplified for now
      final followersRes = await _client.from('etok_follows').select('id').eq('following_id', userId);
      final followingRes = await _client.from('etok_follows').select('id').eq('follower_id', userId);
      
      return {
        'likes': likesRes.length,
        'followers': followersRes.length,
        'following': followingRes.length,
      };
    } catch (e) {
      print('Stats error: $e');
      return {'likes': 0, 'followers': 0, 'following': 0};
    }
  }

  Future<List<EtokVideo>> fetchUserVideos(String userId) async {
    try {
      final res = await _client
          .from('etok_videos')
          .select('*, author:profiles(*)')
          .eq('author_id', userId)
          .order('created_at', ascending: false);
      return (res as List).map((v) => EtokVideo.fromJson(v)).toList();
    } catch (e) {
      print('User videos fetch error: $e');
      return [];
    }
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final res = await _client.from('etok_follows').select().eq('follower_id', followerId).eq('following_id', followingId).maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> followUser(String followerId, String followingId) async {
    try {
      await _client.from('etok_follows').upsert({'follower_id': followerId, 'following_id': followingId});
    } catch (e) {
      print('Follow error: $e');
    }
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await _client.from('etok_follows').delete().eq('follower_id', followerId).eq('following_id', followingId);
    } catch (e) {
      print('Unfollow error: $e');
    }
  }

  Future<List<EtokVideo>> searchVideos(String query) async {
    try {
      final res = await _client
          .from('etok_videos')
          .select('*, author:profiles(*)')
          .ilike('description', '%$query%')
          .order('created_at', ascending: false)
          .limit(20);
      return (res as List).map((v) => EtokVideo.fromJson(v)).toList();
    } catch (e) {
      print('Search videos error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> uploadVideo(File file) async {
    try {
      final fileName = 'etok_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final path = 'etok_videos/$fileName';
      
      await _client.storage.from('chat-media').upload(path, file);
      
      final url = await _client.storage.from('chat-media').createSignedUrl(path, 60 * 60 * 24 * 365); // 1 year
      
      return {'url': url, 'path': path};
    } catch (e) {
      print('Video upload error: $e');
      rethrow;
    }
  }

  Future<bool> createVideo({
    required String authorId,
    required String description,
    required String videoUrl,
    required double duration,
    String? thumbnailUrl,
    List<String> hashtags = const [],
    String privacy = 'everyone',
    bool allowComments = true,
    bool allowDuet = true,
    bool allowDownload = true,
  }) async {
    try {
      await _client.from('etok_videos').insert({
        'author_id': authorId,
        'description': description,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'duration': duration,
        'hashtags': hashtags,
        'privacy': privacy,
        'allow_comments': allowComments,
        'allow_duet': allowDuet,
        'allow_download': allowDownload,
        'sound_name': 'Original Sound',
      });
      return true;
    } catch (e) {
      print('Create video error: $e');
      return false;
    }
  }
}
