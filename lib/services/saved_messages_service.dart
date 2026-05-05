import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_message.dart';

class SavedMessagesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<SavedMessage>> getSavedMessages(String userId) async {
    try {
      final res = await _client
          .from('saved_messages')
          .select('*, messages(*)')
          .eq('user_id', userId)
          .order('saved_at', ascending: false);
      
      return (res as List).map((e) => SavedMessage.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching saved messages: $e');
      return [];
    }
  }

  Future<bool> saveMessage(String userId, String messageId, String chatId, {String? note}) async {
    try {
      await _client.from('saved_messages').insert({
        'user_id': userId,
        'message_id': messageId,
        'chat_id': chatId,
        'note': note,
      });
      return true;
    } catch (e) {
      print('Error saving message: $e');
      return false;
    }
  }

  Future<bool> unsaveMessage(String userId, String messageId) async {
    try {
      await _client
          .from('saved_messages')
          .delete()
          .eq('user_id', userId)
          .eq('message_id', messageId);
      return true;
    } catch (e) {
      print('Error unsaving message: $e');
      return false;
    }
  }
}
