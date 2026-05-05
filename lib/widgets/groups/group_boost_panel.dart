import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class GroupBoostPanel extends StatelessWidget {
  final String groupName;
  final int currentBoosts;
  final int level;

  const GroupBoostPanel({
    super.key,
    required this.groupName,
    this.currentBoosts = 4,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Nitro Icon & Title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: Colors.pinkAccent, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Boost $groupName',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock exclusive perks for the whole group',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          // Boost Progress Card
          GlassmorphicContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Level 1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('$currentBoosts/10 Boosts', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const Text('Level 2', style: TextStyle(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: currentBoosts / 10,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Perks List
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('LEVEL 1 PERKS', style: TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 16),
          _buildPerkItem(Icons.high_quality, 'Higher Quality Audio', 'Better voice messages and calls'),
          _buildPerkItem(Icons.emoji_emotions, 'Custom Group Emojis', 'Use unique emojis in this group'),
          _buildPerkItem(Icons.folder_shared, 'Increased File Limit', 'Send files up to 2GB'),
          const SizedBox(height: 32),
          // Boost Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Boost logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt, size: 20),
                  SizedBox(width: 8),
                  Text('Boost This Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '1 Boost costs 50 Stars / month',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
