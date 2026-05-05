import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MediaGallery extends ConsumerStatefulWidget {
  final String chatId;
  const MediaGallery({super.key, required this.chatId});

  @override
  ConsumerState<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends ConsumerState<MediaGallery> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allMedia = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMedia();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMedia() async {
    try {
      final res = await Supabase.instance.client
          .from('messages')
          .select('id, media_url, message_type, file_name, content, created_at')
          .eq('chat_id', widget.chatId)
          .inFilter('message_type', ['image', 'video', 'file'])
          .order('created_at', ascending: false);
      setState(() { _allMedia = List<Map<String, dynamic>>.from(res); _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _filterByType(String type) {
    if (type == 'all') return _allMedia;
    return _allMedia.where((m) => m['message_type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF150D28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const Padding(padding: EdgeInsets.all(16), child: Text('Media Gallery', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            indicatorColor: const Color(0xFF7C3AED),
            tabs: const [Tab(text: 'All'), Tab(text: 'Images'), Tab(text: 'Videos'), Tab(text: 'Files')],
          ),
          // Grid
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGrid(_filterByType('all')),
                      _buildGrid(_filterByType('image')),
                      _buildGrid(_filterByType('video')),
                      _buildFileList(_filterByType('file')),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text('No media yet', style: TextStyle(color: Colors.white38)));
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final url = item['media_url'] as String?;
        final isVideo = item['message_type'] == 'video';
        return GestureDetector(
          onTap: () { /* Navigate to MediaViewer */ },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null)
                CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, placeholder: (_, __) => Container(color: Colors.white10))
              else
                Container(color: Colors.white10, child: const Icon(Icons.image, color: Colors.white24)),
              if (isVideo)
                Center(child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFileList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text('No files yet', style: TextStyle(color: Colors.white38)));
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return ListTile(
          leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.insert_drive_file, color: Colors.white54)),
          title: Text(item['file_name'] ?? 'File', style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: Text(item['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: const Icon(Icons.download, color: Colors.white38, size: 20),
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white10, highlightColor: Colors.white24,
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
        itemCount: 12,
        itemBuilder: (_, __) => Container(color: Colors.white),
      ),
    );
  }
}
