import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  static final DraftService _instance = DraftService._internal();
  factory DraftService() => _instance;
  DraftService._internal();

  static const String _prefix = 'draft_';

  Future<void> saveDraft(String chatId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    if (text.trim().isEmpty) {
      await prefs.remove('$_prefix$chatId');
    } else {
      await prefs.setString('$_prefix$chatId', text);
    }
  }

  Future<String?> getDraft(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$chatId');
  }

  Future<void> clearDraft(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$chatId');
  }
}
