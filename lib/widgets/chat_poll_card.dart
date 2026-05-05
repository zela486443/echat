import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatPollCard extends StatefulWidget {
  final Map<String, dynamic> pollData;
  final bool isMe;

  const ChatPollCard({super.key, required this.pollData, required this.isMe});

  @override
  State<ChatPollCard> createState() => _ChatPollCardState();
}

class _ChatPollCardState extends State<ChatPollCard> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final options = widget.pollData['options'] as List;
    final totalVotes = options.fold<int>(0, (sum, opt) => sum + (opt['votes'] as List).length);

    return Container(
      width: 280,
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
              Icon(Icons.poll_outlined, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text('POLL', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.pollData['question'] ?? 'No Question', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...options.map((opt) => _buildOption(opt, totalVotes)),
          const SizedBox(height: 12),
          Text('$totalVotes votes • ${widget.pollData['closed'] == true ? 'Closed' : 'Active'}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildOption(Map<String, dynamic> opt, int totalVotes) {
    final votes = (opt['votes'] as List).length;
    final percent = totalVotes > 0 ? (votes / totalVotes) : 0.0;
    final isSelected = _selectedOption == opt['id'];

    return GestureDetector(
      onTap: () => setState(() => _selectedOption = opt['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Stack(
          children: [
            Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 44,
              width: 248 * percent, // Assuming fixed padding width subtract
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            ),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: Text(opt['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14))),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  Text('${(percent * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
