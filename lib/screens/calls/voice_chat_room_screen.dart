import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VoiceChatRoomScreen extends StatefulWidget {
  const VoiceChatRoomScreen({super.key});

  @override
  State<VoiceChatRoomScreen> createState() => _VoiceChatRoomScreenState();
}

class _VoiceChatRoomScreenState extends State<VoiceChatRoomScreen> {
  bool isMuted = true;
  bool isHandRaised = false;

  final List<Map<String, dynamic>> participants = [
    {'name': 'Alex', 'role': 'Host', 'isSpeaking': true, 'color': Colors.blue},
    {'name': 'Sarah', 'role': 'Speaker', 'isSpeaking': false, 'color': Colors.purple},
    {'name': 'Mike', 'role': 'Listener', 'isSpeaking': false, 'color': Colors.green},
    {'name': 'Emma', 'role': 'Listener', 'isSpeaking': false, 'color': Colors.orange},
    {'name': 'David', 'role': 'Listener', 'isSpeaking': false, 'color': Colors.teal},
    {'name': 'Lisa', 'role': 'Listener', 'isSpeaking': false, 'color': Colors.red},
  ];

  Widget _participantCard(dynamic p, String currentUserId) {
    bool isMe = p['userId'] == currentUserId;
    bool isSpeaking = p['isSpeaking'] ?? false;
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isSpeaking)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 2),
                ),
              ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1.2.seconds).custom(builder: (context, val, child) => Opacity(opacity: 0.8 - (val * 0.5), child: child)),
            
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSpeaking ? const Color(0xFF10B981) : (p['isMuted'] == true ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: ChatAvatar(name: p['name'], src: p['avatar'], size: 'lg'),
              ),
            ),

            if (p['isMuted'] == true)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.mic_off, color: Colors.white, size: 10),
                ),
              ),
            
            if (p['isHandRaised'] == true)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                  child: const Icon(Icons.pan_tool, color: Colors.black, size: 10),
                ),
              ).animate(onPlay: (c) => c.repeat()).moveY(begin: 0, end: -4, duration: 0.6.seconds, curve: Curves.easeInOut),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isMe ? 'You' : p['name'],
          style: TextStyle(
            color: isMe ? const Color(0xFF7C3AED) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ).animate(target: isSpeaking ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms);
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap, {bool isDestructive = false}) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => HapticFeedback.selectionClick(),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDestructive ? Colors.red : Colors.white.withOpacity(0.12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                if (isDestructive) BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ).animate(onPlay: (c) => c.stop()).scale(
                begin: const Offset(1, 1),
                end: const Offset(0.86, 0.86),
                duration: 100.ms,
                curve: Curves.easeOutQuad,
              ).then().scale(
                begin: const Offset(0.86, 0.86),
                end: const Offset(1, 1),
                duration: 150.ms,
                curve: Curves.elasticOut,
              ),
        ),
      ],
    );
  }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => context.pop(),
        ),
        title: const Text('Flutter Devs Weekly', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                return _participantCard(participants[index], currentUserId);
              },
            ),
          ),
                  isMuted ? theme.colorScheme.surface : theme.colorScheme.primary,
                  isMuted ? theme.colorScheme.onSurface : Colors.white,
                  () => setState(() => isMuted = !isMuted),
                ),
                _buildControlButton(
                  'Raise Hand',
                  isHandRaised ? Icons.back_hand : Icons.pan_tool_outlined,
                  isHandRaised ? Colors.amber : theme.colorScheme.surface,
                  isHandRaised ? Colors.white : theme.colorScheme.onSurface,
                  () => setState(() => isHandRaised = !isHandRaised),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Text('Leave', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
