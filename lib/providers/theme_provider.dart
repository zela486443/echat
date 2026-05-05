import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccentColor {
  final String id;
  final String name;
  final Color color;

  AccentColor({required this.id, required this.name, required this.color});
}

final List<AccentColor> availableAccents = [
  AccentColor(id: 'pink',   name: 'Fruity Pink',    color: const Color(0xFFF76EA8)), // 338 85% 70%
  AccentColor(id: 'blue',   name: 'Ocean Blue',     color: const Color(0xFF3B82F6)), // 210 90% 60%
  AccentColor(id: 'green',  name: 'Forest Green',   color: const Color(0xFF10B981)), // 145 65% 45%
  AccentColor(id: 'purple', name: 'Royal Purple',   color: const Color(0xFF8B5CF6)), // 260 80% 60%
  AccentColor(id: 'orange', name: 'Sunset Orange',  color: const Color(0xFFF97316)), // 25 90% 55%
  AccentColor(id: 'cyan',   name: 'Neon Cyan',      color: const Color(0xFF06B6D4)), // 180 80% 50%
  AccentColor(id: 'red',    name: 'Cherry Red',     color: const Color(0xFFEF4444)), // 0 75% 55%
  AccentColor(id: 'gold',   name: 'Golden',         color: const Color(0xFFF59E0B)), // 45 90% 55%
];

class AppThemeNotifier extends StateNotifier<AccentColor> {
  AppThemeNotifier() : super(availableAccents[0]) {
    _load();
  }

  static const _key = 'echat_accent_id';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_key);
    if (id != null) {
      final color = availableAccents.firstWhere((c) => c.id == id, orElse: () => availableAccents[0]);
      state = color;
    }
  }

  Future<void> setAccent(AccentColor color) async {
    state = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, color.id);
  }
}

final themeProvider = StateNotifierProvider<AppThemeNotifier, AccentColor>((ref) => AppThemeNotifier());
