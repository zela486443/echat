import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsernameService {
  static final UsernameService _instance = UsernameService._internal();
  factory UsernameService() => _instance;
  UsernameService._internal();

  final _client = Supabase.instance.client;
  static const int minLength = 3;
  static const int maxLength = 32;
  static final RegExp _usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');

  String? validateUsername(String username) {
    if (username.length < minLength) return 'At least $minLength characters';
    if (username.length > maxLength) return 'At most $maxLength characters';
    if (!_usernameRegex.hasMatch(username)) return 'Letters, numbers, underscores only';
    return null;
  }

  Future<bool> isUsernameAvailable(String username) async {
    try {
      final r = await _client.from('profiles').select('id').eq('username', username.toLowerCase()).maybeSingle();
      return r == null;
    } catch (e) { return false; }
  }

  Future<({bool success, String? error})> setUsername(String userId, String username) async {
    final err = validateUsername(username);
    if (err != null) return (success: false, error: err);
    if (!await isUsernameAvailable(username)) return (success: false, error: 'Already taken');
    try {
      await _client.from('profiles').update({'username': username.toLowerCase()}).eq('id', userId);
      return (success: true, error: null);
    } catch (e) { return (success: false, error: '$e'); }
  }

  Future<String?> getUsername(String userId) async {
    try {
      final r = await _client.from('profiles').select('username').eq('id', userId).maybeSingle();
      return r?['username'];
    } catch (_) { return null; }
  }

  String generateShareLink(String username) => 'https://echat.app/@${username.toLowerCase()}';

  Future<List<Map<String, dynamic>>> searchByUsername(String query) async {
    if (query.length < 2) return [];
    try {
      return List<Map<String, dynamic>>.from(
        await _client.from('profiles').select('id, username, full_name, avatar_url').ilike('username', '%$query%').limit(20)
      );
    } catch (_) { return []; }
  }
}
