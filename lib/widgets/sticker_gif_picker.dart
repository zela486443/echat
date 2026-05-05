import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/sticker_service.dart';
import '../theme/app_theme.dart';

class StickerGifPicker extends StatefulWidget {
  final Function(Sticker) onSelect;
  final VoidCallback onClose;

  const StickerGifPicker({super.key, required this.onSelect, required this.onClose});

  @override
  State<StickerGifPicker> createState() => _StickerGifPickerState();
}

class _StickerGifPickerState extends State<StickerGifPicker> {
  String _activeTab = 'smileys';
  String _searchQuery = '';
  List<Sticker> _recentStickers = [];
  List<Sticker> _favoriteStickers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final recent = await StickerService.getRecent();
    final favs = await StickerService.getFavorites();
    if (mounted) {
      setState(() {
        _recentStickers = recent;
        _favoriteStickers = favs;
        if (_recentStickers.isNotEmpty) _activeTab = 'recent';
      });
    }
  }

  List<Sticker> _getDisplayStickers() {
    if (_searchQuery.isNotEmpty) return StickerService.search(_searchQuery);
    if (_activeTab == 'recent') return _recentStickers;
    if (_activeTab == 'favorites') return _favoriteStickers;
    final pack = StickerService.stickerPacks.firstWhere((p) => p.id == _activeTab, orElse: () => StickerService.stickerPacks.first);
    return pack.stickers;
  }

  @override
  Widget build(BuildContext context) {
    final stickers = _getDisplayStickers();
    final isSearching = _searchQuery.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Color(0xFF150D28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header / Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search stickers...',
                        hintStyle: TextStyle(color: Colors.white30),
                        prefixIcon: Icon(LucideIcons.search, color: Colors.white30, size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white38, size: 20),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Tabs
          if (!isSearching)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildTab('recent', LucideIcons.clock, 'Recent'),
                  _buildTab('favorites', LucideIcons.star, 'Favorites'),
                  ...StickerService.stickerPacks.map((p) => _buildTab(p.id, null, p.name, iconText: p.icon)),
                ],
              ),
            ),

          const Divider(height: 1, color: Colors.white10),

          // Grid
          Expanded(
            child: stickers.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: stickers.length,
                    itemBuilder: (context, i) {
                      final s = stickers[i];
                      final isFav = _favoriteStickers.any((fav) => fav.id == s.id);
                      return _buildStickerItem(s, isFav);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String id, IconData? icon, String label, {String? iconText}) {
    final active = _activeTab == id;
    return GestureDetector(
      onTap: () => setState(() { _activeTab = id; _searchQuery = ''; _searchController.clear(); }),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 4, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (icon != null) Icon(icon, size: 14, color: active ? AppTheme.primary : Colors.white38),
            if (iconText != null) Text(iconText, style: TextStyle(fontSize: 14, color: active ? AppTheme.primary : Colors.white38)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: active ? AppTheme.primary : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerItem(Sticker s, bool isFav) {
    return GestureDetector(
      onTap: () async {
        await StickerService.addRecent(s);
        widget.onSelect(s);
      },
      onLongPress: () async {
        final nowFav = await StickerService.toggleFavorite(s);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(nowFav ? 'Added to Favorites' : 'Removed from Favorites'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ));
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(s.label, style: const TextStyle(color: Colors.white38, fontSize: 9), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
              if (isFav)
                const Positioned(top: 4, right: 4, child: Icon(Icons.star, color: Colors.amber, size: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.search, size: 48, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text('No stickers found', style: TextStyle(color: Colors.white.withOpacity(0.2))),
        ],
      ),
    );
  }
}
