import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PerMessageTimerService {
  static final PerMessageTimerService _instance = PerMessageTimerService._internal();
  factory PerMessageTimerService() => _instance;
  PerMessageTimerService._internal();
  static const String _key = 'echat_msg_timers';

  static const List<Map<String, dynamic>> TIMER_PRESETS = [
    {'label': '5 seconds', 'ms': 5000},
    {'label': '15 seconds', 'ms': 15000},
    {'label': '30 seconds', 'ms': 30000},
    {'label': '1 minute', 'ms': 60000},
    {'label': '5 minutes', 'ms': 300000},
    {'label': '1 hour', 'ms': 3600000},
  ];

  Future<void> setMessageTimer(String messageId, int ms) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = _load(prefs);
    timers[messageId] = DateTime.now().add(Duration(milliseconds: ms)).toIso8601String();
    await prefs.setString(_key, jsonEncode(timers));
  }

  Future<String?> getMessageTimer(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = _load(prefs);
    return timers[messageId];
  }

  Future<List<String>> getExpiredMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final timers = _load(prefs);
    final now = DateTime.now();
    return timers.entries
        .where((e) => DateTime.parse(e.value).isBefore(now))
        .map((e) => e.key)
        .toList();
  }

  Future<void> clearExpiredTimers({Function(String messageId)? onExpire}) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = _load(prefs);
    final now = DateTime.now();
    final expired = <String>[];
    timers.forEach((k, v) {
      if (DateTime.parse(v).isBefore(now)) { expired.add(k); onExpire?.call(k); }
    });
    for (final id in expired) { timers.remove(id); }
    await prefs.setString(_key, jsonEncode(timers));
  }

  Future<void> removeTimer(String messageId) async {
    final prefs = await SharedPreferences.getInstance();
    final timers = _load(prefs);
    timers.remove(messageId);
    await prefs.setString(_key, jsonEncode(timers));
  }

  Map<String, String> _load(SharedPreferences prefs) {
    final data = prefs.getString(_key);
    if (data == null) return {};
    return Map<String, String>.from(jsonDecode(data));
  }

  Duration? getRemainingTime(String expiresAt) {
    final exp = DateTime.tryParse(expiresAt);
    if (exp == null) return null;
    final diff = exp.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}
