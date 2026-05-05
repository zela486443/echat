import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/etok_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/etok_service.dart';
import 'package:go_router/go_router.dart';

class EtokAnalyticsScreen extends ConsumerStatefulWidget {
  const EtokAnalyticsScreen({super.key});

  @override
  ConsumerState<EtokAnalyticsScreen> createState() => _EtokAnalyticsScreenState();
}

class _EtokAnalyticsScreenState extends ConsumerState<EtokAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _period = '7 days';
  Map<String, dynamic> _stats = {'likes': 0, 'followers': 0, 'following': 0, 'videos': 0};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;

    final service = ref.read(etokServiceProvider);
    final stats = await service.fetchProfileStats(userId);
    final videos = await service.fetchUserVideos(userId);

    if (mounted) {
      setState(() {
        _stats = {
          ...stats,
          'videos': videos.length,
          'views': videos.fold<int>(0, (prev, v) => prev + v.views),
        };
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Creator Analytics', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildContentTab(),
                _buildAudienceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, color: Colors.white54, size: 14),
              const SizedBox(width: 8),
              Text('Last $_period', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      indicatorColor: const Color(0xFFFF0050),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white38,
      tabs: const [Tab(text: 'Overview'), Tab(text: 'Content'), Tab(text: 'Audience')],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Video Views', _formatCount(_stats['views'] ?? 0), Icons.remove_red_eye, const Color(0xFFFF0050)),
              _buildStatCard('Likes', _formatCount(_stats['likes'] ?? 0), Icons.favorite, Colors.orange),
              _buildStatCard('Followers', _formatCount(_stats['followers'] ?? 0), Icons.people, Colors.cyan),
              _buildStatCard('Videos', '${_stats['videos'] ?? 0}', Icons.play_circle_filled, Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          _buildChartCard('Video Views Trend'),
          const SizedBox(height: 16),
          _buildChartCard('Follower Growth'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) => Container(width: 30, height: 20.0 + (i * 10), decoration: BoxDecoration(color: const Color(0xFFFF0050).withOpacity(0.6), borderRadius: BorderRadius.circular(4)))),
            ),
          ),
          const SizedBox(height: 8),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Text('M', style: TextStyle(color: Colors.white38, fontSize: 10)), Text('T', style: TextStyle(color: Colors.white38, fontSize: 10)), Text('W', style: TextStyle(color: Colors.white38, fontSize: 10)), Text('T', style: TextStyle(color: Colors.white38, fontSize: 10)), Text('F', style: TextStyle(color: Colors.white38, fontSize: 10)), Text('S', style: TextStyle(color: Colors.white38, fontSize: 10)), Text('S', style: TextStyle(color: Colors.white38, fontSize: 10))]),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  Widget _buildContentTab() {
    return const Center(child: Text('Content Tab', style: TextStyle(color: Colors.white38)));
  }

  Widget _buildAudienceTab() {
    return const Center(child: Text('Audience Tab', style: TextStyle(color: Colors.white38)));
  }
}
