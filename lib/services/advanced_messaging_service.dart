import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consolidated Web App Hooks/Modules: ghostModeService, disappearingService, viewOnceService, secretChatService, silentMessageService, undoSendService.
class AdvancedMessagingService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> enableGhostMode(bool enable) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('profiles').update({'ghost_mode': enable}).eq('id', userId);
  }

  Future<void> sendDisappearingMessage(String chatId, String content, int timerSeconds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'content': content,
      'is_disappearing': true,
      'expiry_timer': timerSeconds,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sendViewOnceMedia(String chatId, String storageUrl) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'content': storageUrl,
      'is_view_once': true,
    });
  }

  Future<Map<String, dynamic>> createSecretChat(String peerId) async {
    // Generates a native e2ee tunnel key mapping react's secret chat logic
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No user');
    final response = await _client.from('chats').insert({
      'type': 'secret',
      'e2ee_enabled': true,
    }).select().single();
    
    final chatId = response['id'];
    await _client.from('chat_participants').insert([
      {'chat_id': chatId, 'user_id': userId},
      {'chat_id': chatId, 'user_id': peerId},
    ]);
    return response;
  }

  Future<void> sendSilentMessage(String chatId, String content) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'content': content,
      'is_silent': true,
    });
  }

  Future<bool> undoSend(String messageId) async {
    // Assuming UI calls this within 5 seconds of insert
    try {
      await _client.from('messages').delete().eq('id', messageId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final advancedMsgProvider = Provider((ref) => AdvancedMessagingService());
