import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupPermissions {
  final bool canSendMessages;
  final bool canAddMembers;
  final bool canChangeInfo;
  final bool canPinMessages;
  final bool canDeleteMessages;

  const GroupPermissions({this.canSendMessages = true, this.canAddMembers = true, this.canChangeInfo = false, this.canPinMessages = false, this.canDeleteMessages = false});

  factory GroupPermissions.fromJson(Map<String, dynamic> j) => GroupPermissions(
    canSendMessages: j['can_send'] ?? true, canAddMembers: j['can_add'] ?? true,
    canChangeInfo: j['can_change_info'] ?? false, canPinMessages: j['can_pin'] ?? false, canDeleteMessages: j['can_delete'] ?? false,
  );

  Map<String, dynamic> toJson() => {'can_send': canSendMessages, 'can_add': canAddMembers, 'can_change_info': canChangeInfo, 'can_pin': canPinMessages, 'can_delete': canDeleteMessages};

  GroupPermissions copyWith({bool? canSendMessages, bool? canAddMembers, bool? canChangeInfo, bool? canPinMessages, bool? canDeleteMessages}) => GroupPermissions(
    canSendMessages: canSendMessages ?? this.canSendMessages, canAddMembers: canAddMembers ?? this.canAddMembers,
    canChangeInfo: canChangeInfo ?? this.canChangeInfo, canPinMessages: canPinMessages ?? this.canPinMessages, canDeleteMessages: canDeleteMessages ?? this.canDeleteMessages,
  );
}

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();
  final _client = Supabase.instance.client;

  Future<GroupPermissions> getGroupPermissions(String groupId) async {
    try {
      final r = await _client.from('groups').select('permissions').eq('id', groupId).maybeSingle();
      if (r == null || r['permissions'] == null) return const GroupPermissions();
      return GroupPermissions.fromJson(r['permissions']);
    } catch (_) { return const GroupPermissions(); }
  }

  Future<void> setGroupPermissions(String groupId, GroupPermissions perms) async {
    await _client.from('groups').update({'permissions': perms.toJson()}).eq('id', groupId);
  }

  Future<bool> isMemberMuted(String groupId, String userId) async {
    try {
      final r = await _client.from('group_muted_members').select('id').eq('group_id', groupId).eq('user_id', userId).maybeSingle();
      return r != null;
    } catch (_) { return false; }
  }

  Future<void> muteMember(String groupId, String userId, {int? durationMinutes}) async {
    await _client.from('group_muted_members').upsert({
      'group_id': groupId, 'user_id': userId, 'muted_at': DateTime.now().toIso8601String(),
      'muted_until': durationMinutes != null ? DateTime.now().add(Duration(minutes: durationMinutes)).toIso8601String() : null,
    });
  }

  Future<void> unmuteMember(String groupId, String userId) async {
    await _client.from('group_muted_members').delete().eq('group_id', groupId).eq('user_id', userId);
  }

  Future<void> promoteMember(String groupId, String userId) async {
    await _client.from('group_members').update({'role': 'admin'}).eq('group_id', groupId).eq('user_id', userId);
  }

  Future<void> demoteMember(String groupId, String userId) async {
    await _client.from('group_members').update({'role': 'member'}).eq('group_id', groupId).eq('user_id', userId);
  }

  Future<void> logAdminAction(String groupId, String action, String adminId) async {
    try {
      await _client.from('admin_logs').insert({'group_id': groupId, 'action': action, 'admin_id': adminId, 'created_at': DateTime.now().toIso8601String()});
    } catch (e) { debugPrint('Log admin action: $e'); }
  }

  Future<List<Map<String, dynamic>>> getAdminLogs(String groupId, {int limit = 50}) async {
    try {
      return List<Map<String, dynamic>>.from(await _client.from('admin_logs').select().eq('group_id', groupId).order('created_at', ascending: false).limit(limit));
    } catch (_) { return []; }
  }

  Future<bool> isAdmin(String groupId, String userId) async {
    try {
      final r = await _client.from('group_members').select('role').eq('group_id', groupId).eq('user_id', userId).maybeSingle();
      return r?['role'] == 'admin' || r?['role'] == 'owner';
    } catch (_) { return false; }
  }
}
