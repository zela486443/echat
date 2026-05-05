import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../../services/ai_intelligence_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<AIMessage> _messages = [];
  List<AIConversation> _conversations = [];
  String? _activeConvId;
  bool _isBusy = false;
  bool _isLoadingConvs = true;

  final List<String> _suggestions = [
    'Write a poem about Ethiopia 🇪🇹',
    'Generate image of a futuristic city 🏙️',
    'Explain quantum computing ⚛️',
    'Top 5 recipes with Teff 🌾',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final service = ref.read(aiIntelligenceProvider);
    final convs = await service.loadConversations();
    if (mounted) {
      setState(() {
        _conversations = convs;
        _isLoadingConvs = false;
      });
    }
  }

  Future<void> _selectConversation(String? convId) async {
    if (convId == _activeConvId) return;
    
    setState(() {
      _activeConvId = convId;
      _messages = [];
      _isBusy = false;
    });

    if (convId != null) {
      final service = ref.read(aiIntelligenceProvider);
      final msgs = await service.loadMessages(convId);
      if (mounted && _activeConvId == convId) {
        setState(() => _messages = msgs);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? text]) async {
    final query = (text ?? _inputController.text).trim();
    if (query.isEmpty || _isBusy) return;

    _inputController.clear();
    final service = ref.read(aiIntelligenceProvider);

    // 1. Ensure conversation exists
    if (_activeConvId == null) {
      final newId = await service.createConversation(query.length > 30 ? query.substring(0, 30) : query);
      if (newId == null) return;
      setState(() => _activeConvId = newId);
      _loadInitialData(); // Refresh history list
    }

    final convId = _activeConvId!;

    // 2. Add user message
    final userMsg = AIMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: query,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages = [..._messages, userMsg];
      _isBusy = true;
    });
    _scrollToBottom();

    await service.saveMessage(convId, 'user', query);

    // 3. Check for image request
    if (service.isImageRequest(query)) {
      try {
        final result = await service.generateImage(query);
        final aiMsg = AIMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'assistant',
          content: 'Here is your generated image! 🎨',
          imageUrl: result['image_url'],
          createdAt: DateTime.now(),
        );
        setState(() {
          _messages = [..._messages, aiMsg];
          _isBusy = false;
        });
        await service.saveMessage(convId, 'assistant', aiMsg.content, imageUrl: aiMsg.imageUrl);
        _scrollToBottom();
      } catch (e) {
        _showError(e.toString());
        setState(() => _isBusy = false);
      }
      return;
    }

    // 4. Handle Streaming Text
    try {
      String fullContent = "";
      final assistantMsgId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final stream = service.streamAIResponse(_messages);
      
      await for (final chunk in stream) {
        fullContent += chunk;
        setState(() {
          // Update or add assistant message in current list
          final index = _messages.indexWhere((m) => m.id == assistantMsgId);
          if (index != -1) {
            _messages[index] = AIMessage(
              id: assistantMsgId,
              role: 'assistant',
              content: fullContent,
              createdAt: DateTime.now(),
            );
          } else {
            _messages = [
              ..._messages,
              AIMessage(
                id: assistantMsgId,
                role: 'assistant',
                content: fullContent,
                createdAt: DateTime.now(),
              )
            ];
          }
        });
        _scrollToBottom();
      }

      await service.saveMessage(convId, 'assistant', fullContent);
      setState(() => _isBusy = false);
    } catch (e) {
      _showError(e.toString());
      setState(() => _isBusy = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: _buildHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), 
          onPressed: () => Scaffold.of(context).openDrawer()
        )),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), 
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary(AppTheme.primary), 
                borderRadius: BorderRadius.circular(12)
              ), 
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const Text('Echat AI', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(_isBusy ? 'Thinking...' : 'Online', style: TextStyle(color: _isBusy ? Colors.amber : Colors.green, fontSize: 11)),
              ]
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white), 
            onPressed: () => _selectConversation(null)
          ),
        ],
      ),
      body: AuroraGradientBg(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty ? _buildEmptyState() : _buildMessageList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF141414),
      child: Column(
        children: [
          const DrawerHeader(child: Center(child: Text('Chat History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.white),
            title: const Text('New Chat', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _selectConversation(null);
            },
          ),
          const Divider(color: Colors.white10),
          if (_isLoadingConvs)
            const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conv = _conversations[index];
                  final isActive = conv.id == _activeConvId;
                  return ListTile(
                    leading: Icon(Icons.message, color: isActive ? AppTheme.primary : Colors.white38, size: 18),
                    title: Text(
                      conv.title, 
                      style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      DateFormat('MMM d').format(conv.lastMessageAt), 
                      style: const TextStyle(color: Colors.white24, fontSize: 10)
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _selectConversation(conv.id);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                      onPressed: () async {
                        await ref.read(aiIntelligenceProvider).deleteConversation(conv.id);
                        _loadInitialData();
                        if (_activeConvId == conv.id) _selectConversation(null);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24), 
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary(AppTheme.primary), 
                borderRadius: BorderRadius.circular(40),
                boxShadow: AppTheme.shadowPrimary,
              ), 
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 48)
            ),
            const SizedBox(height: 32),
            const Text('Echat AI', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Ask me anything or generate images', style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: _suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _handleSend(s),
                    borderRadius: BorderRadius.circular(16),
                    child: GlassmorphicContainer(
                      height: 56,
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(s, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        bool isUser = msg.role == 'user';
        return _buildBubble(msg, isUser);
      },
    );
  }

  Widget _buildBubble(AIMessage msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) 
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: CircleAvatar(
                radius: 14, 
                backgroundColor: AppTheme.primary.withOpacity(0.2), 
                child: const Icon(Icons.auto_awesome, color: Colors.blue, size: 14)
              ),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.gradientPrimary(AppTheme.primary) : null,
                color: isUser ? null : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser ? null : Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: msg.content,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      code: const TextStyle(backgroundColor: Colors.black26, fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  if (msg.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          msg.imageUrl!,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200, 
                              width: double.infinity, 
                              color: Colors.white10,
                              child: const Center(child: CircularProgressIndicator())
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('h:mm a').format(msg.createdAt), 
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, 
        right: 16, 
        top: 12, 
        bottom: MediaQuery.of(context).padding.bottom + 12
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1)))
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.mic, color: Colors.white38)
          ),
          Expanded(
            child: GlassmorphicContainer(
              height: 50,
              borderRadius: 25,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ask me anything...', 
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 14), 
                  border: InputBorder.none
                ),
                onSubmitted: (v) => _handleSend(v),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              gradient: AppTheme.gradientPrimary(AppTheme.primary),
              boxShadow: AppTheme.shadowGlowSm,
            ),
            child: IconButton(
              onPressed: () => _handleSend(), 
              icon: Icon(
                _isBusy ? Icons.stop : Icons.send, 
                color: Colors.white, 
                size: 20
              )
            ),
          ),
        ],
      ),
    );
  }
}
