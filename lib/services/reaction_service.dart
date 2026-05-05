import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Reaction {
  final String id;
  final String messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  Reaction({required this.id, required this.messageId, required this.userId, required this.emoji, required this.createdAt});
  factory Reaction.fromJson(Map<String, dynamic> j) => Reaction(
    id: j['id'] ?? '', messageId: j['message_id'] ?? '', userId: j['user_id'] ?? '',
    emoji: j['emoji'] ?? '', createdAt: DateTime.tryParse(j['created_at'] ?? '') ?? DateTime.now(),
  );
}

class ReactionGroup {
  final String emoji;
  final int count;
  final bool hasReacted;
  final List<String> userIds;
  ReactionGroup({required this.emoji, required this.count, required this.hasReacted, required this.userIds});
}

class ReactionService {
  static final ReactionService _instance = ReactionService._internal();
  factory ReactionService() => _instance;
  ReactionService._internal();

  final _client = Supabase.instance.client;

  Future<bool> addReaction(String messageId, String emoji, String userId) async {
    try {
      // Check if already reacted with this emoji
      final existing = await _client.from('message_reactions')
          .select('id').eq('message_id', messageId).eq('user_id', userId).eq('emoji', emoji).maybeSingle();
      if (existing != null) return false; // Already reacted

      await _client.from('message_reactions').insert({
        'message_id': messageId, 'user_id': userId, 'emoji': emoji, 'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) { debugPrint('Add reaction error: $e'); return false; }
  }

  Future<bool> removeReaction(String messageId, String emoji, String userId) async {
    try {
      await _client.from('message_reactions').delete().eq('message_id', messageId).eq('user_id', userId).eq('emoji', emoji);
      return true;
    } catch (e) { debugPrint('Remove reaction error: $e'); return false; }
  }

  Future<bool> toggleReaction(String messageId, String emoji, String userId) async {
    final existing = await _client.from('message_reactions')
        .select('id').eq('message_id', messageId).eq('user_id', userId).eq('emoji', emoji).maybeSingle();
    if (existing != null) {
      return removeReaction(messageId, emoji, userId);
    } else {
      return addReaction(messageId, emoji, userId);
    }
  }

  Future<List<Reaction>> getReactions(String messageId) async {
    try {
      final res = await _client.from('message_reactions').select().eq('message_id', messageId).order('created_at');
      return (res as List).map((e) => Reaction.fromJson(e)).toList();
    } catch (e) { debugPrint('Get reactions error: $e'); return []; }
  }

  List<ReactionGroup> groupReactions(List<Reaction> reactions, String currentUserId) {
    final map = <String, List<Reaction>>{};
    for (final r in reactions) {
      map.putIfAbsent(r.emoji, () => []).add(r);
    }
    return map.entries.map((e) => ReactionGroup(
      emoji: e.key, count: e.value.length,
      hasReacted: e.value.any((r) => r.userId == currentUserId),
      userIds: e.value.map((r) => r.userId).toList(),
    )).toList()..sort((a, b) => b.count.compareTo(a.count));
  }
}
