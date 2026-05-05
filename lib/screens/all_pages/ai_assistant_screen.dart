import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isBusy = false;
  bool _isGeneratingImage = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestions = [
    'Write a poem about Ethiopia',
    'How does blockchain work?',
    'Generate an image of a cyber city',
    'Translate "Hello" to Amharic'
  ];

  void _sendMessage([String? text]) {
    final msg = text ?? _controller.text;
    if (msg.isEmpty || _isBusy) return;

    setState(() {
      _messages.add({'role': 'user', 'content': msg});
      _controller.clear();
      _isBusy = true;
      if (msg.toLowerCase().contains('generate') || msg.toLowerCase().contains('image')) {
        _isGeneratingImage = true;
      }
    });

    _scrollToBottom();

    // Simulation logic
    if (_isGeneratingImage) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'role': 'assistant',
              'content': 'Here is your generated image! 🎨',
              'image_url': 'https://images.unsplash.com/photo-1614728263952-84ea256f9679?q=80&w=1000&auto=format&fit=crop',
            });
            _isBusy = false;
            _isGeneratingImage = false;
          });
          _scrollToBottom();
        }
      });
    } else {
      _streamResponse('I am Echat AI. To answer your question about **$msg**:\n\n1. First, we need to consider the context.\n2. Second, we apply logic.\n\n`Code block example`\n\nHope this helps!');
    }
  }

  void _streamResponse(String fullText) {
    String currentText = "";
    int index = 0;
    
    _messages.add({'role': 'assistant', 'content': ''});
    final msgIndex = _messages.length - 1;

    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (index >= fullText.length) {
        timer.cancel();
        setState(() => _isBusy = false);
        return;
      }
      if (mounted) {
        setState(() {
          currentText += fullText[index];
          _messages[msgIndex]['content'] = currentText;
          index++;
        });
        _scrollToBottom();
      } else {
        timer.cancel();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background Glow
          Positioned(top: -100, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF7C3AED).withOpacity(0.05)))),
          
          Column(
            children: [
              Expanded(child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList()),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(builder: (context) => IconButton(icon: const Icon(LucideIcons.menu, color: Colors.white, size: 20), onPressed: () => Scaffold.of(context).openDrawer())),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]), shape: BoxShape.circle),
            child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Echat AI', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_isBusy ? 'Thinking...' : 'Powered by AI', style: TextStyle(color: _isBusy ? const Color(0xFF10B981) : Colors.white38, fontSize: 10)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(LucideIcons.plus, color: Colors.white38, size: 20), onPressed: () => setState(() => _messages.clear())),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0D0A1A),
      child: Column(
        children: [
          DrawerHeader(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]), shape: BoxShape.circle), child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 32)), const SizedBox(height: 12), const Text('Chat History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]))),
          ListTile(leading: const Icon(LucideIcons.plus, color: Colors.white), title: const Text('New Chat', style: TextStyle(color: Colors.white)), onTap: () { setState(() => _messages.clear()); context.pop(); }),
          const Divider(color: Colors.white10),
          Expanded(child: ListView.builder(itemCount: 5, itemBuilder: (context, index) => ListTile(leading: const Icon(LucideIcons.messageSquare, color: Colors.white24, size: 18), title: Text('Research Topic $index', style: const TextStyle(color: Colors.white38, fontSize: 14))))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(LucideIcons.sparkles, color: Color(0xFF7C3AED), size: 48)),
            const SizedBox(height: 24),
            const Text('What can I help with?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Ask me anything or use suggestions below', style: TextStyle(color: Colors.white24, fontSize: 14)),
            const SizedBox(height: 40),
            ..._suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _sendMessage(s),
                borderRadius: BorderRadius.circular(16),
                child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold))),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isGeneratingImage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return _buildGeneratingImageState();
        final msg = _messages[index];
        final isMe = msg['role'] == 'user';
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) Container(margin: const EdgeInsets.only(top: 4, right: 8), padding: const EdgeInsets.all(4), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]), shape: BoxShape.circle), child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 10)),
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isMe ? const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]) : null,
                        color: isMe ? null : const Color(0xFF151122),
                        borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: const Radius.circular(20), bottomLeft: Radius.circular(isMe ? 20 : 4), bottomRight: Radius.circular(isMe ? 4 : 20)),
                      ),
                      child: MarkdownBody(
                        data: msg['content'],
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                          strong: const TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold),
                          code: const TextStyle(backgroundColor: Colors.white10, fontFamily: 'monospace', fontSize: 12),
                          listBullet: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    if (msg['image_url'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(msg['image_url'], height: 250, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneratingImageState() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(margin: const EdgeInsets.only(top: 4, right: 8), padding: const EdgeInsets.all(4), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]), shape: BoxShape.circle), child: const Icon(LucideIcons.image, color: Colors.white, size: 10)),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED))),
                SizedBox(width: 12),
                Text('Generating image...', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(color: const Color(0xFF0D0A1A), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          IconButton(icon: const Icon(LucideIcons.mic, color: Colors.white24, size: 20), onPressed: () {}),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Ask Echat AI...', hintStyle: TextStyle(color: Colors.white12), border: InputBorder.none),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_isBusy ? LucideIcons.square : LucideIcons.send, color: const Color(0xFF7C3AED), size: 20),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}
