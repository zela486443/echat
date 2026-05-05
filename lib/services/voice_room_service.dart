import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/voice_room.dart';

class VoiceRoomService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<VoiceRoom?> getVoiceRoom(String id) async {
    try {
      final res = await _client.from('voice_rooms').select('*').eq('id', id).single();
      final participants = await _client.from('voice_participants').select('*').eq('room_id', id);
      
      final room = VoiceRoom.fromJson(res);
      return room.copyWith(participants: (participants as List).map((p) => VoiceParticipant.fromJson(p)).toList());
    } catch (e) {
      return null;
    }
  }

  Future<void> joinVoiceRoom(String roomId, String userId, String name) async {
    try {
      await _client.from('voice_participants').upsert({
        'room_id': roomId,
        'user_id': userId,
        'name': name,
        'is_muted': true,
      });
    } catch (e) {
      print('Error joining voice room: $e');
    }
  }

  Future<void> leaveVoiceRoom(String roomId, String userId) async {
    try {
      await _client.from('voice_participants').delete().eq('room_id', roomId).eq('user_id', userId);
    } catch (e) {
      print('Error leaving voice room: $e');
    }
  }

  Future<void> toggleMute(String roomId, String userId, bool isMuted) async {
    try {
      await _client.from('voice_participants').update({'is_muted': isMuted}).eq('room_id', roomId).eq('user_id', userId);
    } catch (e) {
      print('Error toggling mute: $e');
    }
  }

  Future<void> toggleHand(String roomId, String userId, bool raised) async {
    try {
      await _client.from('voice_participants').update({'is_hand_raised': raised}).eq('room_id', roomId).eq('user_id', userId);
    } catch (e) {
      print('Error toggling hand: $e');
    }
  }
}
