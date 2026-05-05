import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChecklistService {
  final _client = Supabase.instance.client;

  /// Create a new checklist in a chat.
  Future<String> createChecklist({
    required String chatId,
    required String title,
    required List<String> items,
  }) async {
    final res = await _client.from('checklists').insert({
      'chat_id': chatId,
      'title': title,
      'created_at': DateTime.now().toIso8601String(),
    }).select().single();

    final checklistId = res['id'];

    final itemRows = items.map((text) => {
      'checklist_id': checklistId,
      'text': text,
      'is_completed': false,
    }).toList();

    await _client.from('checklist_items').insert(itemRows);
    
    return checklistId;
  }

  /// Toggle completion status of an item.
  Future<void> toggleItem(String itemId, bool isCompleted) async {
    await _client.from('checklist_items').update({
      'is_completed': isCompleted,
    }).match({'id': itemId});
  }

  /// Fetch checklists for a chat.
  Future<List<Map<String, dynamic>>> getChecklists(String chatId) async {
    final res = await _client
        .from('checklists')
        .select('*, checklist_items(*)')
        .match({'chat_id': chatId});
    return List<Map<String, dynamic>>.from(res);
  }
}

final checklistServiceProvider = Provider<ChecklistService>((ref) => ChecklistService());
