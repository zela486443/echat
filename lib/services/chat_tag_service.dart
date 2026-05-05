import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatTag {
  final String id;
  final String userId;
  final String name;
  final String color; // hex color
  ChatTag({required this.id, required this.userId, required this.name, required this.color});
  factory ChatTag.fromJson(Map<String, dynamic> j) => ChatTag(id: j['id'], userId: j['user_id'], name: j['tag_name'], color: j['color'] ?? '#7C3AED');
}

class ChatTagService {
  static final ChatTagService _instance = ChatTagService._internal();
  factory ChatTagService() => _instance;
  ChatTagService._internal();
  final _client = Supabase.instance.client;

  static const List<Map<String, String>> PRESET_TAGS = [
    {'name': 'Work', 'color': '#3B82F6'},
    {'name': 'Family', 'color': '#10B981'},
    {'name': 'Friends', 'color': '#F59E0B'},
    {'name': 'Important', 'color': '#EF4444'},
    {'name': 'School', 'color': '#8B5CF6'},
    {'name': 'Business', 'color': '#EC4899'},
  ];

  Future<ChatTag> createTag(String userId, String name, String color) async {
    final res = await _client.from('chat_tags').insert({
      'user_id': userId, 'tag_name': name, 'color': color,
    }).select().single();
    return ChatTag.fromJson(res);
  }

  Future<void> assignTagToChat(String tagId, String chatId) async {
    await _client.from('chat_tag_assignments').upsert({'tag_id': tagId, 'chat_id': chatId});
  }

  Future<void> removeTagFromChat(String tagId, String chatId) async {
    await _client.from('chat_tag_assignments').delete().eq('tag_id', tagId).eq('chat_id', chatId);
  }

  Future<List<ChatTag>> getAllTags(String userId) async {
    try {
      final res = await _client.from('chat_tags').select().eq('user_id', userId).order('tag_name');
      return (res as List).map((e) => ChatTag.fromJson(e)).toList();
    } catch (_) { return []; }
  }

  Future<List<String>> getTagsForChat(String chatId) async {
    try {
      final res = await _client.from('chat_tag_assignments').select('tag_id').eq('chat_id', chatId);
      return (res as List).map((e) => e['tag_id'] as String).toList();
    } catch (_) { return []; }
  }

  Future<List<String>> getChatsByTag(String tagId) async {
    try {
      final res = await _client.from('chat_tag_assignments').select('chat_id').eq('tag_id', tagId);
      return (res as List).map((e) => e['chat_id'] as String).toList();
    } catch (_) { return []; }
  }

  Future<void> deleteTag(String tagId) async {
    await _client.from('chat_tag_assignments').delete().eq('tag_id', tagId);
    await _client.from('chat_tags').delete().eq('id', tagId);
  }
}
