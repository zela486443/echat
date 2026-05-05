import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/etok_provider.dart';
import '../../models/etok_video.dart';
import '../../models/profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import 'dart:async';

class EtokSearchScreen extends ConsumerStatefulWidget {
  const EtokSearchScreen({super.key});

  @override
  ConsumerState<EtokSearchScreen> createState() => _EtokSearchScreenState();
}

class _EtokSearchScreenState extends ConsumerState<EtokSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isSearching = false;
  Timer? _debounce;
  List<PublicProfile> _userResults = [];
  List<EtokVideo> _videoResults = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Dance', 'emoji': '💃', 'colors': [Colors.pink, Colors.purple]},
    {'label': 'Comedy', 'emoji': '😂', 'colors': [Colors.orange, Colors.red]},
    {'label': 'Sports', 'emoji': '⚽', 'colors': [Colors.green, Colors.teal]},
    {'label': 'Food', 'emoji': '🍲', 'colors': [Colors.deepOrange, Colors.orange]},
    {'label': 'Travel', 'emoji': '✈️', 'colors': [Colors.lightBlue, Colors.blue]},
    {'label': 'Fashion', 'emoji': '👗', 'colors': [Colors.pinkAccent, Colors.redAccent]},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            if (_isSearching) _buildTabs(),
            Expanded(
              child: _isSearching ? _buildSearchResults() : _buildDiscovery(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (_isSearching)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchController.clear();
              }),
            ),
          if (_isSearching) const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close, color: Colors.white38), onPressed: () => setState(() => _searchController.clear()))
                      : null,
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && !_isSearching) setState(() => _isSearching = true);
                  _onSearchChanged(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final service = ref.read(etokServiceProvider);
    final supabaseService = ref.read(supabaseServiceProvider);
    
    final usersFuture = supabaseService.searchProfiles(query);
    final videosFuture = service.searchVideos(query);
    
    final userResults = await usersFuture;
    final videoResults = await videosFuture;

    if (mounted) {
      setState(() {
        _userResults = userResults;
        _videoResults = videoResults;
        _isLoading = false;
      });
    }
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      indicatorColor: Colors.white,
      isScrollable: true,
      tabs: const [
        Tab(text: 'Top'),
        Tab(text: 'Users'),
        Tab(text: 'Videos'),
        Tab(text: 'Sounds'),
        Tab(text: 'LIVE'),
      ],
    );
  }

  Widget _buildDiscovery() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.2),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: cat['colors']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(bottom: 8, left: 12, child: Text(cat['label'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                    Positioned(bottom: 4, right: 8, child: Text(cat['emoji'], style: const TextStyle(fontSize: 32))),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Row(children: [Icon(Icons.trending_up, color: Color(0xFFFF0050), size: 18), SizedBox(width: 8), Text('Trending', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['#DanceChallenge', '#TechTok', '#Foodie', '#TravelVlog', '#EtokTrend']
                .map((h) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)), child: Text(h, style: const TextStyle(color: Colors.white70, fontSize: 13))))
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text('Suggested Accounts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          // Suggested accounts placeholder
          _buildUserTile('zola', 'Zola'),
          _buildUserTile('etok_official', 'Etok Official'),
        ],
      ),
    );
  }


  Widget _buildSearchResults() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white24));

    return TabBarView(
      controller: _tabController,
      children: [
        _buildTopResults(),
        _buildUserResults(),
        _buildVideoResults(),
        _buildSearchTabContent('Sounds'),
        _buildSearchTabContent('LIVE'),
      ],
    );
  }

  Widget _buildTopResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_userResults.isNotEmpty) ...[
          const Text('Users', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._userResults.take(3).map((u) => _buildUserTile(u.username ?? 'user', u.name ?? 'Unknown', profile: u)),
          const SizedBox(height: 24),
        ],
        if (_videoResults.isNotEmpty) ...[
          const Text('Videos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildVideoGrid(_videoResults.take(6).toList()),
        ],
      ],
    );
  }

  Widget _buildUserResults() {
    if (_userResults.isEmpty) return const Center(child: Text('No users found', style: TextStyle(color: Colors.white38)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final u = _userResults[index];
        return _buildUserTile(u.username ?? 'user', u.name ?? 'Unknown', profile: u);
      },
    );
  }

  Widget _buildVideoResults() {
    if (_videoResults.isEmpty) return const Center(child: Text('No videos found', style: TextStyle(color: Colors.white38)));
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 9/16),
      itemCount: _videoResults.length,
      itemBuilder: (context, index) {
        final v = _videoResults[index];
        return GestureDetector(
          onTap: () {
            // Logic to play this specific video
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              image: v.thumbnailUrl != null ? DecorationImage(image: NetworkImage(v.thumbnailUrl!), fit: BoxFit.cover) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid(List<EtokVideo> videos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 9/16),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          image: videos[index].thumbnailUrl != null ? DecorationImage(image: NetworkImage(videos[index].thumbnailUrl!), fit: BoxFit.cover) : null,
        ),
      ),
    );
  }

  Widget _buildUserTile(String username, String name, {PublicProfile? profile}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        if (profile != null) context.push('/etok/profile/${profile.id}');
      },
      leading: CircleAvatar(
        backgroundColor: Colors.white12, 
        backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
        child: profile?.avatarUrl == null ? Text(name[0]) : null,
      ),
      title: Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(name, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), padding: const EdgeInsets.symmetric(horizontal: 16), minimumSize: const Size(0, 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        child: const Text('Follow', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSearchTabContent(String tab) {
    return Center(child: Text('Results for $tab', style: const TextStyle(color: Colors.white38)));
  }
}
