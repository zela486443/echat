import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../application/webrtc_controller.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String remoteUserId;
  final bool isVideo;

  const CallScreen({super.key, required this.remoteUserId, this.isVideo = true});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _isMuted = false;
  bool _isVideoOff = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    
    await ref.read(webrtcControllerProvider.notifier).initializeCall();
    final controller = ref.read(webrtcControllerProvider.notifier);
    
    setState(() {
      _localRenderer.srcObject = controller.localStream;
      _remoteRenderer.srcObject = controller.remoteStream;
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _endCall() async {
    await ref.read(webrtcControllerProvider.notifier).endCall();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video Fullscreen
          if (widget.isVideo)
             Positioned.fill(
                child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
             )
          else 
            const Center(child: CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60))),
          
          // Local Video Picture-in-Picture
          if (widget.isVideo)
            Positioned(
              top: 60, right: 20,
              width: 100, height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: RTCVideoView(_localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
              ),
            ),
            
          // Call Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlBtn(
                    icon: _isMuted ? LucideIcons.micOff : LucideIcons.mic,
                    color: _isMuted ? Colors.white : Colors.grey.shade800,
                    iconColor: _isMuted ? Colors.black : Colors.white,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  _ControlBtn(
                    icon: _isVideoOff ? LucideIcons.videoOff : LucideIcons.video,
                    color: _isVideoOff ? Colors.white : Colors.grey.shade800,
                    iconColor: _isVideoOff ? Colors.black : Colors.white,
                    onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                  ),
                  _ControlBtn(
                    icon: LucideIcons.phoneOff,
                    color: Colors.redAccent,
                    iconColor: Colors.white,
                    size: 64,
                    onTap: _endCall,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _ControlBtn({required IconData icon, required Color color, required Color iconColor, required VoidCallback onTap, double size = 56}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }
}
