import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/etok_analytics_provider.dart';

class EtokAnalyticsScreen extends ConsumerStatefulWidget {
  const EtokAnalyticsScreen({super.key});

  @override
  ConsumerState<EtokAnalyticsScreen> createState() => _EtokAnalyticsScreenState();
}

class _EtokAnalyticsScreenState extends ConsumerState<EtokAnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Content', 'Audience'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Creator Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF0050),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildContentTab(),
          _buildAudienceTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard('Video Views', '24.5K', LucideIcons.eye, const Color(0xFFFF0050)),
            _buildStatCard('Likes', '12.2K', LucideIcons.heart, Colors.orange),
            _buildStatCard('Followers', '1.2K', LucideIcons.users, Colors.blue),
            _buildStatCard('Shares', '840', LucideIcons.share2, Colors.green),
          ],
        ),
        const SizedBox(height: 24),
        _buildChartCard('Video Views (Last 7 days)', _buildLineChart()),
        const SizedBox(height: 16),
        _buildChartCard('Follower Growth', _buildBarChart()),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 20),
          SizedBox(height: 150, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [const FlSpot(0, 3), const FlSpot(1, 1), const FlSpot(2, 4), const FlSpot(3, 2), const FlSpot(4, 5)],
            isCurved: true,
            color: const Color(0xFFFF0050),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFFFF0050).withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 12)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.blue, width: 12)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: Colors.blue, width: 12)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: Colors.blue, width: 12)]),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    final videosAsync = ref.watch(creatorVideosProvider);

    return videosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF0050))),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (videos) {
        if (videos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.videoOff, color: Colors.white24, size: 48),
                const SizedBox(height: 16),
                const Text('No videos yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: videos.length,
          itemBuilder: (context, i) {
            final v = videos[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(image: NetworkImage(v.thumbnailUrl), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(v.createdAt.toIso8601String().split('T')[0], style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _miniStat(LucideIcons.eye, '${v.viewCount}'),
                            const SizedBox(width: 12),
                            _miniStat(LucideIcons.heart, '${v.likesCount}'),
                            const SizedBox(width: 12),
                            _miniStat(LucideIcons.messageCircle, '${v.commentsCount}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _miniStat(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: Colors.white24, size: 12),
        const SizedBox(width: 4),
        Text(val, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildAudienceTab() {
    final analytics = ref.watch(etokAnalyticsDataProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChartCard('Gender Distribution', _buildGenderPieChart(analytics['audience_gender'] as List)),
        const SizedBox(height: 16),
        _buildChartCard('Top Regions', _buildRegionsList(analytics['audience_regions'] as List)),
        const SizedBox(height: 16),
        _buildChartCard('Follower Growth', _buildBarChart()),
      ],
    );
  }

  Widget _buildGenderPieChart(List<dynamic> data) {
    return SizedBox(
      height: 150,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 30,
          sections: data.map((d) {
            final val = d['value'] as double;
            final label = d['label'] as String;
            Color color = Colors.blue;
            if (label == 'Female') color = const Color(0xFFFF0050);
            if (label == 'Other') color = Colors.purple;
            
            return PieChartSectionData(
              color: color,
              value: val,
              title: '${val.toInt()}%',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRegionsList(List<dynamic> data) {
    return Column(
      children: data.map((d) {
        final percent = d['percent'] as int;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(d['region'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('$percent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFFFF0050),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
