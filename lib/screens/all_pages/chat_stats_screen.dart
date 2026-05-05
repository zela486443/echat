import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/chat_stats_service.dart';
import '../../widgets/aurora_gradient_bg.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../theme/app_theme.dart';

class ChatStatsScreen extends ConsumerStatefulWidget {
  final String? chatId;
  const ChatStatsScreen({super.key, this.chatId});

  @override
  ConsumerState<ChatStatsScreen> createState() => _ChatStatsScreenState();
}

class _ChatStatsScreenState extends ConsumerState<ChatStatsScreen> {
  ChatStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (widget.chatId == null) return;
    setState(() => _isLoading = true);
    final stats = await ref.read(chatStatsProvider).computeStats(widget.chatId!);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Chat Statistics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: AuroraGradientBg(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _stats == null 
            ? const Center(child: Text('No data available', style: TextStyle(color: Colors.white38)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildOverviewCard(),
                    const SizedBox(height: 20),
                    _buildGridStats(),
                    const SizedBox(height: 20),
                    _buildTimeCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return GlassmorphicContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Total Messages', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 8),
          Text('${_stats!.totalMessages}', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatMini('You', _stats!.yourMessages, Colors.blue),
              Container(width: 1, height: 30, color: Colors.white10),
              _buildStatMini('Them', _stats!.theirMessages, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMini(String label, int val, Color color) {
    final percent = _stats!.totalMessages > 0 ? (val / _stats!.totalMessages * 100).round() : 0;
    return Expanded(
      child: Column(
        children: [
          Text('$val', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('$label ($percent%)', style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGridStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildGridItem(Icons.image, 'Media', '${_stats!.mediaCount}'),
        _buildGridItem(Icons.mic, 'Voice', '${_stats!.voiceCount}'),
        _buildGridItem(Icons.text_format, 'Avg Words', '${_stats!.avgWordsPerMessage}'),
        _buildGridItem(Icons.calendar_today, 'Since', _stats!.firstMessageDate != null ? DateFormat('MMM yyyy').format(_stats!.firstMessageDate!) : 'N/A'),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String label, String val) {
    return GlassmorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    final hour = _stats!.mostActiveHour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return GlassmorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.access_time, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Most Active Time', style: TextStyle(color: Colors.white54, fontSize: 13)),
                Text('$displayHour:00 $ampm', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
