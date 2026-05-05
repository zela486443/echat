import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Reminder {
  final String id;
  final String chatId;
  final String messageId;
  final String messageText;
  final DateTime remindAt;
  final bool fired;

  Reminder({required this.id, required this.chatId, required this.messageId, required this.messageText, required this.remindAt, this.fired = false});

  Map<String, dynamic> toJson() => {'id': id, 'chatId': chatId, 'messageId': messageId, 'messageText': messageText, 'remindAt': remindAt.toIso8601String(), 'fired': fired};
  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(id: j['id'], chatId: j['chatId'], messageId: j['messageId'], messageText: j['messageText'], remindAt: DateTime.parse(j['remindAt']), fired: j['fired'] ?? false);
}

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  static const String _key = 'echat_reminders';

  static const List<Map<String, dynamic>> REMINDER_PRESETS = [
    {'label': 'In 15 minutes', 'minutes': 15},
    {'label': 'In 1 hour', 'minutes': 60},
    {'label': 'In 3 hours', 'minutes': 180},
    {'label': 'Tomorrow morning', 'minutes': -1}, // handled specially
    {'label': 'Custom', 'minutes': -2},
  ];

  Future<Reminder> addReminder({required String chatId, required String messageId, required String messageText, required DateTime remindAt}) async {
    final reminders = await getReminders();
    final reminder = Reminder(id: DateTime.now().millisecondsSinceEpoch.toString(), chatId: chatId, messageId: messageId, messageText: messageText, remindAt: remindAt);
    reminders.add(reminder);
    await _save(reminders);
    return reminder;
  }

  Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Reminder.fromJson(e)).toList();
  }

  Future<List<Reminder>> getDueReminders() async {
    final all = await getReminders();
    final now = DateTime.now();
    return all.where((r) => !r.fired && r.remindAt.isBefore(now)).toList();
  }

  Future<void> removeReminder(String id) async {
    final reminders = await getReminders();
    reminders.removeWhere((r) => r.id == id);
    await _save(reminders);
  }

  Future<void> markFired(String id) async {
    final reminders = await getReminders();
    final idx = reminders.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      reminders[idx] = Reminder(id: reminders[idx].id, chatId: reminders[idx].chatId, messageId: reminders[idx].messageId, messageText: reminders[idx].messageText, remindAt: reminders[idx].remindAt, fired: true);
      await _save(reminders);
    }
  }

  Future<void> _save(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(reminders.map((r) => r.toJson()).toList()));
  }

  DateTime getTomorrowMorning() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 9, 0);
  }
}
