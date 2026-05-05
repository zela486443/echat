import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Reminder {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? chatId;

  Reminder({required this.id, required this.title, required this.dateTime, this.chatId});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'dateTime': dateTime.toIso8601String(), 'chatId': chatId};
  factory Reminder.fromJson(Map<String, dynamic> j) => Reminder(
    id: j['id'],
    title: j['title'],
    dateTime: DateTime.parse(j['dateTime']),
    chatId: j['chatId'],
  );
}

class ReminderService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static const List<String> REMINDER_PRESETS = [
    'In 30 minutes',
    'In 1 hour',
    'Tomorrow morning',
    'Next Monday',
  ];

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  Future<void> addReminder(Reminder reminder) async {
    final scheduleTime = tz.TZDateTime.from(reminder.dateTime, tz.local);
    
    // Check if time is in future
    if (scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      reminder.id.hashCode,
      'eChats Reminder',
      reminder.title,
      scheduleTime,
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders', importance: Importance.max),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode(reminder.toJson()),
    );
  }

  Future<void> cancelReminder(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService());
