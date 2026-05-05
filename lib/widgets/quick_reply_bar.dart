import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/quick_reply_service.dart';
import '../theme/app_theme.dart';

class QuickReplyBar extends StatelessWidget {
  final String query;
  final Function(String) onSelect;
  final VoidCallback onClose;

  const QuickReplyBar({
    super.key,
    required this.query,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!query.startsWith('/')) return const SizedBox.shrink();
    
    final results = QuickReplyService.search(query);
    if (results.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1130),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(LucideIcons.zap, color: AppTheme.primary, size: 14),
                const SizedBox(width: 8),
                const Text('Quick Replies', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(LucideIcons.x, color: Colors.white38, size: 14),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                final reply = results[index];
                return ListTile(
                  onTap: () => onSelect(reply.text),
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(reply.shortcut, style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  ),
                  title: Text(reply.text, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
