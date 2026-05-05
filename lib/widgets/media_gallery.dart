import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'glassmorphic_container.dart';

class MediaGallery extends StatefulWidget {
  final String chatId;
  final String chatName;

  const MediaGallery({super.key, required this.chatId, required this.chatName});

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for demonstration - in real app, fetch via Supabase
  final List<Map<String, dynamic>> _mediaItems = [
    {'type': 'image', 'url': 'https://picsum.photos/200/300?random=1', 'date': 'Today'},
    {'type': 'image', 'url': 'https://picsum.photos/200/300?random=2', 'date': 'Today'},
    {'type': 'video', 'url': 'https://picsum.photos/200/300?random=3', 'date': 'Yesterday', 'duration': '0:15'},
    {'type': 'image', 'url': 'https://picsum.photos/200/300?random=4', 'date': 'Last Week'},
    {'type': 'file', 'name': 'presentation.pdf', 'size': '2.4 MB', 'date': 'Last Month'},
    {'type': 'link', 'url': 'https://google.com', 'title': 'Google Search', 'date': 'Last Month'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMediaGrid('all'),
                _buildMediaGrid('image'),
                _buildMediaGrid('video'),
                _buildFileList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shared Media',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.chatName,
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppTheme.primary,
      labelColor: AppTheme.primary,
      unselectedLabelColor: Colors.white38,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: 'All'),
        Tab(text: 'Photos'),
        Tab(text: 'Videos'),
        Tab(text: 'Files'),
      ],
    );
  }

  Widget _buildMediaGrid(String filter) {
    final filtered = _mediaItems.where((item) => filter == 'all' || item['type'] == filter).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No media found', style: TextStyle(color: Colors.white24)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        if (item['type'] == 'image' || item['type'] == 'video') {
          return _buildMediaThumbnail(item);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMediaThumbnail(Map<String, dynamic> item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(item['url'], fit: BoxFit.cover),
          if (item['type'] == 'video')
            const Center(
              child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 32),
            ),
          if (item['type'] == 'video')
            Positioned(
              bottom: 4,
              right: 6,
              child: Text(
                item['duration'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    final files = _mediaItems.where((item) => item['type'] == 'file' || item['type'] == 'link').toList();
    
    if (files.isEmpty) {
      return const Center(child: Text('No files or links', style: TextStyle(color: Colors.white24)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final item = files[index];
        final isLink = item['type'] == 'link';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassmorphicContainer(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLink ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLink ? LucideIcons.link2 : LucideIcons.fileText,
                    color: isLink ? Colors.blueAccent : Colors.greenAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLink ? (item['title'] ?? item['url']) : item['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isLink ? item['url'] : '${item['size']} • ${item['date']}',
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white24, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
