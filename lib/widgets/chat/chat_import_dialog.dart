import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

class ChatImportDialog extends StatefulWidget {
  final String chatId;
  const ChatImportDialog({super.key, required this.chatId});

  @override
  State<ChatImportDialog> createState() => _ChatImportDialogState();
}

class _ChatImportDialogState extends State<ChatImportDialog> {
  bool _isLoading = false;
  bool _isParsed = false;
  int _messageCount = 0;
  String? _error;
  List<Map<String, dynamic>> _parsedMessages = [];
  double _progress = 0;

  Future<void> _pickAndParse() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;

    setState(() { _isLoading = true; _error = null; });
    try {
      final content = await File(path).readAsString();
      final data = jsonDecode(content);
      List<Map<String, dynamic>> messages;
      if (data is List) {
        messages = List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['messages'] is List) {
        messages = List<Map<String, dynamic>>.from(data['messages']);
      } else {
        throw const FormatException('Invalid format: expected array or {messages: []}');
      }

      setState(() { _parsedMessages = messages; _messageCount = messages.length; _isParsed = true; _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Parse error: $e'; _isLoading = false; });
    }
  }

  Future<void> _importMessages() async {
    setState(() { _isLoading = true; _progress = 0; });
    try {
      final client = Supabase.instance.client;
      final batch = <Map<String, dynamic>>[];
      for (int i = 0; i < _parsedMessages.length; i++) {
        final msg = _parsedMessages[i];
        batch.add({
          'chat_id': widget.chatId,
          'sender_id': msg['sender_id'] ?? msg['from'] ?? '',
          'content': msg['content'] ?? msg['text'] ?? '',
          'message_type': msg['message_type'] ?? msg['type'] ?? 'text',
          'created_at': msg['created_at'] ?? msg['timestamp'] ?? DateTime.now().toIso8601String(),
        });
        if (batch.length >= 50 || i == _parsedMessages.length - 1) {
          await client.from('messages').insert(batch);
          batch.clear();
          setState(() => _progress = (i + 1) / _parsedMessages.length);
        }
      }
      if (mounted) { Navigator.pop(context, true); }
    } catch (e) {
      setState(() { _error = 'Import error: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1130),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Import Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isParsed && !_isLoading) ...[
            const Icon(Icons.upload_file, color: Colors.white38, size: 48),
            const SizedBox(height: 12),
            const Text('Select a JSON backup file to import messages into this chat.',
                style: TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
          ],
          if (_isParsed && !_isLoading) ...[
            Icon(Icons.check_circle, color: Colors.green.shade400, size: 48),
            const SizedBox(height: 12),
            Text('$_messageCount messages found', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Ready to import', style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
          if (_isLoading && _isParsed) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progress, backgroundColor: Colors.white10, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text('${(_progress * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
          if (_isLoading && !_isParsed)
            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
        if (!_isParsed)
          ElevatedButton(
            onPressed: _isLoading ? null : _pickAndParse,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Select File', style: TextStyle(color: Colors.white)),
          ),
        if (_isParsed)
          ElevatedButton(
            onPressed: _isLoading ? null : _importMessages,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(_isLoading ? 'Importing...' : 'Import', style: const TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
