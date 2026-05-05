import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  final _client = Supabase.instance.client;

  /// Promote a member to admin or moderator.
  Future<void> updateMemberRole(String chatId, String userId, String role) async {
    await _client.from('chat_members').update({'role': role}).match({
      'chat_id': chatId,
      'user_id': userId,
    });
    
    await _logAction(chatId, 'Promoted user $userId to $role');
  }

  /// Mute a member for a specific duration.
  Future<void> muteMember(String chatId, String userId, DateTime? until) async {
    await _client.from('chat_members').update({
      'is_muted': true,
      'muted_until': until?.toIso8601String(),
    }).match({
      'chat_id': chatId,
      'user_id': userId,
    });

    await _logAction(chatId, 'Muted user $userId until $until');
  }

  /// Ban a member from the group.
  Future<void> banMember(String chatId, String userId) async {
    await _client.from('chat_members').update({'is_banned': true}).match({
      'chat_id': chatId,
      'user_id': userId,
    });

    await _logAction(chatId, 'Banned user $userId');
  }

  /// Logs administrative actions for the group history.
  Future<void> _logAction(String chatId, String action) async {
    await _client.from('admin_logs').insert({
      'chat_id': chatId,
      'action': action,
      'admin_id': _client.auth.currentUser?.id,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get administrative permissions for the current user in a chat.
  Future<Map<String, bool>> getMyPermissions(String chatId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return {};

    final res = await _client
        .from('chat_members')
        .select('role')
        .match({'chat_id': chatId, 'user_id': userId})
        .maybeSingle();

    final role = res?['role'] ?? 'member';
    return {
      'can_delete': role == 'admin' || role == 'owner',
      'can_mute': role == 'admin' || role == 'owner' || role == 'moderator',
      'can_pin': true, // Custom logic here
      'can_invite': true,
    };
  }
}

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());
