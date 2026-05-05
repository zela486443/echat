import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationPriority { low, normal, high, urgent }

class SmartNotification {
  final String id;
  final String title;
  final String body;
  final NotificationPriority priority;
  final DateTime timestamp;

  SmartNotification({
    required this.id,
    required this.title,
    required this.body,
    this.priority = NotificationPriority.normal,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SmartNotificationService extends StateNotifier<List<SmartNotification>> {
  SmartNotificationService() : super([]);

  void addNotification(SmartNotification notification) {
    // Logic to prioritize or filter notifications
    // e.g., If priority is urgent, move to top and show a special banner
    state = [notification, ...state];
    
    // Auto-prune old notifications (keep last 50)
    if (state.length > 50) {
      state = state.sublist(0, 50);
    }
  }

  void clearAll() {
    state = [];
  }

  List<SmartNotification> get urgentNotifications => 
      state.where((n) => n.priority == NotificationPriority.urgent).toList();
}

final smartNotificationProvider = StateNotifierProvider<SmartNotificationService, List<SmartNotification>>((ref) {
  return SmartNotificationService();
});
