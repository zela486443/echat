import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/group.dart';
import '../models/group_message.dart';

class GroupService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Group?> createGroup({
    required String name,
    required String createdBy,
    String? description,
    bool isChannel = false,
  }) async {
    try {
      final data = await _client.from('groups').insert({
        'name': name,
        'description': description,
        'created_by': createdBy,
        'is_channel': isChannel,
      }).select().single();

      // Automatically add creator as admin
      await _client.from('group_members').insert({
        'group_id': data['id'],
        'user_id': createdBy,
        'role': 'admin',
      });

      return Group.fromJson(data);
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }

  Future<List<Group>> getUserGroups(String userId) async {
    try {
      final membersData = await _client
          .from('group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = (membersData as List<dynamic>)
          .map((m) => m['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) return [];

      final data = await _client
          .from('groups')
          .select()
          .inFilter('id', groupIds)
          .order('updated_at', ascending: false);

      return (data as List<dynamic>).map((e) => Group.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching user groups: $e');
      return [];
    }
  }

  Future<Group?> getGroup(String groupId) async {
    try {
      final data = await _client.from('groups').select().eq('id', groupId).maybeSingle();
      if (data == null) return null;
      return Group.fromJson(data);
    } catch (e) {
      print('Error fetching group: $e');
      return null;
    }
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    try {
      final data = await _client
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .order('joined_at', ascending: true);
      
      return (data as List<dynamic>).map((e) => GroupMember.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching group members: $e');
      return [];
    }
  }

  Future<List<GroupMessage>> getGroupMessages(String groupId) async {
    try {
      final data = await _client
          .from('group_messages')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: true);
      
      return (data as List<dynamic>).map((e) => GroupMessage.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching group messages: $e');
      return [];
    }
  }

  Future<GroupMessage?> sendGroupMessage(String groupId, String content) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await _client.from('group_messages').insert({
        'group_id': groupId,
        'sender_id': userId,
        'content': content,
        'message_type': 'text',
      }).select().single();

      // Update group updated_at
      await _client.from('groups').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', groupId);

      return GroupMessage.fromJson(data);
    } catch (e) {
      print('Error sending group message: $e');
      return null;
    }
  }

  Future<bool> isGroupAdmin(String groupId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final data = await _client
          .from('group_members')
          .select('role')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return false;
      return data['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeGroupMember(String groupId, String userId) async {
    try {
      await _client
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  RealtimeChannel subscribeToGroupMessages(String groupId, Function(GroupMessage) onMessage) {
    return _client
        .channel('group-messages-$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'group_id', value: groupId),
          callback: (payload) {
            onMessage(GroupMessage.fromJson(payload.newRecord));
          },
        )
        .subscribe();
  }

  void unsubscribeFromGroupMessages(RealtimeChannel channel) {
    _client.removeChannel(channel);
  }
}
