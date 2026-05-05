import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChecklistCard extends StatefulWidget {
  final Map<String, dynamic> checklistData;
  final bool isMe;

  const ChecklistCard({super.key, required this.checklistData, required this.isMe});

  @override
  State<ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<ChecklistCard> {
  late List<dynamic> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.checklistData['items'] ?? []);
  }

  void _toggleItem(int index) {
    setState(() {
      _items[index]['completed'] = !(_items[index]['completed'] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _items.where((i) => i['completed'] == true).length;
    final progress = _items.isEmpty ? 0.0 : completedCount / _items.length;

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.listTodo, color: Color(0xFF7C3AED), size: 18),
              const SizedBox(width: 8),
              const Expanded(child: Text('CHECKLIST', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
              Text('$completedCount/${_items.length}', style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.checklistData['title'] ?? 'Task List', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.05),
            color: const Color(0xFF7C3AED),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 16),
          ..._items.asMap().entries.map((entry) => _buildItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildItem(int index, Map<String, dynamic> item) {
    final bool isDone = item['completed'] ?? false;
    return GestureDetector(
      onTap: () => _toggleItem(index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF7C3AED) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: isDone ? Colors.transparent : Colors.white24, width: 1.5),
              ),
              child: isDone ? const Icon(LucideIcons.check, color: Colors.white, size: 12) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item['text'] ?? '',
                style: TextStyle(
                  color: isDone ? Colors.white24 : Colors.white70,
                  fontSize: 13,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
