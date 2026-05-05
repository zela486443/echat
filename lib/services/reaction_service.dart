import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReactionService {
  final _client = Supabase.instance.client;

  /// Add or update a reaction to a message.
  Future<void> addReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    await _client.from('message_reactions').upsert({
      'message_id': messageId,
      'user_id': userId,
      'emoji': emoji,
      'created_at': DateTime.now().toIso8601String(),
    }, onConflict: 'message_id,user_id');
  }

  /// Remove a reaction.
  Future<void> removeReaction(String messageId, String userId) async {
    await _client.from('message_reactions').delete().match({
      'message_id': messageId,
      'user_id': userId,
    });
  }

  /// Fetch all reactions for a specific message.
  Future<List<Map<String, dynamic>>> getReactions(String messageId) async {
    final res = await _client
        .from('message_reactions')
        .select('emoji, user_id, profiles(username, full_name)')
        .match({'message_id': messageId});
    return List<Map<String, dynamic>>.from(res);
  }

  /// Group reactions by emoji for UI display (e.g., 👍 5, ❤️ 3).
  Map<String, int> groupReactions(List<Map<String, dynamic>> reactions) {
    final Map<String, int> counts = {};
    for (final r in reactions) {
      final emoji = r['emoji'] as String;
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    return counts;
  }
}

final reactionServiceProvider = Provider<ReactionService>((ref) => ReactionService());
