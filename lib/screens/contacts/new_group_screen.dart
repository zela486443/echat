import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({super.key});

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final List<String> _selectedIds = [];
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _contacts = [
    {'id': '1', 'name': 'Abel Tesfaye', 'username': 'abel_tesfaye', 'online': true},
    {'id': '2', 'name': 'Zola Jesus', 'username': 'zola_j', 'online': false},
    {'id': '3', 'name': 'Daniel Caesar', 'username': 'danny_c', 'online': true},
    {'id': '4', 'name': 'James Blake', 'username': 'jblake', 'online': false},
    {'id': '5', 'name': 'Solange Knowles', 'username': 'solange', 'online': true},
  ];

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_selectedIds.isNotEmpty) _buildSelectedHorizontalList(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildSearchField(),
            ),
          ),
          _buildContactsList(),
        ],
      ),
      floatingActionButton: _selectedIds.isNotEmpty 
        ? FloatingActionButton(
            backgroundColor: const Color(0xFF7C3AED),
            onPressed: () {},
            child: const Icon(LucideIcons.arrowRight, color: Colors.white),
          )
        : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Group', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          if (_selectedIds.isNotEmpty) Text('${_selectedIds.length} members selected', style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSelectedHorizontalList() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _selectedIds.length,
          itemBuilder: (context, index) {
            final id = _selectedIds[index];
            final contact = _contacts.firstWhere((c) => c['id'] == id);
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                children: [
                  Column(
                    children: [
                      CircleAvatar(radius: 26, backgroundColor: const Color(0xFF7C3AED), child: Text(contact['name']![0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 4),
                      Text(contact['name'].split(' ')[0], style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ],
                  ),
                  Positioned(right: 0, top: 0, child: GestureDetector(onTap: () => _toggleSelection(id), child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(LucideIcons.x, color: Colors.black, size: 10)))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.search, color: Colors.white24, size: 18), hintText: 'Who would you like to add?', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }

  Widget _buildContactsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final contact = _contacts[index];
          final isSelected = _selectedIds.contains(contact['id']);

          return ListTile(
            onTap: () => _toggleSelection(contact['id']),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Stack(
              children: [
                CircleAvatar(radius: 24, backgroundColor: const Color(0xFF151122), child: Text(contact['name']![0], style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                if (contact['online'] as bool) Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D0A1A), width: 2)))),
              ],
            ),
            title: Text(contact['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            subtitle: Text('@${contact['username']}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
            trailing: Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? const Color(0xFF7C3AED) : Colors.transparent, border: Border.all(color: isSelected ? Colors.transparent : Colors.white10, width: 2)), child: isSelected ? const Icon(LucideIcons.check, color: Colors.white, size: 14) : null),
          );
        },
        childCount: _contacts.length,
      ),
    );
  }
}
