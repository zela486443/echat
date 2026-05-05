import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consolidated: adminService, privacyService, blockService, sharingPreventionService, deviceService
class GlobalControlService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> isAdmin() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    final res = await _client.from('profiles').select('is_admin').eq('id', userId).single();
    return res['is_admin'] == true;
  }

  Future<void> updatePrivacySettings(Map<String, dynamic> settings) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('privacy_settings').upsert({
      'user_id': userId,
      ...settings,
    });
  }

  Future<void> blockUser(String contactId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('blocked_users').insert({'blocker_id': userId, 'blocked_id': contactId});
  }

  Future<void> logDeviceLogin(String deviceName, String platform) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('user_devices').insert({
      'user_id': userId,
      'device_name': deviceName,
      'platform': platform,
      'last_active': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getActiveDevices() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    return await _client.from('user_devices').select().eq('user_id', userId);
  }

  Future<void> revokeDevice(String deviceId) async {
    await _client.from('user_devices').delete().eq('id', deviceId);
  }

  Future<void> toggleScreenshotPrevention(bool prevent) async {
    // In actual Flutter this would also trigger flutter_windowmanager for Android UI level block.
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('privacy_settings').upsert({'user_id': userId, 'prevent_screenshots': prevent});
  }
}

final globalControlProvider = Provider((ref) => GlobalControlService());
