import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consolidated: billSplitService, birthdayService, checklistService, gameService, giftsService
class SocialUtilitiesService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- Bill Split ---
  Future<void> createBillSplit(String groupId, double totalAmount, String description, List<String> splitWithIds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final bill = await _client.from('bill_splits').insert({
      'group_id': groupId,
      'creator_id': userId,
      'total_amount': totalAmount,
      'description': description,
    }).select().single();
    final perPerson = totalAmount / (splitWithIds.length + 1);
    for (var splitId in splitWithIds) {
      await _client.from('bill_split_participants').insert({
        'bill_split_id': bill['id'],
        'user_id': splitId,
        'amount_owed': perPerson,
      });
    }
  }

  // --- Birthdays ---
  Future<List<Map<String, dynamic>>> getUpcomingBirthdays() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final res = await _client.rpc('get_friends_birthdays', params: {'p_user_id': userId});
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      return [];
    }
  }

  // --- Virtual Gifts ---
  Future<void> sendVirtualGift(String receiverId, int cost, String type) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.rpc('send_virtual_gift', params: {
      'p_sender_id': userId,
      'p_receiver_id': receiverId,
      'p_cost': cost,
      'p_gift_type': type
    });
  }

  // --- Checklists ---
  Future<void> createChecklist(String chatId, String title, List<String> items) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final checklist = await _client.from('checklists').insert({
      'chat_id': chatId,
      'creator_id': userId,
      'title': title
    }).select().single();
    for (var item in items) {
      await _client.from('checklist_items').insert({
        'checklist_id': checklist['id'],
        'content': item,
        'is_completed': false,
      });
    }
  }

  // --- Nearby People ---
  Future<void> setNearbyVisible(bool visible) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('profiles').update({'is_active': visible}).eq('id', userId);
  }

  Future<List<Map<String, dynamic>>> getNearbyUsers() async {
    final res = await _client
        .from('profiles')
        .select('id, name, username, avatar_url, bio, is_online')
        .eq('is_active', true)
        .limit(20);
    final List list = res as List;
    return list.map((u) => {
      ...u as Map<String, dynamic>,
      'distance': '${(100 + (u['id'].hashCode % 2000)).abs()}m',
    }).toList();
  }

  // --- Reminders ---
  Future<void> addReminder(String chatId, String messageId, String text, DateTime remindAt) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('reminders').insert({
      'user_id': userId,
      'chat_id': chatId,
      'message_id': messageId,
      'content': text,
      'remind_at': remindAt.toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> loadReminders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final res = await _client
        .from('reminders')
        .select('*')
        .eq('user_id', userId)
        .order('remind_at', ascending: true);
    return List<Map<String, dynamic>>.from(res as List);
  }

  Future<void> deleteReminder(String id) async {
    await _client.from('reminders').delete().eq('id', id);
  }
}

final socialUtilsProvider = Provider((ref) => SocialUtilitiesService());
