import 'package:shared_preferences/shared_preferences.dart';

class SecretChatService {
  static final SecretChatService _instance = SecretChatService._internal();
  factory SecretChatService() => _instance;
  SecretChatService._internal();

  static const String _secretPrefix = 'secret_chat_';
  static const String _timerPrefix = 'self_destruct_';

  /// Self-destruct timer options
  static const List<Map<String, dynamic>> SELF_DESTRUCT_OPTIONS = [
    {'value': 0, 'label': 'Off'},
    {'value': 5, 'label': '5 seconds'},
    {'value': 15, 'label': '15 seconds'},
    {'value': 30, 'label': '30 seconds'},
    {'value': 60, 'label': '1 minute'},
    {'value': 300, 'label': '5 minutes'},
    {'value': 3600, 'label': '1 hour'},
    {'value': 86400, 'label': '1 day'},
    {'value': 604800, 'label': '1 week'},
  ];

  /// Check if a chat is a secret chat
  Future<bool> isSecretChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_secretPrefix$chatId') ?? false;
  }

  /// Enable secret chat mode
  Future<void> enableSecretChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_secretPrefix$chatId', true);
  }

  /// Disable secret chat mode
  Future<void> disableSecretChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_secretPrefix$chatId', false);
    await prefs.remove('$_timerPrefix$chatId');
  }

  /// Set self-destruct timer in seconds (0 = off)
  Future<void> setSelfDestructTimer(String chatId, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_timerPrefix$chatId', seconds);
  }

  /// Get self-destruct timer in seconds
  Future<int> getSelfDestructTimer(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_timerPrefix$chatId') ?? 0;
  }

  /// Get human-readable label for timer value
  String getSelfDestructLabel(int seconds) {
    if (seconds == 0) return 'Off';
    if (seconds < 60) return '$seconds seconds';
    if (seconds < 3600) return '${seconds ~/ 60} minute${seconds ~/ 60 > 1 ? 's' : ''}';
    if (seconds < 86400) return '${seconds ~/ 3600} hour${seconds ~/ 3600 > 1 ? 's' : ''}';
    if (seconds < 604800) return '${seconds ~/ 86400} day${seconds ~/ 86400 > 1 ? 's' : ''}';
    return '${seconds ~/ 604800} week${seconds ~/ 604800 > 1 ? 's' : ''}';
  }

  /// Toggle secret chat
  Future<bool> toggleSecretChat(String chatId) async {
    final isSecret = await isSecretChat(chatId);
    if (isSecret) {
      await disableSecretChat(chatId);
    } else {
      await enableSecretChat(chatId);
    }
    return !isSecret;
  }
}
