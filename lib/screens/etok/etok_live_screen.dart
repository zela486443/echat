import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';

class EtokLiveScreen extends ConsumerStatefulWidget {
  final String? streamId;
  const EtokLiveScreen({super.key, this.streamId});

  @override
  ConsumerState<EtokLiveScreen> createState() => _EtokLiveScreenState();
}

class _EtokLiveScreenState extends ConsumerState<EtokLiveScreen> {
  bool _isWatching = false;
  bool _showGifts = false;
  String _activeCategory = 'All';
  final List<String> _categories = ['All', 'Music', 'Gaming', 'Education', 'Lifestyle', 'Tech', 'Art', 'Sports'];

  // Mock data for watching mode
  final List<Map<String, String>> _comments = [
    {'name': 'selam_h', 'text': '🔥🔥🔥 amazing!', 'avatar': '👩'},
    {'name': 'biruk_t', 'text': 'Love this content!', 'avatar': '👦'},
    {'name': 'tigist_w', 'text': '❤️❤️❤️', 'avatar': '💪'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.streamId != null) {
      _isWatching = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isWatching) {
      return _buildWatchingUI();
    }
    return _buildBrowseUI();
  }

  // --- Watching UI ---
  Widget _buildWatchingUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Stream background (Mock)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF0D0A1A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Text('🎸', style: TextStyle(fontSize: 120)),
            ),
          ),
          
          _buildBlackOverlay(),

          // Top Header
          Positioned(
            top: 50, left: 16, right: 16,
            child: Row(
              children: [
                IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => setState(() => _isWatching = false)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 14, backgroundColor: Colors.white24, child: Text('👤', style: TextStyle(fontSize: 12))),
                      const SizedBox(width: 8),
                      const Text('Selam App', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFFF0050), borderRadius: BorderRadius.circular(10)), child: const Text('Follow', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(15)),
                  child: const Row(children: [Icon(LucideIcons.users, color: Colors.white, size: 14), SizedBox(width: 4), Text('1.2K', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
                ),
              ],
            ),
          ),

          // Comments
          Positioned(
            bottom: 100, left: 16, right: 80,
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_comments[i]['avatar']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_comments[i]['name']!, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(_comments[i]['text']!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Actions
          Positioned(
            bottom: 120, right: 16,
            child: Column(
              children: [
                _buildActionIcon(LucideIcons.gift, 'Gift', onTap: () => setState(() => _showGifts = true)),
                const SizedBox(height: 16),
                _buildActionIcon(LucideIcons.share2, 'Share'),
              ],
            )
          ),

          // Bottom Input
          Positioned(
            bottom: 30, left: 16, right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25)),
                    child: const TextField(decoration: InputDecoration(hintText: 'Say something...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none), style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(LucideIcons.send, color: Color(0xFFFF0050), size: 28),
              ],
            ),
          ),

          // Gift Drawer
          if (_showGifts) _buildGiftDrawer(),
        ],
      ),
    );
  }

  Widget _buildBlackOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle, border: Border.all(color: Colors.white10)), child: Icon(icon, color: Colors.white, size: 22)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _buildGiftDrawer() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF111111), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Send Gift', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(LucideIcons.x, color: Colors.white54), onPressed: () => setState(() => _showGifts = false)),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: [
                _buildGiftItem('💎', 'Diamond', '10'),
                _buildGiftItem('🌹', 'Rose', '1'),
                _buildGiftItem('🚀', 'Rocket', '100'),
                _buildGiftItem('👑', 'Crown', '50'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftItem(String emoji, String name, String coins) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)),
        Text('$coins Coins', style: const TextStyle(color: Colors.yellow, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- Browse UI ---
  Widget _buildBrowseUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.search, color: Colors.white70), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFF0050), borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [Icon(LucideIcons.radio, color: Colors.white, size: 14), SizedBox(width: 4), Text('Go LIVE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('🔴 Live Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildLiveCard('Music Jam', 'Selam H.', '🎸', 'Color(0xFF7C3AED)'),
                    _buildLiveCard('Gaming Night', 'Biruk T.', '🎮', 'Color(0xFF2563EB)'),
                    _buildLiveCard('Tech Chat', 'Abel G.', '💻', 'Color(0xFF059669)'),
                    _buildLiveCard('Art Gallery', 'Meron A.', '🎨', 'Color(0xFFDB2777)'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          bool active = _activeCategory == _categories[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_categories[i]),
              selected: active,
              onSelected: (val) => setState(() => _activeCategory = _categories[i]),
              selectedColor: Colors.white,
              backgroundColor: Colors.white10,
              labelStyle: TextStyle(color: active ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveCard(String title, String host, String emoji, String colorStr) {
    return InkWell(
      onTap: () => setState(() => _isWatching = true),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Colors.black45, Colors.black]),
        ),
        child: Stack(
          children: [
             Center(child: Text(emoji, style: const TextStyle(fontSize: 60))),
             Positioned(
               bottom: 0, left: 0, right: 0,
               child: Container(
                 padding: const EdgeInsets.all(12),
                 decoration: const BoxDecoration(
                   gradient: LinearGradient(colors: [Colors.black, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                   borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                     Text(host, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                   ],
                 ),
               ),
             ),
             Positioned(
               top: 8, left: 8,
               child: Container(
                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                 decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                 child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
