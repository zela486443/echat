import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatTagService {
  final _client = Supabase.instance.client;

  /// Create a new category/tag for organizing chats.
  Future<String> createTag(String name, {String color = '#7C3AED'}) async {
    final userId = _client.auth.currentUser?.id;
    final res = await _client.from('chat_tags').insert({
      'user_id': userId,
      'name': name,
      'color': color,
    }).select().single();
    return res['id'];
  }

  /// Assign a tag to a specific chat.
  Future<void> assignTag(String chatId, String tagId) async {
    await _client.from('chat_tag_assignments').upsert({
      'chat_id': chatId,
      'tag_id': tagId,
    });
  }

  /// Remove a tag from a chat.
  Future<void> removeTag(String chatId, String tagId) async {
    await _client.from('chat_tag_assignments').delete().match({
      'chat_id': chatId,
      'tag_id': tagId,
    });
  }

  /// Get all tags for the current user.
  Future<List<Map<String, dynamic>>> getMyTags() async {
    final userId = _client.auth.currentUser?.id;
    final res = await _client.from('chat_tags').select('*').match({'user_id': userId});
    return List<Map<String, dynamic>>.from(res);
  }

  /// Filter chat IDs by a specific tag.
  Future<List<String>> getChatIdsByTag(String tagId) async {
    final res = await _client.from('chat_tag_assignments').select('chat_id').match({'tag_id': tagId});
    return (res as List).map((r) => r['chat_id'] as String).toList();
  }
}

final chatTagServiceProvider = Provider<ChatTagService>((ref) => ChatTagService());
