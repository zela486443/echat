import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SilentMessageService {
  static const _prefix = 'silent_mode_';

  Future<bool> isSilentMode(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$chatId') ?? false;
  }

  Future<void> setSilentMode(String chatId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$chatId', enabled);
  }

  Future<bool> toggleSilentMode(String chatId) async {
    final current = await isSilentMode(chatId);
    await setSilentMode(chatId, !current);
    return !current;
  }

  Future<List<String>> getAllSilentChats() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys()
        .where((k) => k.startsWith(_prefix) && prefs.getBool(k) == true)
        .map((k) => k.replaceFirst(_prefix, ''))
        .toList();
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) await prefs.remove(k);
  }
}

final silentMessageServiceProvider = Provider<SilentMessageService>((ref) => SilentMessageService());
