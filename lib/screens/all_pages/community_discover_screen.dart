import 'package:flutter/material.dart';
import '../../widgets/aurora_gradient_bg.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../providers/discover_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommunityDiscoverScreen extends ConsumerWidget {
  const CommunityDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(discoverChannelsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Discover Communities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: AuroraGradientBg(
        child: channelsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white24)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white24))),
          data: (channels) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSearchBox(),
              const SizedBox(height: 24),
              _buildSectionHeader('Trending Topics', Icons.trending_up, Colors.orange),
              _buildTrendingTopics(),
              const SizedBox(height: 32),
              _buildSectionHeader('Recommended Channels', Icons.groups, Colors.blue),
              if (channels.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: Text('No channels found', style: TextStyle(color: Colors.white24))),
                )
              else
                ...channels.map((c) => _buildGroupCard(
                  context,
                  c.name,
                  c.description ?? 'No description',
                  'Public Channel',
                  'https://picsum.photos/200?random=${c.id.hashCode}',
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return GlassmorphicContainer(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.white24),
          SizedBox(width: 12),
          Text('Search communities...', style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTrendingTopics() {
    final topics = ['#Flutter', '#TechNews', '#Ethiopia', '#Wallet', '#AI', '#Echats'];
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: topics.map((t) => ActionChip(
          label: Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          backgroundColor: Colors.white.withOpacity(0.1),
          side: BorderSide.none,
          onPressed: () {},
        )).toList(),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, String title, String desc, String members, String imgUrl) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(imgUrl)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.white24, size: 14),
                      const SizedBox(width: 4),
                      Text(members, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                      const Spacer(),
                      TextButton(onPressed: () {}, child: const Text('Join', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
