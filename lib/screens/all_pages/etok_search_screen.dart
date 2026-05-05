import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/etok_service.dart';
import '../../models/etok_video.dart';

class EtokSearchScreen extends StatefulWidget {
  const EtokSearchScreen({super.key});

  @override
  State<EtokSearchScreen> createState() => _EtokSearchScreenState();
}

class _EtokSearchScreenState extends State<EtokSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<EtokVideo> _videoResults = [];
  bool _loading = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Dance', 'emoji': '💃', 'color': Color(0xFFE91E63)},
    {'label': 'Comedy', 'emoji': '😂', 'color': Color(0xFFFF9800)},
    {'label': 'Sports', 'emoji': '⚽', 'color': Color(0xFF4CAF50)},
    {'label': 'Food', 'emoji': '🍲', 'color': Color(0xFFF44336)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildDiscoveryView()
                : _buildResultsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(LucideIcons.search, color: Colors.white54, size: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 8),
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _searchController.clear()),
              child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.2),
          itemCount: _categories.length,
          itemBuilder: (context, index) => _buildCategoryCard(_categories[index]),
        ),
        const SizedBox(height: 24),
        const Text('Trending', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        _buildTrendingItem('#DanceChallenge', '1.2B'),
        _buildTrendingItem('#CookingTips', '840M'),
        _buildTrendingItem('#TravelVlog', '2.1B'),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
      decoration: BoxDecoration(color: (cat['color'] as Color).withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          Positioned(bottom: 4, right: 4, child: Text(cat['emoji'], style: const TextStyle(fontSize: 32))),
          Positioned(bottom: 8, left: 12, child: Text(cat['label'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildTrendingItem(String hashtag, String views) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)), child: const Icon(LucideIcons.hash, color: Colors.white, size: 18)),
      title: Text(hashtag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('$views views', style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
    );
  }

  Widget _buildResultsView() {
     return const Center(child: Text('Search results will appear here', style: TextStyle(color: Colors.white38)));
  }
}
