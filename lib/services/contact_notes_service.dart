import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContactNote {
  final String contactId;
  final String note;
  final DateTime updatedAt;

  ContactNote({
    required this.contactId,
    required this.note,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'contactId': contactId,
    'note': note,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ContactNote.fromJson(Map<String, dynamic> json) => ContactNote(
    contactId: json['contactId'],
    note: json['note'],
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class ContactNotesService {
  static const String _key = 'echat_contact_notes';

  Future<String> getNote(String contactId) async {
    final notes = await _load();
    final note = notes.where((n) => n.contactId == contactId).toList();
    return note.isNotEmpty ? note.first.note : '';
  }

  Future<void> saveNote(String contactId, String note) async {
    final notes = await _load();
    notes.removeWhere((n) => n.contactId == contactId);
    if (note.trim().isNotEmpty) {
      notes.add(ContactNote(
        contactId: contactId,
        note: note.trim(),
        updatedAt: DateTime.now(),
      ));
    }
    await _save(notes);
  }

  Future<List<ContactNote>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => ContactNote.fromJson(e)).toList();
  }

  Future<void> _save(List<ContactNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(notes.map((e) => e.toJson()).toList()));
  }
}
