import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/social_utilities_service.dart';

class BackgroundServicesNotifier extends StateNotifier<void> {
  final Ref ref;
  Timer? _presenceTimer;
  Timer? _reminderTimer;
  Timer? _birthdayTimer;
  
  final _client = Supabase.instance.client;

  BackgroundServicesNotifier(this.ref) : super(null) {
    _init();
  }

  void _init() {
    _client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _startAll();
      } else if (event == AuthChangeEvent.signedOut) {
        _stopAll();
      }
    });

    // If already logged in
    if (_client.auth.currentUser != null) {
      _startAll();
    }
  }

  void _startAll() {
    _stopAll();
    _startPresenceHeartbeat();
    _startReminderChecker();
    _startBirthdayChecker();
    _showWelcomeToast();
  }

  void _stopAll() {
    _presenceTimer?.cancel();
    _reminderTimer?.cancel();
    _birthdayTimer?.cancel();
  }

  void _startPresenceHeartbeat() {
    // Every 30 seconds update last_seen
    _presenceTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      
      await _client.from('profiles').update({
        'last_seen': DateTime.now().toIso8601String(),
        'is_online': true,
      }).eq('id', userId);
    });
  }

  void _startReminderChecker() {
    // Check every 1 minute
    _reminderTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final service = ref.read(socialUtilsProvider);
      final all = await service.loadReminders();
      final now = DateTime.now();

      for (var r in all) {
        final remindAt = DateTime.parse(r['remind_at']);
        if (remindAt.isBefore(now)) {
          _notify('Reminder: ${r['content']}', color: Colors.blue);
          await service.deleteReminder(r['id']);
        }
      }
    });
  }

  void _startBirthdayChecker() {
    // Check every 6 hours
    _birthdayTimer = Timer.periodic(const Duration(hours: 6), (_) async {
      final birthdays = await ref.read(socialUtilsProvider).getUpcomingBirthdays();
      final today = DateTime.now();
      
      for (var b in birthdays) {
        final bday = DateTime.parse(b['birthday']);
        if (bday.month == today.month && bday.day == today.day) {
          _notify('Today is ${b['name']}\'s Birthday! 🎂', color: Colors.pinkAccent);
        }
      }
    });
  }

  void _showWelcomeToast() {
    final name = _client.auth.currentUser?.userMetadata?['name'] ?? 'User';
    _notify('Welcome back, $name! 👋');
  }

  void _notify(String message, {Color color = const Color(0xFF10B981)}) {
    // We use a global state or event bus to show notifications.
    // For now, we'll use a simple print or a dedicated provider for UI to listen to.
    ref.read(backgroundNotificationProvider.notifier).show(message, color);
  }

  @override
  void dispose() {
    _stopAll();
    super.dispose();
  }
}

// UI notification state
class BackgroundNotification {
  final String message;
  final Color color;
  final DateTime timestamp;

  BackgroundNotification(this.message, this.color, this.timestamp);
}

class NotificationNotifier extends StateNotifier<BackgroundNotification?> {
  NotificationNotifier() : super(null);

  void show(String message, Color color) {
    state = BackgroundNotification(message, color, DateTime.now());
  }

  void clear() {
    state = null;
  }
}

final backgroundNotificationProvider = StateNotifierProvider<NotificationNotifier, BackgroundNotification?>((ref) => NotificationNotifier());
final backgroundServicesProvider = StateNotifierProvider<BackgroundServicesNotifier, void>((ref) => BackgroundServicesNotifier(ref));
