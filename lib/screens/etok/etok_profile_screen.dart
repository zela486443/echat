import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class EtokProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  const EtokProfileScreen({super.key, this.userId});

  @override
  ConsumerState<EtokProfileScreen> createState() => _EtokProfileScreenState();
}

class _EtokProfileScreenState extends ConsumerState<EtokProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOwn = widget.userId == null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('@zola', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(radius: 50, backgroundColor: Colors.white10, child: Text('👤', style: TextStyle(fontSize: 40))),
                  const SizedBox(height: 12),
                  const Text('Zola', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('@zola', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 20),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStat('Following', '241'),
                      const SizedBox(width: 32),
                      _buildStat('Followers', '1.2K'),
                      const SizedBox(width: 32),
                      _buildStat('Likes', '15.4K'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOwn ? Colors.white10 : const Color(0xFFFF0050),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(isOwn ? 'Edit Profile' : 'Follow', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )),
                        if (!isOwn) ...[
                          const SizedBox(width: 8),
                          Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.message, color: Colors.white, size: 20)),
                        ],
                        const SizedBox(width: 8),
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.share, color: Colors.white, size: 20)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Digital Creator | Love Etok! 🚀', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(height: 32),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white38,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_3x3)),
                      Tab(icon: Icon(Icons.favorite_border)),
                    ],
                  ),

                  // Video Grid (Placeholder)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.7, crossAxisSpacing: 1, mainAxisSpacing: 1),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.white.withOpacity(0.05),
                        child: Stack(
                          children: [
                            const Center(child: Icon(Icons.play_arrow, color: Colors.white24)),
                            Positioned(
                              bottom: 4, left: 4,
                              child: Row(children: [const Icon(Icons.play_arrow, color: Colors.white, size: 12), const SizedBox(width: 2), Text(_formatCount(1200 + index * 100), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
