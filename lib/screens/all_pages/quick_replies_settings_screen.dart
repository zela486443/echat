import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuickRepliesSettingsScreen extends ConsumerStatefulWidget {
  const QuickRepliesSettingsScreen({super.key});

  @override
  ConsumerState<QuickRepliesSettingsScreen> createState() => _QuickRepliesSettingsScreenState();
}

class _QuickRepliesSettingsScreenState extends ConsumerState<QuickRepliesSettingsScreen> {
  final List<Map<String, String>> _replies = [
    {'id': '1', 'shortcut': '/hi', 'text': 'Hello! How can I help you today?'},
    {'id': '2', 'shortcut': '/addr', 'text': 'Our office is located at Bole, Addis Ababa.'},
  ];

  void _showAddEditSheet({Map<String, String>? reply}) {
    final shortcutController = TextEditingController(text: reply?['shortcut'] ?? '/');
    final textController = TextEditingController(text: reply?['text'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(reply == null ? 'New Quick Reply' : 'Edit Quick Reply', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('SHORTCUT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            TextField(controller: shortcutController, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontFamily: 'monospace'), decoration: InputDecoration(hintText: '/shortcut', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            const Text('REPLY TEXT', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            TextField(controller: textController, maxLines: 3, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Your reply message...', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)), child: Text(reply == null ? 'Add Quick Reply' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Quick Replies', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          Text('Type / to use in chats', style: TextStyle(color: Colors.white38, fontSize: 11)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Color(0xFFFF0050)), onPressed: () => _showAddEditSheet()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 24),
          if (_replies.isEmpty) _buildEmptyState() else ..._replies.map((r) => _buildReplyCard(r)),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.1))),
      child: const Row(
        children: [
          Icon(LucideIcons.zap, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text('Type /shortcut in any chat to instantly insert your reply.', style: TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)), child: const Icon(LucideIcons.zap, color: Colors.white24, size: 32)),
        const SizedBox(height: 24),
        const Text('No quick replies yet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const Text('Tap + to create your first shortcut', style: TextStyle(color: Colors.white38, fontSize: 13)),
      ],
    );
  }

  Widget _buildReplyCard(Map<String, String> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.zap, color: Colors.blue, size: 18)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['shortcut']!, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14)),
              const SizedBox(height: 4),
              Text(r['text']!, style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white24, size: 18), onPressed: () => _showAddEditSheet(reply: r)),
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
