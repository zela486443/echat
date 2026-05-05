import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupPinnedMessage {
  final String messageId;
  final String content;
  final String pinnedBy;
  final DateTime pinnedAt;
  GroupPinnedMessage({required this.messageId, required this.content, required this.pinnedBy, required this.pinnedAt});
  factory GroupPinnedMessage.fromJson(Map<String, dynamic> j) => GroupPinnedMessage(
    messageId: j['message_id'] ?? '', content: j['content'] ?? '', pinnedBy: j['pinned_by'] ?? '',
    pinnedAt: DateTime.tryParse(j['pinned_at'] ?? '') ?? DateTime.now(),
  );
}

class BannedMember {
  final String userId;
  final String bannedBy;
  final String? reason;
  final DateTime bannedAt;
  BannedMember({required this.userId, required this.bannedBy, this.reason, required this.bannedAt});
  factory BannedMember.fromJson(Map<String, dynamic> j) => BannedMember(
    userId: j['user_id'] ?? '', bannedBy: j['banned_by'] ?? '', reason: j['reason'],
    bannedAt: DateTime.tryParse(j['banned_at'] ?? '') ?? DateTime.now(),
  );
}

class GroupExtService {
  static final GroupExtService _instance = GroupExtService._internal();
  factory GroupExtService() => _instance;
  GroupExtService._internal();
  final _client = Supabase.instance.client;

  // === REACTIONS ===
  Future<void> toggleGroupReaction(String groupId, String messageId, String emoji, String userId) async {
    try {
      final existing = await _client.from('group_message_reactions')
          .select('id').eq('message_id', messageId).eq('user_id', userId).eq('emoji', emoji).maybeSingle();
      if (existing != null) {
        await _client.from('group_message_reactions').delete().eq('id', existing['id']);
      } else {
        await _client.from('group_message_reactions').insert({
          'group_id': groupId, 'message_id': messageId, 'user_id': userId, 'emoji': emoji,
        });
      }
    } catch (e) { debugPrint('Toggle group reaction: $e'); }
  }

  Future<Map<String, int>> getMessageReactions(String messageId) async {
    try {
      final res = await _client.from('group_message_reactions').select('emoji').eq('message_id', messageId);
      final map = <String, int>{};
      for (final r in res) { map[r['emoji']] = (map[r['emoji']] ?? 0) + 1; }
      return map;
    } catch (_) { return {}; }
  }

  // === PINNED MESSAGES ===
  Future<GroupPinnedMessage?> getPinnedMessage(String groupId) async {
    try {
      final r = await _client.from('group_pinned_messages').select().eq('group_id', groupId).order('pinned_at', ascending: false).limit(1).maybeSingle();
      return r != null ? GroupPinnedMessage.fromJson(r) : null;
    } catch (_) { return null; }
  }

  Future<void> pinGroupMessage(String groupId, String messageId, String content, String userId) async {
    await _client.from('group_pinned_messages').upsert({
      'group_id': groupId, 'message_id': messageId, 'content': content,
      'pinned_by': userId, 'pinned_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unpinGroupMessage(String groupId) async {
    await _client.from('group_pinned_messages').delete().eq('group_id', groupId);
  }

  // === BAN MEMBERS ===
  Future<List<BannedMember>> getBannedMembers(String groupId) async {
    try {
      final res = await _client.from('group_banned_members').select().eq('group_id', groupId);
      return (res as List).map((e) => BannedMember.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  Future<void> banMember(String groupId, String userId, String bannedBy, {String? reason}) async {
    await _client.from('group_banned_members').insert({
      'group_id': groupId, 'user_id': userId, 'banned_by': bannedBy,
      'reason': reason, 'banned_at': DateTime.now().toIso8601String(),
    });
    // Also remove from group members
    await _client.from('group_members').delete().eq('group_id', groupId).eq('user_id', userId);
  }

  Future<void> unbanMember(String groupId, String userId) async {
    await _client.from('group_banned_members').delete().eq('group_id', groupId).eq('user_id', userId);
  }

  Future<bool> isBanned(String groupId, String userId) async {
    try {
      final r = await _client.from('group_banned_members').select('id').eq('group_id', groupId).eq('user_id', userId).maybeSingle();
      return r != null;
    } catch (_) { return false; }
  }

  // === INVITE LINK ===
  Future<String> generateInviteLink(String groupId) async {
    final code = '${groupId.substring(0, 8)}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    await _client.from('groups').update({'invite_code': code}).eq('id', groupId);
    return 'https://echat.app/join/$code';
  }
}
