import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';

class EtokShareSheet extends StatelessWidget {
  final String videoUrl;
  final String videoId;
  final String creatorName;

  const EtokShareSheet({
    super.key,
    required this.videoUrl,
    required this.videoId,
    required this.creatorName,
  });

  void _shareExternally() {
    Share.share('Check out this Etok video by @$creatorName: $videoUrl');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share to',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Internal Contacts Row
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5, // Mock contacts
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                        child: Text('C${index + 1}', style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 8),
                      Text('Contact ${index + 1}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10, height: 32),
          // Action Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(Icons.ios_share, 'External', _shareExternally),
                _buildActionButton(Icons.link, 'Copy Link', () {
                  // Copy link logic
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!')));
                }),
                _buildActionButton(Icons.download, 'Download', () {
                  // Download logic
                }),
                _buildActionButton(Icons.report_problem_outlined, 'Report', () {
                  // Report logic
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }
}
