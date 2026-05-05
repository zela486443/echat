import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class VoiceChatRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  const VoiceChatRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<VoiceChatRoomScreen> createState() => _VoiceChatRoomScreenState();
}

class _VoiceChatRoomScreenState extends ConsumerState<VoiceChatRoomScreen> with TickerProviderStateMixin {
  bool _isMuted = false;
  bool _isHandRaised = false;
  
  final List<Map<String, dynamic>> _participants = [
    {'userId': '1', 'name': 'You', 'isSpeaking': true, 'isMuted': false, 'isHandRaised': false},
    {'userId': '2', 'name': 'Alex Rivera', 'isSpeaking': false, 'isMuted': true, 'isHandRaised': true},
    {'userId': '3', 'name': 'Sarah Chen', 'isSpeaking': false, 'isMuted': false, 'isHandRaised': false},
    {'userId': '4', 'name': 'Jordan Lee', 'isSpeaking': false, 'isMuted': false, 'isHandRaised': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildParticipantGrid()),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Strategy Meeting', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Echat Core Team', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.users, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text('${_participants.length}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ],
            ),
            IconButton(icon: const Icon(LucideIcons.x, color: Colors.white54), onPressed: () => context.pop()),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 30,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: _participants.length,
      itemBuilder: (context, i) => _buildParticipantCard(_participants[i]),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> p) {
    bool isYou = p['userId'] == '1';
    bool speaking = p['isSpeaking'];
    bool muted = isYou ? _isMuted : p['isMuted'];
    bool hand = isYou ? _isHandRaised : p['isHandRaised'];

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (speaking) _buildSpeakingRings(),
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: speaking ? Colors.green.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                border: Border.all(color: speaking ? Colors.green : Colors.white10, width: 2),
              ),
              child: Center(
                child: Text(
                  p['name'].substring(0, 1),
                  style: TextStyle(color: speaking ? Colors.green : Colors.white70, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (muted)
              Positioned(
                bottom: 0, right: 0,
                child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(LucideIcons.micOff, color: Colors.white, size: 12)),
              ),
            if (hand)
              Positioned(
                top: 0, right: 0,
                child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle), child: const Icon(LucideIcons.hand, color: Colors.black, size: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(isYou ? 'You' : p['name'], style: TextStyle(color: isYou ? const Color(0xFF7C3AED) : Colors.white, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildSpeakingRings() {
    return _SpeakingRings();
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 50),
      decoration: BoxDecoration(color: Colors.black45, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(icon: _isMuted ? LucideIcons.micOff : LucideIcons.mic, active: !_isMuted, color: _isMuted ? Colors.red : const Color(0xFF7C3AED), onTap: () => setState(() => _isMuted = !_isMuted)),
          _buildControlButton(icon: LucideIcons.hand, active: _isHandRaised, color: Colors.amber, onTap: () => setState(() => _isHandRaised = !_isHandRaised)),
          _buildControlButton(icon: LucideIcons.phoneOff, active: false, color: Colors.red, onTap: () => context.pop()),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required bool active, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(shape: BoxShape.circle, color: active ? color : Colors.white10),
        child: Icon(icon, color: active ? Colors.white : Colors.white70, size: 24),
      ),
    );
  }
}

class _SpeakingRings extends StatefulWidget {
  @override
  State<_SpeakingRings> createState() => _SpeakingRingsState();
}

class _SpeakingRingsState extends State<_SpeakingRings> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(2, (index) {
        return ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Interval(index * 0.5, 1.0, curve: Curves.easeOut))),
          child: FadeTransition(
            opacity: Tween(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Interval(index * 0.5, 1.0, curve: Curves.easeOut))),
            child: Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 2))),
          ),
        );
      }),
    );
  }
}
