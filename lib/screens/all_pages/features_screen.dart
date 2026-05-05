import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeaturesScreen extends ConsumerWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> features = [
      {'icon': Icons.message, 'title': 'Instant Messaging', 'desc': 'Real-time 1-on-1 and group chats with reactions, replies, and pins', 'status': 'available', 'color': Colors.blue},
      {'icon': Icons.shield, 'title': 'End-to-End Encryption', 'desc': 'Messages secured with military-grade encryption', 'status': 'available', 'color': Colors.green},
      {'icon': Icons.people, 'title': 'Group Chats', 'desc': 'Groups up to 200 members with polls, slow mode, and admin tools', 'status': 'available', 'color': Colors.purple},
      {'icon': Icons.videocam, 'title': 'Voice & Video Calls', 'desc': 'HD voice and video calls with screen sharing and background blur', 'status': 'available', 'color': Colors.orange},
      {'icon': Icons.smart_toy, 'title': 'Echat AI Assistant', 'desc': 'Built-in AI assistant for smart conversations, summaries, and help', 'status': 'available', 'color': Colors.indigo},
      {'icon': Icons.account_balance_wallet, 'title': 'In-App Wallet', 'desc': 'Send money, request payments, savings goals, and QR pay', 'status': 'available', 'color': const Color(0xFF10B981)},
      {'icon': Icons.insights, 'title': 'Chat Statistics', 'desc': 'View message counts, most active hours, and streaks per chat', 'status': 'available', 'color': Colors.lightBlue},
      {'icon': Icons.star, 'title': 'Stories & Highlights', 'desc': 'Share moments and save them as profile highlights', 'status': 'beta', 'color': Colors.amber},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.05),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Row(children: [Icon(Icons.star, color: Colors.blue, size: 20), SizedBox(width: 8), Text('Echat Features', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeroCard(features.where((f) => f['status'] == 'available').length),
            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft, child: Text('ALL FEATURES', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
            const SizedBox(height: 16),
            ...features.map((f) => _buildFeatureCard(f)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(int availableCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          const Icon(Icons.star, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text('Echat', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$availableCount features fully available', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> f) {
    bool isAvailable = f['status'] == 'available';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: f['color'].withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(f['icon'], color: f['color'], size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(f['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(isAvailable ? 'Available' : 'Beta', style: TextStyle(color: isAvailable ? Colors.green : Colors.amber, fontSize: 9, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(f['desc'], style: const TextStyle(color: Colors.white38, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
