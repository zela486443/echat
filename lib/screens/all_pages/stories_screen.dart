import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StoriesScreen extends ConsumerStatefulWidget {
  const StoriesScreen({super.key});

  @override
  ConsumerState<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends ConsumerState<StoriesScreen> {
  bool _showArchive = false;

  final List<String> _cardGradients = [
    'linear-gradient(145deg,#7c3aed,#ec4899)',
    'linear-gradient(145deg,#06b6d4,#7c3aed)',
    'linear-gradient(145deg,#f97316,#ec4899)',
    'linear-gradient(145deg,#10b981,#06b6d4)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (_showArchive) _buildArchiveSection(),
                _buildMyStoryBanner(),
                _buildSectionHeader(LucideIcons.star, 'CLOSE FRIENDS', color: Color(0xFF10B981), badge: 2),
                _buildStoryGrid(count: 2, isCF: true),
                _buildSectionHeader(LucideIcons.sparkles, 'NEW STORIES', badge: 5),
                _buildStoryGrid(count: 4),
                _buildSectionHeader(LucideIcons.eye, 'VIEWED', color: Colors.white38),
                _buildStoryGrid(count: 4, seen: true),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(color: Colors.black45, border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: SafeArea(
        child: Column(
          children: [
            Container(height: 2, width: double.infinity, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.purple, Colors.pink, Colors.orange]))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Stories', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text('12 active', style: TextStyle(color: Colors.white38, fontSize: 11))]),
                  const Spacer(),
                  _buildHeaderButton(LucideIcons.star, 'Close Friends', Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  IconButton(icon: Icon(LucideIcons.archive, color: _showArchive ? const Color(0xFF7C3AED) : Colors.white54), onPressed: () => setState(() => _showArchive = !_showArchive)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(icon, color: color, size: 14), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))]));
  }

  Widget _buildSectionHeader(IconData icon, String title, {Color color = const Color(0xFF7C3AED), int? badge}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle), child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
          ],
        ],
      ),
    );
  }

  Widget _buildMyStoryBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      height: 100,
      decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFF7C3AED).withOpacity(0.2), const Color(0xFFEC4899).withOpacity(0.2)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          const Padding(padding: EdgeInsets.all(16), child: CircleAvatar(radius: 30, backgroundColor: Colors.white10, child: Icon(LucideIcons.camera, color: Color(0xFF7C3AED)))),
          const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Add to Your Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text('Share a photo or video', style: TextStyle(color: Colors.white38, fontSize: 13))])),
          Padding(padding: const EdgeInsets.all(16), child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle), child: const Icon(LucideIcons.plus, color: Colors.white, size: 18))),
        ],
      ),
    );
  }

  Widget _buildStoryGrid({required int count, bool isCF = false, bool seen = false}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.6),
      itemCount: count,
      itemBuilder: (context, i) => _buildStoryCard(i, isCF, seen),
    );
  }

  Widget _buildStoryCard(int index, bool isCF, bool seen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCF ? Color(0xFF10B981) : (seen ? Colors.transparent : const Color(0xFF7C3AED).withOpacity(0.5)), width: 2),
        gradient: LinearGradient(colors: [Colors.purple.withOpacity(0.3), Colors.pink.withOpacity(0.3)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Stack(
        children: [
          const Center(child: Icon(LucideIcons.image, color: Colors.white12, size: 40)),
          if (seen) Container(decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(18))),
          Positioned(
            top: 10, left: 10, right: 10,
            child: Row(children: List.generate(3, (index) => Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 1.5), decoration: BoxDecoration(color: Colors.white.withOpacity(index == 0 ? 1 : 0.4), borderRadius: BorderRadius.circular(1)))))),
          ),
          if (isCF) const Positioned(top: 20, right: 10, child: Icon(LucideIcons.star, color: Color(0xFF10B981), size: 16)),
          Positioned(
            bottom: 10, left: 10, right: 10,
            child: Row(
              children: [
                const CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: Text('👤', style: TextStyle(fontSize: 10))),
                const SizedBox(width: 8),
                const Expanded(child: Text('User Name', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20)),
      child: const Center(child: Text('Your Archived Stories appear here', style: TextStyle(color: Colors.white38, fontSize: 13))),
    );
  }
}
