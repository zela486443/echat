import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consolidated: translationService, smartReplyService, reactionService, videoMessageService (transcription parts)
class SmartFeaturesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> translateText(String messageId, String targetLanguage) async {
    // Matches React translation RPC call
    final res = await _client.rpc('translate_message', params: {
      'p_message_id': messageId,
      'p_target_lang': targetLanguage,
    });
    return res as String;
  }

  Future<List<String>> generateSmartReplies(String latestMessageText) async {
    final res = await _client.rpc('generate_smart_replies', params: {
      'p_text': latestMessageText,
    });
    return List<String>.from(res as List);
  }

  Future<void> addReaction(String messageId, String emoji) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('message_reactions').insert({
      'message_id': messageId,
      'user_id': userId,
      'emoji': emoji,
    });
  }

  Future<void> removeReaction(String messageId, String emoji) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('message_reactions').delete()
      .eq('message_id', messageId)
      .eq('user_id', userId)
      .eq('emoji', emoji);
  }
}

final smartFeaturesProvider = Provider((ref) => SmartFeaturesService());
