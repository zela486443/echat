import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileMusic {
  final String? title;
  final String? artist;
  final String? url;
  final bool isPlaying;
  ProfileMusic({this.title, this.artist, this.url, this.isPlaying = false});
  factory ProfileMusic.fromJson(Map<String, dynamic> j) => ProfileMusic(
    title: j['music_title'], artist: j['music_artist'], url: j['music_url'], isPlaying: j['music_playing'] ?? false,
  );
}

class ProfileMusicService {
  static final ProfileMusicService _instance = ProfileMusicService._internal();
  factory ProfileMusicService() => _instance;
  ProfileMusicService._internal();
  final _client = Supabase.instance.client;

  Future<ProfileMusic?> getProfileMusic(String userId) async {
    try {
      final r = await _client.from('profiles').select('music_title, music_artist, music_url, music_playing').eq('id', userId).maybeSingle();
      if (r == null || r['music_title'] == null) return null;
      return ProfileMusic.fromJson(r);
    } catch (_) { return null; }
  }

  Future<void> setProfileMusic(String userId, {required String title, required String artist, String? url}) async {
    await _client.from('profiles').update({
      'music_title': title, 'music_artist': artist, 'music_url': url, 'music_playing': true,
    }).eq('id', userId);
  }

  Future<void> removeProfileMusic(String userId) async {
    await _client.from('profiles').update({
      'music_title': null, 'music_artist': null, 'music_url': null, 'music_playing': false,
    }).eq('id', userId);
  }

  Future<void> toggleProfileMusic(String userId) async {
    try {
      final r = await _client.from('profiles').select('music_playing').eq('id', userId).maybeSingle();
      final current = r?['music_playing'] ?? false;
      await _client.from('profiles').update({'music_playing': !current}).eq('id', userId);
    } catch (e) { debugPrint('Toggle music: $e'); }
  }
}
