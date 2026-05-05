import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileMusicService {
  final _client = Supabase.instance.client;

  /// Fetch profile music configuration for a user.
  Future<Map<String, dynamic>?> getProfileMusic(String userId) async {
    final res = await _client
        .from('profile_music')
        .select('*')
        .match({'user_id': userId})
        .maybeSingle();
    return res;
  }

  /// Set the track for the profile background music.
  Future<void> setProfileMusic({
    required String userId,
    required String trackName,
    required String trackUrl,
    String? artist,
  }) async {
    await _client.from('profile_music').upsert({
      'user_id': userId,
      'track_name': trackName,
      'track_url': trackUrl,
      'artist': artist,
      'is_enabled': true,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  /// Toggle profile music on/off.
  Future<void> toggleMusic(String userId, bool enabled) async {
    await _client.from('profile_music').update({
      'is_enabled': enabled,
    }).match({'user_id': userId});
  }
}

final profileMusicServiceProvider = Provider<ProfileMusicService>((ref) => ProfileMusicService());
