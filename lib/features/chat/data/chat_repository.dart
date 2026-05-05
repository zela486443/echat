import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/chat_model.dart';
import '../../../models/message_model.dart';
import 'dart:io';

class ChatRepository {
  final SupabaseClient client;

  ChatRepository({required this.client});

  Stream<List<Chat>> watchChats(String userId) {
    return client
        .from('chats') 
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) => data.map((json) => Chat.fromJson(json)).toList());
  }

  // Real-time Supabase WebSocket mapping
  Stream<List<Message>> watchMessages(String chatId) {
    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((data) => data.map((json) => Message.fromJson(json)).toList());
  }

  // Standard Text Message
  Future<void> sendTextMessage(String chatId, String senderId, String text) async {
    await _insertMessage(chatId, senderId, text, MessageType.text);
  }

  // Voice Note Mapping (from VoiceRecorder.tsx)
  Future<void> sendVoiceNote(String chatId, String senderId, File audioFile, int durationMs) async {
    final path = await _uploadMedia(audioFile, 'voice_notes');
    await _insertMessage(chatId, senderId, 'Voice Note ($durationMs ms)', MessageType.voice, mediaUrl: path);
  }

  // Poll Mapping (from PollCreator.tsx)
  Future<void> sendPoll(String chatId, String senderId, String question, List<String> options) async {
    final payload = {
      'question': question,
      'options': options.map((o) => {'text': o, 'votes': 0}).toList(),
      'total_votes': 0,
    };
    await _insertMessage(chatId, senderId, 'Poll: $question', MessageType.poll, metadataKey: 'poll_data', metadataValue: payload);
  }

  // Bill Split Mapping (from BillSplitCreator.tsx)
  Future<void> sendBillSplit(String chatId, String senderId, String title, double totalAmount) async {
    final payload = {'title': title, 'total_amount': totalAmount, 'participants': []};
    await _insertMessage(chatId, senderId, 'Bill Split: $title', MessageType.bill_split, metadataKey: 'bill_split_data', metadataValue: payload);
  }

  Future<void> _insertMessage(
    String chatId, 
    String senderId, 
    String text, 
    MessageType type, {
    String? mediaUrl,
    String? metadataKey,
    Map<String, dynamic>? metadataValue,
  }) async {
    final data = <String, dynamic>{
      'chat_id': chatId,
      'sender_id': senderId,
      'text': text,
      'type': type.name, // ENUM serialization
    };
    if (mediaUrl != null) data['media_url'] = mediaUrl;
    if (metadataKey != null && metadataValue != null) data[metadataKey] = metadataValue;
    
    await client.from('messages').insert(data);
  }

  Future<String> _uploadMedia(File file, String bucket) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
    await client.storage.from(bucket).upload(fileName, file);
    return client.storage.from(bucket).getPublicUrl(fileName);
  }
}
