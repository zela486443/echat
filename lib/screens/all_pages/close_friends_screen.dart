import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CloseFriendsScreen extends ConsumerStatefulWidget {
  const CloseFriendsScreen({super.key});

  @override
  ConsumerState<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends ConsumerState<CloseFriendsScreen> {
  final Set<String> _closeFriends = {'1', '3'};
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _mockContacts = [
    {'id': '1', 'name': 'Melat V', 'username': 'melat_v', 'avatar': '👩'},
    {'id': '2', 'name': 'Abel T', 'username': 'abel_t', 'avatar': '👦'},
    {'id': '3', 'name': 'Tigist W', 'username': 'tigist_w', 'avatar': '👩‍🎨'},
    {'id': '4', 'name': 'Biruk S', 'username': 'biruk_s', 'avatar': '🧔'},
  ];

  void _toggle(String id) {
    setState(() {
      if (_closeFriends.contains(id)) {
        _closeFriends.remove(id);
      } else {
        _closeFriends.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Column(children: [Text('Close Friends', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)), Text('2 friends', style: TextStyle(color: Colors.white54, fontSize: 11))]),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Search contacts...', hintStyle: TextStyle(color: Colors.white38), prefixIcon: Icon(Icons.search, color: Colors.white38), border: InputBorder.none),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: const Color(0xFF10B981).withOpacity(0.05),
            child: const Text('Share stories exclusively with Close Friends — they see a green ring.', style: TextStyle(color: const Color(0xFF10B981), fontSize: 12), textAlign: TextAlign.center),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _mockContacts.length,
              itemBuilder: (context, index) {
                final c = _mockContacts[index];
                bool isClose = _closeFriends.contains(c['id']);
                return ListTile(
                  onTap: () => _toggle(c['id']),
                  leading: Stack(
                    children: [
                      CircleAvatar(backgroundColor: isClose ? const Color(0xFF10B981) : Colors.white12, child: Text(c['avatar'])),
                      if (isClose) Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(1), decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle), child: const Icon(Icons.star, color: Colors.white, size: 10))),
                    ],
                  ),
                  title: Text(c['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('@${c['username']}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: isClose ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                    child: Icon(Icons.star, color: isClose ? const Color(0xFF10B981) : Colors.white24, size: 20),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
