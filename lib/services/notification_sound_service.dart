import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SoundConfig {
  final String id;
  final String name;

  SoundConfig({required this.id, required this.name});
}

final List<SoundConfig> presetSounds = [
  SoundConfig(id: 'default', name: 'Default'),
  SoundConfig(id: 'chord', name: 'Chord'),
  SoundConfig(id: 'crystal', name: 'Crystal'),
  SoundConfig(id: 'subtle', name: 'Subtle'),
  SoundConfig(id: 'reverb', name: 'Reverb'),
  SoundConfig(id: 'echats_mix', name: 'Echats Mix'),
];

class NotificationSoundService {
  static const String _defaultSoundKey = 'echat_default_sound';
  static const String _contactSoundsKey = 'echat_contact_sounds';

  Future<String> getDefaultSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultSoundKey) ?? 'default';
  }

  Future<void> setDefaultSound(String soundId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultSoundKey, soundId);
  }

  Future<Map<String, String>> getContactSounds() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_contactSoundsKey);
    if (data == null) return {};
    return Map<String, String>.from(jsonDecode(data));
  }

  Future<void> setContactSound(String userId, String soundId) async {
    final prefs = await SharedPreferences.getInstance();
    final sounds = await getContactSounds();
    sounds[userId] = soundId;
    await prefs.setString(_contactSoundsKey, jsonEncode(sounds));
  }
}

final notificationSoundProvider = Provider((ref) => NotificationSoundService());
