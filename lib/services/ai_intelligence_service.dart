import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIMessage {
  final String id;
  final String role;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  AIMessage({
    required this.id,
    required this.role,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory AIMessage.fromMap(Map<String, dynamic> map) {
    return AIMessage(
      id: map['id'],
      role: map['role'],
      content: map['content'] ?? '',
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class AIConversation {
  final String id;
  final String title;
  final DateTime lastMessageAt;

  AIConversation({
    required this.id,
    required this.title,
    required this.lastMessageAt,
  });

  factory AIConversation.fromMap(Map<String, dynamic> map) {
    return AIConversation(
      id: map['id'],
      title: map['title'],
      lastMessageAt: DateTime.parse(map['last_message_at']),
    );
  }
}

class AIIntelligenceService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _chatUrl => '${dotenv.env['SUPABASE_URL']}/functions/v1/ai-chat';
  String get _imageUrl => '${dotenv.env['SUPABASE_URL']}/functions/v1/ai-image';

  // --- DB Persistence ---

  Future<List<AIConversation>> loadConversations() async {
    final res = await _client
        .from('ai_conversations')
        .select('*')
        .order('last_message_at', ascending: false)
        .limit(50);
    return (res as List).map((m) => AIConversation.fromMap(m)).toList();
  }

  Future<String?> createConversation(String title) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    
    final res = await _client
        .from('ai_conversations')
        .insert({'user_id': userId, 'title': title})
        .select('id')
        .single();
    return res['id'] as String?;
  }

  Future<void> deleteConversation(String convId) async {
    await _client.from('ai_conversations').delete().eq('id', convId);
  }

  Future<List<AIMessage>> loadMessages(String convId) async {
    final res = await _client
        .from('ai_messages')
        .select('*')
        .eq('conversation_id', convId)
        .order('created_at', ascending: true);
    return (res as List).map((m) => AIMessage.fromMap(m)).toList();
  }

  Future<void> saveMessage(String convId, String role, String content, {String? imageUrl}) async {
    await _client.from('ai_messages').insert({
      'conversation_id': convId,
      'role': role,
      'content': content,
      'image_url': imageUrl,
    });
    
    // Update conversation last_message_at
    await _client.from('ai_conversations').update({
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', convId);
  }

  // --- Streaming Chat ---

  Stream<String> streamAIResponse(List<AIMessage> messages) async* {
    final apiMessages = messages.map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();

    final request = http.Request('POST', Uri.parse(_chatUrl));
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_ANON_KEY']}',
    });
    request.body = jsonEncode({'messages': apiMessages});

    final response = await http.Client().send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to connect to AI service');
    }

    final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

    await for (final line in stream) {
      if (line.isEmpty || !line.startsWith('data: ')) continue;
      final data = line.substring(6).trim();
      if (data == '[DONE]') break;

      try {
        final parsed = jsonDecode(data);
        final content = parsed['choices']?[0]?['delta']?['content'] as String?;
        if (content != null) {
          yield content;
        }
      } catch (e) {
        // Handle partial JSON or formatting errors
      }
    }
  }

  // --- Image Generation ---

  Future<Map<String, dynamic>> generateImage(String prompt) async {
    final response = await http.post(
      Uri.parse(_imageUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['SUPABASE_ANON_KEY']}',
      },
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate image');
    }

    return jsonDecode(response.body);
  }

  bool isImageRequest(String text) {
    final lower = text.toLowerCase();
    final imageKeywords = [
      'generate', 'create', 'draw', 'make', 'design', 'paint', 'sketch', 'imagine',
      'ምስል', 'ሥዕል', 'ስዕል'
    ];
    final targetKeywords = ['image', 'picture', 'photo', 'illustration', 'art', 'drawing', 'logo'];

    bool hasAction = imageKeywords.any((k) => lower.contains(k));
    bool hasTarget = targetKeywords.any((k) => lower.contains(k));

    return (hasAction && hasTarget) || lower.startsWith('draw') || lower.startsWith('paint');
  }

  // --- Legacy Bot Methods ---

  Future<List<Map<String, dynamic>>> getAvailableBots() async {
    return await _client.from('bots').select();
  }

  Future<void> addBotToGroup(String groupId, String botId) async {
    await _client.from('group_bots').insert({'group_id': groupId, 'bot_id': botId});
  }
}

final aiIntelligenceProvider = Provider((ref) => AIIntelligenceService());
