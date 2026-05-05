import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class SavedMessagesScreen extends ConsumerStatefulWidget {
  const SavedMessagesScreen({super.key});

  @override
  ConsumerState<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends ConsumerState<SavedMessagesScreen> {
  String _searchQuery = "";
  final List<dynamic> _savedMessages = [
    {'sender': 'Abode Kaleb', 'content': 'Check out this design system!', 'time': 'Apr 25, 10:45 AM', 'saved_at': 'Today', 'type': 'text'},
    {'sender': 'You', 'content': 'Photo', 'time': 'Apr 24, 2:30 PM', 'saved_at': 'Yesterday', 'type': 'image'},
    {'sender': 'Zion', 'content': 'Project_Specs.pdf', 'time': 'Apr 23, 9:15 AM', 'saved_at': 'Apr 23', 'type': 'file'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildSearchBarSliver(),
          if (_savedMessages.isEmpty) _buildEmptyStateSliver() else _buildListSliver(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: Row(
        children: [
          const Icon(LucideIcons.bookmark, color: Color(0xFFF59E0B), size: 20),
          const SizedBox(width: 12),
          const Text('Saved Messages', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              const Icon(LucideIcons.search, color: Colors.white38, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Search saved messages...', hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateSliver() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.bookmark, color: Colors.white10, size: 64),
          const SizedBox(height: 16),
          const Text('No saved messages', style: TextStyle(color: Colors.white24, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Long press any message to bookmark it', style: TextStyle(color: Colors.white12, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildListSliver() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final sm = _savedMessages[index];
            return _buildSavedItem(sm);
          },
          childCount: _savedMessages.length,
        ),
      ),
    );
  }

  Widget _buildSavedItem(dynamic sm) {
    IconData typeIcon = LucideIcons.messageSquare;
    if (sm['type'] == 'image') typeIcon = LucideIcons.camera;
    if (sm['type'] == 'file') typeIcon = LucideIcons.fileText;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   CircleAvatar(radius: 12, backgroundColor: Colors.white10, child: Icon(LucideIcons.user, color: Colors.white38, size: 10)),
                   const SizedBox(width: 8),
                   Text(sm['sender'], style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(sm['time'], style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(typeIcon, color: const Color(0xFF7C3AED).withOpacity(0.5), size: 16),
              const SizedBox(width: 12),
              Expanded(child: Text(sm['content'], style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Saved ${sm['saved_at']}', style: const TextStyle(color: Colors.white10, fontSize: 10)),
              GestureDetector(
                onTap: () {},
                child: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
