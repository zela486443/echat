import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerMessageTimerService {
  final _client = Supabase.instance.client;

  static const List<int> TIMER_PRESETS = [5, 10, 30, 60, 300, 3600]; // seconds

  /// Set a self-destruct timer on an individual message.
  Future<void> setMessageTimer(String messageId, int seconds) async {
    final expiresAt = DateTime.now().add(Duration(seconds: seconds));
    
    await _client.from('messages').update({
      'expires_at': expiresAt.toIso8601String(),
    }).match({'id': messageId});
  }

  /// Get the remaining time for a message.
  Future<int?> getRemainingSeconds(String messageId) async {
    final res = await _client
        .from('messages')
        .select('expires_at')
        .match({'id': messageId})
        .maybeSingle();

    if (res?['expires_at'] == null) return null;
    
    final expiresAt = DateTime.parse(res!['expires_at']);
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  /// Check for expired messages and trigger local cleanup.
  Future<List<String>> getExpiredMessageIds(String chatId) async {
    final res = await _client
        .from('messages')
        .select('id')
        .match({'chat_id': chatId})
        .lt('expires_at', DateTime.now().toIso8601String());
    
    return (res as List).map((m) => m['id'] as String).toList();
  }
}

final perMessageTimerServiceProvider = Provider<PerMessageTimerService>((ref) => PerMessageTimerService());
