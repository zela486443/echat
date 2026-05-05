import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BotChatScreen extends ConsumerStatefulWidget {
  final String botId;
  const BotChatScreen({super.key, required this.botId});

  @override
  ConsumerState<BotChatScreen> createState() => _BotChatScreenState();
}

class _BotChatScreenState extends ConsumerState<BotChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'isBot': true, 'text': 'Hello! How can I help you today?', 'time': '10:00 AM'},
  ];
  bool _isTyping = false;

  final List<String> _commands = ['/start', '/help', '/weather', '/crypto', '/settings'];

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'isBot': false, 'text': text, 'time': '10:01 AM'});
      _isTyping = true;
    });
    _inputController.clear();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({'isBot': true, 'text': 'I received: $text. This is a mock response.', 'time': '10:01 AM'});
      });
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
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: Colors.blue.withOpacity(0.2), child: const Icon(Icons.smart_toy, color: Colors.blue, size: 20)),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('WeatherBot', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text('online', style: TextStyle(color: Colors.green, fontSize: 11)),
            ]),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCommandsBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildCommandsBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _commands.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(_commands[index], style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.blue.withOpacity(0.1),
              side: BorderSide(color: Colors.blue.withOpacity(0.2)),
              onPressed: () => _handleSend(_commands[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isBot = msg['isBot'];
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isBot ? Colors.white.withOpacity(0.1) : const Color(0xFFFF0050),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 4 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 4),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(msg['text'], style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 4),
            Text(msg['time'], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: const Text('...', style: TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Type a command...', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: () => _handleSend(_inputController.text), icon: const Icon(Icons.send, color: Color(0xFFFF0050))),
        ],
      ),
    );
  }
}
