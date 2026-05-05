import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistItem {
  final String id;
  final String text;
  final bool checked;
  ChecklistItem({required this.id, required this.text, this.checked = false});
  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'checked': checked};
  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(id: j['id'], text: j['text'], checked: j['checked'] ?? false);
  ChecklistItem copyWith({bool? checked}) => ChecklistItem(id: id, text: text, checked: checked ?? this.checked);
}

class Checklist {
  final String id;
  final String chatId;
  final String title;
  final List<ChecklistItem> items;
  final DateTime createdAt;
  Checklist({required this.id, required this.chatId, required this.title, required this.items, required this.createdAt});

  Map<String, dynamic> toJson() => {'id': id, 'chatId': chatId, 'title': title, 'items': items.map((e) => e.toJson()).toList(), 'createdAt': createdAt.toIso8601String()};
  factory Checklist.fromJson(Map<String, dynamic> j) => Checklist(
    id: j['id'], chatId: j['chatId'], title: j['title'],
    items: (j['items'] as List).map((e) => ChecklistItem.fromJson(e)).toList(),
    createdAt: DateTime.parse(j['createdAt']),
  );

  Checklist toggleItem(String itemId) {
    return Checklist(id: id, chatId: chatId, title: title, createdAt: createdAt,
      items: items.map((i) => i.id == itemId ? i.copyWith(checked: !i.checked) : i).toList(),
    );
  }

  int get checkedCount => items.where((i) => i.checked).length;
  String get progress => '$checkedCount/${items.length}';
}

class ChecklistService {
  static final ChecklistService _instance = ChecklistService._internal();
  factory ChecklistService() => _instance;
  ChecklistService._internal();
  static const String _key = 'echat_checklists';

  Future<Checklist> createChecklist(String chatId, String title, List<String> itemTexts) async {
    final checklist = Checklist(
      id: DateTime.now().millisecondsSinceEpoch.toString(), chatId: chatId, title: title, createdAt: DateTime.now(),
      items: itemTexts.asMap().entries.map((e) => ChecklistItem(id: '${e.key}', text: e.value)).toList(),
    );
    final all = await _loadAll();
    all.add(checklist);
    await _saveAll(all);
    return checklist;
  }

  Future<Checklist?> toggleChecklistItem(String checklistId, String itemId) async {
    final all = await _loadAll();
    final idx = all.indexWhere((c) => c.id == checklistId);
    if (idx < 0) return null;
    all[idx] = all[idx].toggleItem(itemId);
    await _saveAll(all);
    return all[idx];
  }

  Future<List<Checklist>> getChecklistsForChat(String chatId) async {
    final all = await _loadAll();
    return all.where((c) => c.chatId == chatId).toList();
  }

  Future<void> deleteChecklist(String id) async {
    final all = await _loadAll();
    all.removeWhere((c) => c.id == id);
    await _saveAll(all);
  }

  Future<List<Checklist>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => Checklist.fromJson(e)).toList();
  }

  Future<void> _saveAll(List<Checklist> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
