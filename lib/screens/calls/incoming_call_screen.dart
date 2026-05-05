import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../providers/active_call_provider.dart';
import '../../widgets/chat_avatar.dart';
import '../../services/call_audio_service.dart';
import '../../widgets/calling_widgets.dart';

class IncomingCallScreen extends ConsumerStatefulWidget {
  const IncomingCallScreen({super.key});

  @override
  ConsumerState<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen> {
  @override
  void initState() {
    super.initState();
    CallAudioService().playRingtone();
    _startVibration();
  }

  void _startVibration() async {
    for (int i = 0; i < 20; i++) {
      if (!mounted) break;
      HapticFeedback.vibrate();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    CallAudioService().stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final call = ref.watch(activeCallProvider);
    if (call.status == CallStatus.idle) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    final isVideo = call.callType == 'video';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            _buildBackground(call),

            // Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Badge
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: _buildCallBadge(isVideo),
                  ),

                  // Center Avatar & Info
                  Column(
                    children: [
                      _buildAvatarWithRings(call),
                      const SizedBox(height: 32),
                      Text(
                        call.peerName,
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isVideo ? 'Incoming Video Call...' : 'Incoming Voice Call...',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                      ),
                    ],
                  ),

                  // Bottom Actions
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60, left: 24, right: 24),
                    child: Column(
                      children: [
                        _buildQuickReplies(),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _actionBtn(LucideIcons.phoneOff, 'Decline', Colors.red, () {
                              ref.read(activeCallProvider.notifier).rejectCall();
                            }),
                            _actionBtn(isVideo ? LucideIcons.video : LucideIcons.phone, 'Accept', Colors.green, () {
                              ref.read(activeCallProvider.notifier).acceptCall();
                            }, pulsate: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(ActiveCallState call) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (call.peerAvatar != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Opacity(
              opacity: 0.5,
              child: Image.network(call.peerAvatar!, fit: BoxFit.cover),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.black87],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallBadge(bool isVideo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isVideo ? LucideIcons.video : LucideIcons.phone, color: Colors.white70, size: 14),
          const SizedBox(width: 8),
          Text(
            isVideo ? 'VIDEO CALL' : 'VOICE CALL',
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithRings(ActiveCallState call) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ...[220.0, 180.0, 140.0].map((s) => PulsatingRing(size: s, color: Colors.greenAccent)),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: ChatAvatar(name: call.peerName, src: call.peerAvatar, size: 'xl'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReplies() {
    final replies = ["Can't talk", "Call me later", "Busy now"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: replies.map((r) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ActionChip(
          label: Text(r, style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: Colors.white10,
          side: const BorderSide(color: Colors.white24),
          onPressed: () {
            // In a real app, send message here
            ref.read(activeCallProvider.notifier).rejectCall();
          },
        ),
      )).toList(),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap, {bool pulsate = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ).animate(onPlay: (c) => pulsate ? c.repeat() : null).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 1.seconds,
            curve: Curves.easeInOut,
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
