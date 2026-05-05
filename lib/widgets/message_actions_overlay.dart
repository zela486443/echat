import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/message.dart';

class MessageActionsOverlay extends StatelessWidget {
  final Message message;
  final bool isMe;
  final Offset messageOffset;
  final Size messageSize;
  final Function(String action, Message message)? onAction;

  const MessageActionsOverlay({
    super.key,
    required this.message,
    required this.isMe,
    required this.messageOffset,
    required this.messageSize,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background Blur
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),

          // Message Clone (positioned)
          Positioned(
            top: messageOffset.dy,
            left: isMe ? null : messageOffset.dx,
            right: isMe ? MediaQuery.of(context).size.width - (messageOffset.dx + messageSize.width) : null,
            child: Hero(
              tag: 'msg-${message.id}',
              child: _buildMockMessage(context),
            ),
          ),

          // Quick Reactions Row
          Positioned(
            top: messageOffset.dy - 60,
            left: isMe ? null : 20,
            right: isMe ? 20 : null,
            child: _buildQuickReactions(),
          ),

          // Menu Options
          Positioned(
            top: messageOffset.dy + messageSize.height + 10,
            left: isMe ? null : 20,
            right: isMe ? 20 : null,
            child: _buildMenu(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMockMessage(BuildContext context) {
    return Container(
      width: messageSize.width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primary : const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
      ),
      child: Text(message.content ?? '', style: const TextStyle(color: Colors.white, fontSize: 15)),
    );
  }

  Widget _buildQuickReactions() {
    final emojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: emojis.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(e, style: const TextStyle(fontSize: 24)),
        )).toList(),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          _buildMenuItem(Icons.reply, 'Reply', 'reply'),
          _buildMenuItem(Icons.copy, 'Copy Text', 'copy'),
          if (isMe) _buildMenuItem(Icons.edit, 'Edit', 'edit'),
          _buildMenuItem(Icons.translate, 'Translate', 'translate'),
          _buildMenuItem(Icons.forward, 'Forward', 'forward'),
          _buildMenuItem(Icons.push_pin, 'Pin', 'pin'),
          _buildMenuItem(Icons.alarm, 'Set Reminder', 'reminder'),
          _buildMenuItem(Icons.summarize, 'AI Summary', 'summarize'),
          const Divider(color: Colors.white10, height: 1),
          _buildMenuItem(Icons.delete_outline, 'Delete', 'delete', isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, String action, {bool isDestructive = false}) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white70, size: 20),
      title: Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 14)),
      onTap: () {
        onAction?.call(action, message);
      },
    );
  }
}
