import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecretChatService {
  final _client = Supabase.instance.client;

  /// Enable secret chat for a specific room.
  /// Sets `is_secret` flag in the `rooms` or `chats` table.
  Future<void> enableSecretChat(String chatId, {bool enabled = true}) async {
    await _client
        .from('chats')
        .update({'is_secret': enabled})
        .match({'id': chatId});
  }

  /// Set the self-destruct timer for messages in a secret chat.
  /// [seconds] = 0 means disabled.
  Future<void> setSelfDestructTimer(String chatId, int seconds) async {
    await _client
        .from('chats')
        .update({'self_destruct_seconds': seconds})
        .match({'id': chatId});
  }

  /// Check if a chat is marked as secret.
  Future<bool> isSecretChat(String chatId) async {
    final res = await _client
        .from('chats')
        .select('is_secret')
        .match({'id': chatId})
        .maybeSingle();
    return res?['is_secret'] ?? false;
  }

  /// Get the current self-destruct timer for a chat.
  Future<int> getSelfDestructTimer(String chatId) async {
    final res = await _client
        .from('chats')
        .select('self_destruct_seconds')
        .match({'id': chatId})
        .maybeSingle();
    return res?['self_destruct_seconds'] ?? 0;
  }
}

final secretChatServiceProvider = Provider<SecretChatService>((ref) => SecretChatService());
