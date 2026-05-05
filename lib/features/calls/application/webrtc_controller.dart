import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/providers.dart';

final webrtcControllerProvider = AsyncNotifierProvider<WebRTCController, void>(() {
  return WebRTCController();
});

class WebRTCController extends AsyncNotifier<void> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> initializeCall() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final config = {
        'iceServers': [
          {'urls': ['stun:stun1.l.google.com:19302', 'stun:stun2.l.google.com:19302']}
        ]
      };
      
      _peerConnection = await createPeerConnection(config);
      
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': 'user',
        }
      });

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onAddStream = (MediaStream stream) {
        _remoteStream = stream;
        // Signal UI update for remote stream
        ref.notifyListeners();
      };
    });
  }

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  Future<void> endCall() async {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.close();
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
  }
}
