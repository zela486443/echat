import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsernameService {
  final _client = Supabase.instance.client;

  /// Check if a username is already taken.
  Future<bool> isUsernameAvailable(String username) async {
    if (username.length < 3) return false;
    final res = await _client
        .from('profiles')
        .select('id')
        .match({'username': username.toLowerCase()})
        .maybeSingle();
    return res == null;
  }

  /// Update the user's @username.
  Future<void> setUsername(String userId, String username) async {
    final available = await isUsernameAvailable(username);
    if (!available) throw Exception('Username already taken');

    await _client
        .from('profiles')
        .update({'username': username.toLowerCase()})
        .match({'id': userId});
  }

  /// Generates a deep link for a user's profile.
  String generateShareLink(String username) {
    return 'https://echat.chat/u/${username.toLowerCase()}';
  }

  /// Fetch userId by username.
  Future<String?> getUserIdByUsername(String username) async {
    final res = await _client
        .from('profiles')
        .select('id')
        .match({'username': username.toLowerCase()})
        .maybeSingle();
    return res?['id'];
  }
}

final usernameServiceProvider = Provider<UsernameService>((ref) => UsernameService());
