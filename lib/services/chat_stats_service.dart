import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatStats {
  final int totalMessages;
  final int yourMessages;
  final int theirMessages;
  final int mediaCount;
  final int voiceCount;
  final int avgWordsPerMessage;
  final int mostActiveHour;
  final DateTime? firstMessageDate;

  ChatStats({
    required this.totalMessages,
    required this.yourMessages,
    required this.theirMessages,
    required this.mediaCount,
    required this.voiceCount,
    required this.avgWordsPerMessage,
    required this.mostActiveHour,
    this.firstMessageDate,
  });

  factory ChatStats.empty() => ChatStats(
    totalMessages: 0,
    yourMessages: 0,
    theirMessages: 0,
    mediaCount: 0,
    voiceCount: 0,
    avgWordsPerMessage: 0,
    mostActiveHour: 12,
  );
}

class ChatStatsService {
  final _client = Supabase.instance.client;

  Future<ChatStats> computeStats(String chatId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return ChatStats.empty();

    final res = await _client
        .from('messages')
        .select('content, message_type, created_at, sender_id')
        .eq('chat_id', chatId);
    
    final List messages = res as List;
    if (messages.isEmpty) return ChatStats.empty();

    final hourCounts = List.filled(24, 0);
    int totalWords = 0;
    int textCount = 0;
    int yourMessages = 0;
    int theirMessages = 0;
    int mediaCount = 0;
    int voiceCount = 0;

    for (var m in messages) {
      final isOwn = m['sender_id'] == userId;
      if (isOwn) yourMessages++; else theirMessages++;
      
      final type = m['message_type'];
      if (['image', 'file', 'video'].contains(type)) mediaCount++;
      if (type == 'voice') voiceCount++;
      
      final content = m['content'] as String?;
      if (type == 'text' && content != null) {
        totalWords += content.trim().split(RegExp(r'\s+')).length;
        textCount++;
      }

      if (m['created_at'] != null) {
        final h = DateTime.parse(m['created_at']).toLocal().hour;
        hourCounts[h]++;
      }
    }

    int maxHourValue = -1;
    int mostActiveHour = 12;
    for (int i = 0; i < 24; i++) {
      if (hourCounts[i] > maxHourValue) {
        maxHourValue = hourCounts[i];
        mostActiveHour = i;
      }
    }

    final firstDateStr = messages.last['created_at'] as String?;

    return ChatStats(
      totalMessages: messages.length,
      yourMessages: yourMessages,
      theirMessages: theirMessages,
      mediaCount: mediaCount,
      voiceCount: voiceCount,
      avgWordsPerMessage: textCount > 0 ? (totalWords / textCount).round() : 0,
      mostActiveHour: mostActiveHour,
      firstMessageDate: firstDateStr != null ? DateTime.parse(firstDateStr) : null,
    );
  }
}

final chatStatsProvider = Provider((ref) => ChatStatsService());
