import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupExtService {
  final _client = Supabase.instance.client;

  /// Pin a message to the top of the group.
  Future<void> pinMessage(String chatId, String messageId) async {
    await _client.from('chats').update({
      'pinned_message_id': messageId,
    }).match({'id': chatId});
  }

  /// Unpin the current pinned message.
  Future<void> unpinMessage(String chatId) async {
    await _client.from('chats').update({
      'pinned_message_id': null,
    }).match({'id': chatId});
  }

  /// Get the currently pinned message for a chat.
  Future<Map<String, dynamic>?> getPinnedMessage(String chatId) async {
    final res = await _client
        .from('chats')
        .select('pinned_message_id, messages(*)')
        .match({'id': chatId})
        .maybeSingle();
    return res?['messages'];
  }

  /// Toggle slow mode for the group.
  /// [seconds] = 0 means disabled.
  Future<void> setSlowMode(String chatId, int seconds) async {
    await _client.from('chats').update({
      'slow_mode_seconds': seconds,
    }).match({'id': chatId});
  }

  /// Get list of banned members in a group.
  Future<List<Map<String, dynamic>>> getBannedMembers(String chatId) async {
    final res = await _client
        .from('chat_members')
        .select('user_id, profiles(*)')
        .match({'chat_id': chatId, 'is_banned': true});
    return List<Map<String, dynamic>>.from(res);
  }
}

final groupExtServiceProvider = Provider<GroupExtService>((ref) => GroupExtService());
