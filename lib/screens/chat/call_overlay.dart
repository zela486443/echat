import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/call_provider.dart';

enum CallState { idle, outgoing, connecting, inCall, ended, failed }
enum CallType { voice, video }

class CallOverlay extends ConsumerStatefulWidget {
  final String peerName;
  final String? peerAvatar;
  final CallType type;
  final CallState initialState;

  const CallOverlay({
    super.key,
    required this.peerName,
    this.peerAvatar,
    this.type = CallType.voice,
    this.initialState = CallState.outgoing,
  });

  @override
  ConsumerState<CallOverlay> createState() => _CallOverlayState();
}

class _CallOverlayState extends ConsumerState<CallOverlay> with TickerProviderStateMixin {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  Offset _pipOffset = const Offset(20, 100);

  @override
  void initState() {
    super.initState();
    // Logic is handled by the provider now, but we can keep local UI state
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _endCall() {
    ref.read(activeCallProvider.notifier).endCall();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(activeCallProvider);
    final status = _mapProviderStatus(callState.status);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Background ──
          if (widget.type == CallType.video && status == CallState.inCall)
            _buildRemoteVideo()
          else
            _buildAvatarBackground(),

          // ── Top Bar ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildTopBar(callState, status),
          ),

          // ── Main Content ──
          if (status != CallState.inCall || widget.type == CallType.voice)
            Center(child: _buildCallInfo(status)),

          // ── Draggable PiP (Local Video) ──
          if (widget.type == CallType.video)
            Positioned(
              right: _pipOffset.dx,
              top: _pipOffset.dy,
              child: _buildDraggablePiP(),
            ),

          // ── Bottom Controls ──
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomControls(status),
          ),

          // ── Status Text Overlay ──
          if (status == CallState.ended)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Text(
                  'Call Ended',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  CallState _mapProviderStatus(CallStatus s) {
    switch (s) {
      case CallStatus.outgoing: return CallState.outgoing;
      case CallStatus.connecting: return CallState.connecting;
      case CallStatus.inCall: return CallState.inCall;
      case CallStatus.ended: return CallState.ended;
      default: return CallState.idle;
    }
  }

  Widget _buildRemoteVideo() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.user, color: Colors.white10, size: 80),
            const SizedBox(height: 16),
            const Text('Remote Video Stream', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarBackground() {
    return Stack(
      children: [
        if (widget.peerAvatar != null)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.peerAvatar!),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D0A1A), Color(0xFF150D28)],
              ),
            ),
          ),
        
        // Animated Orbs
        _buildOrb(300, const Color(0xFF7C3AED).withOpacity(0.12), const Offset(-50, 100)),
        _buildOrb(250, const Color(0xFF10B981).withOpacity(0.08), const Offset(200, 400)),
      ],
    );
  }

  Widget _buildOrb(double size, Color color, Offset offset) {
    return Positioned(
      left: offset.dx, top: offset.dy,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).move(
      begin: const Offset(0, 0),
      end: const Offset(30, 30),
      duration: 4.seconds,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildTopBar(ActiveCallState callState, CallState status) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.peerName,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (status == CallState.inCall)
                  Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(callState.durationSeconds),
                        style: const TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  )
                else
                  Text(
                    status == CallState.outgoing ? 'Calling...' : (status == CallState.connecting ? 'Connecting...' : ''),
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(LucideIcons.chevronDown, color: Colors.white54),
              onPressed: () {
                // Minimized mode - for now just leave overlay as is but provider can handle it
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallInfo(CallState status) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (status == CallState.inCall && !_isMuted)
              _buildSoundWaves(),
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 50, spreadRadius: 10),
                ],
              ),
              child: ClipOval(
                child: widget.peerAvatar != null
                    ? Image.network(widget.peerAvatar!, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFF1E1B2E),
                        child: Center(
                          child: Text(
                            widget.peerName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 70, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        if (status == CallState.inCall && _isMuted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.micOff, color: Colors.red[300], size: 14),
                const SizedBox(width: 8),
                Text('Microphone Muted', style: TextStyle(color: Colors.red[300], fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ).animate().fadeIn().scale(),
      ],
    );
  }

  Widget _buildSoundWaves() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(3, (i) {
        return Container(
          width: 180, height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3), width: 1.5),
          ),
        ).animate(onPlay: (c) => c.repeat()).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.6, 1.6),
          duration: (1.5 + i * 0.5).seconds,
          curve: Curves.easeOut,
        ).fadeOut(duration: (1.5 + i * 0.5).seconds);
      }),
    );
  }

  Widget _buildDraggablePiP() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _pipOffset = Offset(
            (_pipOffset.dx - details.delta.dx).clamp(20, MediaQuery.of(context).size.width - 120),
            (_pipOffset.dy + details.delta.dy).clamp(100, MediaQuery.of(context).size.height - 250),
          );
        });
      },
      child: Container(
        width: 110, height: 160,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 25)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: _isCameraOff
              ? const Center(child: Icon(LucideIcons.videoOff, color: Colors.white24))
              : Container(
                  color: Colors.grey[850],
                  child: const Center(child: Text('Self View', style: TextStyle(color: Colors.white38, fontSize: 11))),
                ),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildBottomControls(CallState status) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.95), Colors.transparent],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildControlBtn(
                  icon: _isMuted ? LucideIcons.micOff : LucideIcons.mic,
                  label: 'Mute',
                  active: _isMuted,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                if (widget.type == CallType.video)
                  _buildControlBtn(
                    icon: _isCameraOff ? LucideIcons.videoOff : LucideIcons.video,
                    label: 'Video',
                    active: _isCameraOff,
                    onTap: () => setState(() => _isCameraOff = !_isCameraOff),
                  ),
                _buildControlBtn(
                  icon: _isSpeakerOn ? LucideIcons.volume2 : LucideIcons.volumeX,
                  label: 'Speaker',
                  active: !_isSpeakerOn,
                  onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                ),
                _buildControlBtn(
                  icon: LucideIcons.phoneOff,
                  label: 'End',
                  danger: true,
                  onTap: _endCall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    bool active = false,
    bool danger = false,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: 200.ms,
            width: 62, height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: danger
                  ? Colors.red
                  : active ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.12),
              border: Border.all(color: active ? Colors.white30 : Colors.transparent),
              boxShadow: danger ? [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)] : null,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
