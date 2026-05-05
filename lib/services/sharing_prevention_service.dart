import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharingSettings {
  final bool forwardingPrevented;
  final bool screenshotPrevented;
  final bool copyPrevented;

  const SharingSettings({
    this.forwardingPrevented = false,
    this.screenshotPrevented = false,
    this.copyPrevented = false,
  });

  Map<String, dynamic> toJson() => {
    'forwardingPrevented': forwardingPrevented,
    'screenshotPrevented': screenshotPrevented,
    'copyPrevented': copyPrevented,
  };

  factory SharingSettings.fromJson(Map<String, dynamic> j) => SharingSettings(
    forwardingPrevented: j['forwardingPrevented'] ?? false,
    screenshotPrevented: j['screenshotPrevented'] ?? false,
    copyPrevented: j['copyPrevented'] ?? false,
  );

  SharingSettings copyWith({bool? forwardingPrevented, bool? screenshotPrevented, bool? copyPrevented}) =>
      SharingSettings(
        forwardingPrevented: forwardingPrevented ?? this.forwardingPrevented,
        screenshotPrevented: screenshotPrevented ?? this.screenshotPrevented,
        copyPrevented: copyPrevented ?? this.copyPrevented,
      );
}

class SharingPreventionService {
  static const _prefix = 'sharing_settings_';

  Future<SharingSettings> getSharingSettings(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$chatId');
    if (raw == null) return const SharingSettings();
    return SharingSettings.fromJson(jsonDecode(raw));
  }

  Future<void> saveSharingSettings(String chatId, SharingSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$chatId', jsonEncode(settings.toJson()));
  }

  Future<bool> isForwardingPrevented(String chatId) async =>
      (await getSharingSettings(chatId)).forwardingPrevented;

  Future<bool> isScreenshotPrevented(String chatId) async =>
      (await getSharingSettings(chatId)).screenshotPrevented;

  Future<bool> isCopyPrevented(String chatId) async =>
      (await getSharingSettings(chatId)).copyPrevented;

  Future<void> setForwardingPrevented(String chatId, bool value) async {
    final s = await getSharingSettings(chatId);
    await saveSharingSettings(chatId, s.copyWith(forwardingPrevented: value));
  }

  Future<void> setScreenshotPrevented(String chatId, bool value) async {
    final s = await getSharingSettings(chatId);
    await saveSharingSettings(chatId, s.copyWith(screenshotPrevented: value));
  }

  Future<void> setCopyPrevented(String chatId, bool value) async {
    final s = await getSharingSettings(chatId);
    await saveSharingSettings(chatId, s.copyWith(copyPrevented: value));
  }
}

final sharingPreventionServiceProvider = Provider<SharingPreventionService>((ref) => SharingPreventionService());
