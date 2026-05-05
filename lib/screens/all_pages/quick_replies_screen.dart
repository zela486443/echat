import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class QuickRepliesScreen extends ConsumerStatefulWidget {
  const QuickRepliesScreen({super.key});

  @override
  ConsumerState<QuickRepliesScreen> createState() => _QuickRepliesScreenState();
}

class _QuickRepliesScreenState extends ConsumerState<QuickRepliesScreen> {
  final List<Map<String, String>> _replies = [
    {'id': '1', 'shortcut': '/hi', 'text': 'Hello! How can I help you today?'},
    {'id': '2', 'shortcut': '/thx', 'text': 'Thank you so much for your help!'},
    {'id': '3', 'shortcut': '/busy', 'text': 'I am currently busy, will get back to you soon.'},
  ];

  void _showAddSheet([Map<String, String>? editingReply]) {
    final shortcutController = TextEditingController(text: editingReply?['shortcut'] ?? '/');
    final textController = TextEditingController(text: editingReply?['text'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Color(0xFF151122), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Text(editingReply == null ? 'New Quick Reply' : 'Edit Quick Reply', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('SHORTCUT', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: TextField(
                  controller: shortcutController,
                  style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: '/shortcut'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('REPLY TEXT', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Your reply message...'),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () => context.pop(),
                  child: Text(editingReply == null ? 'Add Quick Reply' : 'Save Changes', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 24),
                  _buildReplyList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: const Text('Quick Replies', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      actions: [
        IconButton(icon: const Icon(LucideIcons.plus, color: Color(0xFF7C3AED), size: 24), onPressed: () => _showAddSheet()),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2))),
      child: const Row(
        children: [
          Icon(LucideIcons.zap, color: Color(0xFF7C3AED), size: 20),
          SizedBox(width: 16),
          Expanded(child: Text('Type /shortcut in any chat to instantly insert your reply.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }

  Widget _buildReplyList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _replies.length,
      itemBuilder: (context, index) {
        final reply = _replies[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.zap, color: Color(0xFF7C3AED), size: 20)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reply['shortcut']!, style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    Text(reply['text']!, style: const TextStyle(color: Colors.white38, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildActionButton(LucideIcons.pencil, () => _showAddSheet(reply)),
              const SizedBox(width: 8),
              _buildActionButton(LucideIcons.trash2, () {}, isDestructive: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: isDestructive ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white24, size: 16),
      ),
    );
  }
}
