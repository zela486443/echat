import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mapped from EtokProfile.tsx and EtokAnalytics.tsx
class EtokProfileScreen extends ConsumerWidget {
  const EtokProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('user_echats_01', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(LucideIcons.barChart2), onPressed: () {}), // To Analytics
          IconButton(icon: const Icon(LucideIcons.menu), onPressed: () {}), // To Settings
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      const Text('@user_echats_01', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      
                      // Stat Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatBlock(title: 'Following', count: '124'),
                          _StatBlock(title: 'Followers', count: '10.2K'),
                          _StatBlock(title: 'Likes', count: '124.5K'),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                              onPressed: () {},
                              child: const Text('Edit Profile'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(onPressed: () {}, child: const Icon(LucideIcons.bookmark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    indicatorColor: Colors.indigo,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(icon: Icon(LucideIcons.grid)),
                      Tab(icon: Icon(LucideIcons.lock)),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Public Videos Grid
              GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 0.6,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: Stack(
                      children: [
                        const Center(child: Icon(LucideIcons.playCircle, color: Colors.white24)),
                        Positioned(
                          bottom: 4, left: 4,
                          child: Row(
                            children: [
                              const Icon(LucideIcons.play, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text('${(index + 1) * 1.5}K', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              // Private Videos Grid
              const Center(child: Text('Only you can see your private videos')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _StatBlock({required String title, required String count}) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
