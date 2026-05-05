import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/active_call_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/chat_avatar.dart';
import '../../services/call_audio_service.dart';
import '../../widgets/calling_widgets.dart';

class ActiveCallScreen extends ConsumerStatefulWidget {
  const ActiveCallScreen({super.key});

  @override
  ConsumerState<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends ConsumerState<ActiveCallScreen> {
  bool _controlsVisible = true;
  Timer? _hideTimer;
  Offset _pipOffset = const Offset(20, 80);

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final call = ref.read(activeCallProvider);
      if (call.status == CallStatus.outgoingCalling) {
        CallAudioService().playCallingSound();
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _resetHideTimer() {
    setState(() => _controlsVisible = true);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    CallAudioService().stopAll();
    super.dispose();
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final call = ref.watch(activeCallProvider);
    final notifier = ref.read(activeCallProvider.notifier);

    // Stop audio when connected or ended
    ref.listen(activeCallProvider.select((s) => s.status), (prev, next) {
      if (next == CallStatus.inCall || next == CallStatus.callEnded || next == CallStatus.rejected) {
        CallAudioService().stopAll();
      }
    });

    final isVideo = call.callType == 'video';
    final isInCall = call.status == CallStatus.inCall;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _resetHideTimer,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            _buildBackground(call),

            // Top HUD
            AnimatedPositioned(
              duration: 400.ms,
              top: _controlsVisible ? 0 : -100,
              left: 0,
              right: 0,
              child: _buildTopHUD(call),
            ),

            // Center Content (for Voice or before video starts)
            if (!isVideo || !isInCall) 
              Center(child: _buildVoiceContent(call)),

            // Draggable PiP (Local Video)
            if (isVideo && isInCall) _buildDraggablePiP(call),

            // Bottom Controls
            AnimatedPositioned(
              duration: 400.ms,
              bottom: _controlsVisible ? 0 : -250,
              left: 0,
              right: 0,
              child: _buildBottomControls(call, notifier),
            ),

            // Muted Warning
            if (call.isMuted && isInCall)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(child: _buildMutedWarning()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(ActiveCallState call) {
    if (call.status == CallStatus.inCall && call.callType == 'video') {
      return Stack(
        fit: StackFit.expand,
        children: [
          RTCVideoView(
            ref.read(activeCallProvider.notifier).remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          if (call.isBlurBg)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent, Colors.black87],
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF0F172A)),
        if (call.peerAvatar != null)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Opacity(
              opacity: 0.4,
              child: Image.network(call.peerAvatar!, fit: BoxFit.cover),
            ),
          ),
        AuroraBackground(
          blobs: [
            AuroraBlob(
              begin: const Alignment(0.7, -0.5),
              end: const Alignment(-0.7, 0.5),
              size: 400,
              color: Colors.blue.withOpacity(0.1),
              duration: 10.seconds,
            ),
            AuroraBlob(
              begin: const Alignment(-0.7, 0.5),
              end: const Alignment(0.7, -0.5),
              size: 400,
              color: Colors.purple.withOpacity(0.1),
              duration: 12.seconds,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopHUD(ActiveCallState call) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ChatAvatar(name: call.peerName, src: call.peerAvatar, size: 'sm'),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.peerName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      _buildSignalBars(call.connectionState),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(call),
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronDown, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceContent(ActiveCallState call) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (call.status == CallStatus.inCall)
              ...[200.0, 160.0].map((s) => PulsatingRing(size: s, color: Colors.blueAccent)),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: ChatAvatar(name: call.peerName, src: call.peerAvatar, size: 'xl'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        if (call.status == CallStatus.inCall) ...[
          Text(
            _formatDuration(call.durationSeconds),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 20),
          _buildSoundWave(active: !call.isMuted),
        ],
      ],
    );
  }

  Widget _buildDraggablePiP(ActiveCallState call) {
    return Positioned(
      left: _pipOffset.dx,
      top: _pipOffset.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _pipOffset += d.delta),
        child: Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
            boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black54)],
          ),
          clipBehavior: Clip.antiAlias,
          child: call.isCameraOff 
            ? const Center(child: Icon(LucideIcons.videoOff, color: Colors.white24))
            : RTCVideoView(
                ref.read(activeCallProvider.notifier).localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(ActiveCallState call, ActiveCallNotifier notifier) {
    final isVideo = call.callType == 'video';
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 50),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isVideo) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ctrlBtn(LucideIcons.volume2, 'Speaker', call.isSpeakerOn, notifier.toggleSpeaker),
                  _ctrlBtn(LucideIcons.hash, 'Keypad', false, () {}),
                  _ctrlBtn(LucideIcons.userPlus, 'Add', false, () {}),
                  _ctrlBtn(LucideIcons.messageCircle, 'Message', false, () {}),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ctrlBtn(call.isMuted ? LucideIcons.micOff : LucideIcons.mic, 'Mute', call.isMuted, notifier.toggleMute),
                if (isVideo) ...[
                  _ctrlBtn(LucideIcons.monitor, 'Share', call.isScreenSharing, notifier.startScreenShare),
                  _ctrlBtn(LucideIcons.phoneOff, 'End', false, notifier.endCall, danger: true, large: true),
                  _ctrlBtn(LucideIcons.aperture, 'Blur', call.isBlurBg, notifier.toggleBlurBg),
                  _ctrlBtn(call.isCameraOff ? LucideIcons.videoOff : LucideIcons.video, 'Camera', call.isCameraOff, notifier.toggleCamera),
                ] else
                  _ctrlBtn(LucideIcons.phoneOff, 'End', false, notifier.endCall, danger: true, large: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, String label, bool active, VoidCallback onTap, {bool danger = false, bool large = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: large ? 72 : 56,
            height: large ? 72 : 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: danger ? Colors.red : (active ? Colors.white : Colors.white10),
            ),
            child: Icon(icon, color: active || danger ? Colors.white : Colors.white70, size: large ? 32 : 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildSignalBars(RTCPeerConnectionState state) {
    int bars = 0;
    Color color = Colors.red;
    if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      bars = 4;
      color = Colors.green;
    } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
      bars = 2;
      color = Colors.yellow;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) => Container(
        width: 3,
        height: 4 + (i * 3),
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: i < bars ? color : Colors.white12,
          borderRadius: BorderRadius.circular(1),
        ),
      )),
    );
  }

  Widget _buildSoundWave({required bool active}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (i) => AnimatedContainer(
        duration: 200.ms,
        width: 4,
        height: active ? (10 + (i % 3) * 10).toDouble() : 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(2),
        ),
      )),
    );
  }

  Widget _buildMutedWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(LucideIcons.micOff, color: Colors.red, size: 14),
          SizedBox(width: 8),
          Text('Microphone muted', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn().shake();
  }

  String _getStatusText(ActiveCallState call) {
    switch (call.status) {
      case CallStatus.outgoingCalling: return 'Calling…';
      case CallStatus.incomingRinging: return 'Incoming Call…';
      case CallStatus.connecting: return 'Connecting…';
      case CallStatus.inCall: return 'Connected';
      case CallStatus.callEnded: return 'Call ended';
      case CallStatus.callFailed: return 'Call failed';
      case CallStatus.rejected: return 'Call declined';
      case CallStatus.missed: return 'No answer';
      case CallStatus.busy: return 'Busy';
      default: return '';
    }
  }
}
