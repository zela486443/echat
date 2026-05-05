import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';

class GroupCallScreen extends ConsumerStatefulWidget {
  final String? roomId;
  const GroupCallScreen({super.key, this.roomId});

  @override
  ConsumerState<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends ConsumerState<GroupCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isScreenSharing = false;

  final List<Map<String, dynamic>> _participants = [
    {'name': 'You', 'isSpeaking': true, 'avatar': null},
    {'name': 'Alex Rivera', 'isSpeaking': false, 'avatar': 'https://i.pravatar.cc/150?u=1'},
    {'name': 'Sarah Chen', 'isSpeaking': true, 'avatar': 'https://i.pravatar.cc/150?u=2'},
    {'name': 'Jordan Lee', 'isSpeaking': false, 'avatar': 'https://i.pravatar.cc/150?u=3'},
    {'name': 'Michael B.', 'isSpeaking': false, 'avatar': 'https://i.pravatar.cc/150?u=4'},
    {'name': 'Emma Wilson', 'isSpeaking': false, 'avatar': 'https://i.pravatar.cc/150?u=5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -100, left: -100, child: _buildGlow(AppTheme.primary.withOpacity(0.15), 300)),
          Positioned(bottom: -100, right: -100, child: _buildGlow(Colors.blue.withOpacity(0.1), 400)),

          // Participant Grid
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildGrid()),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(LucideIcons.lock, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 8),
                Text('Encrypted: ${widget.roomId ?? "Room"}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('REC 04:20', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _participants.length,
      itemBuilder: (context, i) => _buildParticipantCard(_participants[i]),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> p) {
    final bool speaking = p['isSpeaking'];
    final bool isYou = p['name'] == 'You';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: speaking ? AppTheme.primary : Colors.white10, width: speaking ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background placeholder / Video
          Center(
            child: p['avatar'] != null
                ? CircleAvatar(radius: 40, backgroundImage: NetworkImage(p['avatar']))
                : Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.2)),
                    child: Center(child: Text(p['name'].substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                  ),
          ),
          
          // Name label
          Positioned(
            bottom: 12, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Text(p['name'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),

          // Speaking indicator
          if (speaking)
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                child: const Icon(LucideIcons.mic, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ctrlBtn(_isMuted ? LucideIcons.micOff : LucideIcons.mic, _isMuted, () => setState(() => _isMuted = !_isMuted)),
            _ctrlBtn(_isCameraOff ? LucideIcons.videoOff : LucideIcons.video, _isCameraOff, () => setState(() => _isCameraOff = !_isCameraOff)),
            _ctrlBtn(LucideIcons.screenShare, _isScreenSharing, () => setState(() => _isScreenSharing = !_isScreenSharing)),
            _ctrlBtn(LucideIcons.moreHorizontal, false, () {}),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 54, height: 54,
                decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                child: const Icon(LucideIcons.phoneOff, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: active ? AppTheme.primary : Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.white70, size: 20),
      ),
    );
  }
}
