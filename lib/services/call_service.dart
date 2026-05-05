import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:async/async.dart';
import '../models/call_log.dart';

class CallService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CallLog>> fetchCallLogs(String userId) async {
    try {
      final res = await _client
          .from('call_logs')
          .select('*, caller:profiles!call_logs_caller_id_fkey(*), receiver:profiles!call_logs_receiver_id_fkey(*)')
          .or('caller_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false)
          .limit(50);
      
      return (res as List).map((e) => CallLog.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching call logs: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> subscribeToCallLogs(String userId) {
    final s1 = _client.from('call_logs').stream(primaryKey: ['id']).eq('caller_id', userId);
    final s2 = _client.from('call_logs').stream(primaryKey: ['id']).eq('receiver_id', userId);
    
    return StreamGroup.merge([s1, s2]).map((data) => data);
  }

  Future<void> logCall({
    required String callerId,
    required String receiverId,
    required String type,
    required String status,
    String? roomId,
    int? duration,
  }) async {
    try {
      await _client.from('call_logs').insert({
        'caller_id': callerId,
        'receiver_id': receiverId,
        'call_type': type,
        'status': status,
        if (roomId != null) 'room_id': roomId,
        'duration_seconds': duration,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error logging call: $e');
    }
  }

  Future<void> updateCallLogStatus(String roomId, String status, [int? duration]) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'ended_at': DateTime.now().toIso8601String(),
      };
      if (duration != null) updates['duration_seconds'] = duration;

      await _client.from('call_logs').update(updates).eq('room_id', roomId);
    } catch (e) {
      print('Error updating call log: $e');
    }
  }
}
