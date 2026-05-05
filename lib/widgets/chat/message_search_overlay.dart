import 'package:flutter/material.dart';

class MessageSearchOverlay extends StatefulWidget {
  final List<Map<String, dynamic>> messages; // [{id, content, sender_name, created_at}]
  final Function(String messageId) onResultTap;
  final VoidCallback onClose;

  const MessageSearchOverlay({super.key, required this.messages, required this.onResultTap, required this.onClose});

  @override
  State<MessageSearchOverlay> createState() => _MessageSearchOverlayState();
}

class _MessageSearchOverlayState extends State<MessageSearchOverlay> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];

  void _search(String query) {
    if (query.trim().isEmpty) { setState(() => _results = []); return; }
    final q = query.toLowerCase();
    setState(() {
      _results = widget.messages.where((m) {
        final content = (m['content'] as String? ?? '').toLowerCase();
        return content.contains(q);
      }).toList();
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0A1A),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1130),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08))),
              ),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white54), onPressed: widget.onClose),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onChanged: _search,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    Text('${_results.length} results', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  if (_controller.text.isNotEmpty)
                    IconButton(icon: const Icon(Icons.close, color: Colors.white38, size: 18), onPressed: () { _controller.clear(); _search(''); }),
                ],
              ),
            ),
            // Results
            Expanded(
              child: _results.isEmpty
                  ? Center(child: Text(
                      _controller.text.isEmpty ? 'Type to search' : 'No results found',
                      style: TextStyle(color: Colors.white.withOpacity(0.3)),
                    ))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final msg = _results[i];
                        final content = msg['content'] as String? ?? '';
                        final sender = msg['sender_name'] as String? ?? 'Unknown';
                        final date = msg['created_at']?.toString().substring(0, 10) ?? '';

                        return ListTile(
                          onTap: () => widget.onResultTap(msg['id']),
                          title: _buildHighlightedText(content, _controller.text),
                          subtitle: Row(
                            children: [
                              Text(sender, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                              const SizedBox(width: 8),
                              Text(date, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                            ],
                          ),
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle),
                            child: const Icon(Icons.message, color: Colors.white24, size: 18),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) return Text(text, style: const TextStyle(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis);
    final lower = text.toLowerCase();
    final qLower = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lower.indexOf(qLower, start);
      if (idx < 0) { spans.add(TextSpan(text: text.substring(start))); break; }
      if (idx > start) spans.add(TextSpan(text: text.substring(start, idx)));
      spans.add(TextSpan(text: text.substring(idx, idx + query.length), style: const TextStyle(backgroundColor: Color(0x557C3AED), fontWeight: FontWeight.bold)));
      start = idx + query.length;
    }
    return RichText(text: TextSpan(style: const TextStyle(color: Colors.white70, fontSize: 14), children: spans), maxLines: 2, overflow: TextOverflow.ellipsis);
  }
}
