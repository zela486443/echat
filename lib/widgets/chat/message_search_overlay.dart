import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class MessageSearchOverlay extends StatefulWidget {
  final String chatId;
  final Function(String messageId) onResultTap;

  const MessageSearchOverlay({super.key, required this.chatId, required this.onResultTap});

  @override
  State<MessageSearchOverlay> createState() => _MessageSearchOverlayState();
}

class _MessageSearchOverlayState extends State<MessageSearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  
  // Mock search results
  final List<Map<String, dynamic>> _allMessages = [
    {'id': '1', 'sender': 'Zola', 'text': 'Hey, are you coming to the meeting?', 'date': '10:45 AM'},
    {'id': '2', 'sender': 'Alice', 'text': 'Yes, I am on my way.', 'date': '10:46 AM'},
    {'id': '3', 'sender': 'Zola', 'text': 'Great, don\'t forget the presentation files.', 'date': '10:47 AM'},
    {'id': '4', 'sender': 'Alice', 'text': 'I have them right here on my laptop.', 'date': '10:50 AM'},
    {'id': '5', 'sender': 'Bob', 'text': 'I\'ll be a bit late, sorry guys.', 'date': '11:00 AM'},
  ];

  List<Map<String, dynamic>> get _results {
    if (_query.isEmpty) return [];
    return _allMessages.where((m) => 
      m['text'].toString().toLowerCase().contains(_query.toLowerCase()) ||
      m['sender'].toString().toLowerCase().contains(_query.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          color: Color(0xFF0D0A1A),
        ),
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _query.isEmpty ? _buildEmptyState() : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autoFocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.search, color: Colors.white.withOpacity(0.05), size: 80),
          const SizedBox(height: 16),
          const Text(
            'Search for messages or people',
            style: TextStyle(color: Colors.white24, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final results = _results;

    if (results.isEmpty) {
      return const Center(
        child: Text('No messages found', style: TextStyle(color: Colors.white24)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final m = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              widget.onResultTap(m['id']);
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: GlassmorphicContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m['sender'],
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        m['date'],
                        style: const TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildHighlightedText(m['text'], _query),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text, style: const TextStyle(color: Colors.white70));

    final matches = query.toLowerCase();
    final parts = text.split(RegExp(matches, caseSensitive: false));
    final searchMatches = RegExp(matches, caseSensitive: false).allMatches(text).toList();

    List<TextSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i], style: const TextStyle(color: Colors.white70)));
      if (i < searchMatches.length) {
        spans.add(TextSpan(
          text: searchMatches[i].group(0),
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, backgroundColor: AppTheme.primary.withOpacity(0.1)),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
