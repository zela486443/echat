import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/call_service.dart';
import '../services/webrtc_service.dart';
import '../services/call_signaling_service.dart';
import 'auth_provider.dart';

enum CallStatus { 
  idle, 
  outgoingCalling, 
  connecting, 
  inCall, 
  incomingRinging, 
  callEnded, 
  callFailed, 
  rejected, 
  missed, 
  busy 
}

class ActiveCallState {
  final CallStatus status;
  final String? peerId;
  final String peerName;
  final String? peerAvatar;
  final String callType; // 'voice' or 'video'
  final String? roomId;
  final int durationSeconds;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final bool isScreenSharing;
  final bool isBlurBg;
  final String? errorMessage;
  final RTCPeerConnectionState connectionState;

  ActiveCallState({
    this.status = CallStatus.idle,
    this.peerId,
    this.peerName = 'Unknown',
    this.peerAvatar,
    this.callType = 'voice',
    this.roomId,
    this.durationSeconds = 0,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
    this.isScreenSharing = false,
    this.isBlurBg = false,
    this.errorMessage,
    this.connectionState = RTCPeerConnectionState.RTCPeerConnectionStateIdle,
  });

  ActiveCallState copyWith({
    CallStatus? status,
    String? peerId,
    String? peerName,
    String? peerAvatar,
    String? callType,
    String? roomId,
    int? durationSeconds,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
    bool? isScreenSharing,
    bool? isBlurBg,
    String? errorMessage,
    RTCPeerConnectionState? connectionState,
  }) {
    return ActiveCallState(
      status: status ?? this.status,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      callType: callType ?? this.callType,
      roomId: roomId ?? this.roomId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isBlurBg: isBlurBg ?? this.isBlurBg,
      errorMessage: errorMessage ?? this.errorMessage,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}

class ActiveCallNotifier extends StateNotifier<ActiveCallState> {
  final Ref ref;
  final WebRTCService _webRTCService = WebRTCService();
  final CallSignalingService _signalingService = CallSignalingService();
  final CallService _callService = CallService();

  Timer? _timer;
  Timer? _timeoutTimer;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  
  RTCSessionDescription? _pendingOffer;

  ActiveCallNotifier(this.ref) : super(ActiveCallState()) {
    _initRenderers();
    _listenToAuth();
  }

  Future<void> _initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  void _listenToAuth() {
    ref.listen(authProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        _setupSignaling(user.id);
      } else {
        _signalingService.cleanup();
      }
    });
    
    final user = ref.read(authProvider).value;
    if (user != null) _setupSignaling(user.id);
  }

  void _setupSignaling(String userId) {
    _signalingService.subscribeToSignaling(userId);
    
    _signalingService.onIncomingCall = (offer) {
      if (state.status != CallStatus.idle) {
        _signalingService.sendCallState(
          targetId: offer.callerId, 
          type: 'busy', 
          roomId: offer.roomId, 
          senderId: userId
        );
        return;
      }

      _pendingOffer = offer.offer;
      state = state.copyWith(
        status: CallStatus.incomingRinging,
        peerId: offer.callerId,
        peerName: offer.callerName,
        peerAvatar: offer.callerAvatar,
        callType: offer.callType,
        roomId: offer.roomId,
      );
      
      _startTimeoutTimer();
    };

    _signalingService.onCallAnswer = (answer, roomId) async {
      if (state.roomId == roomId && state.status == CallStatus.outgoingCalling) {
        await _webRTCService.handleAnswer(answer);
        state = state.copyWith(status: CallStatus.inCall);
        _startTimer();
      }
    };

    _signalingService.onIceCandidate = (candidate, roomId) {
      if (state.roomId == roomId) {
        _webRTCService.addIceCandidate(candidate);
      }
    };

    _signalingService.onCallStateChange = (type, roomId, senderId) {
      if (state.roomId == roomId) {
        if (type == 'rejected' || type == 'busy' || type == 'timeout') {
          _cleanupCall(type == 'rejected' ? CallStatus.rejected : (type == 'busy' ? CallStatus.busy : CallStatus.missed));
        } else if (type == 'ended') {
          _cleanupCall(CallStatus.callEnded);
        }
      }
    };

    _webRTCService.onIceCandidate = (candidate) {
      final user = ref.read(authProvider).value;
      if (user != null && state.peerId != null && state.roomId != null) {
        _signalingService.sendIceCandidate(
          targetId: state.peerId!, 
          candidate: candidate, 
          roomId: state.roomId!, 
          senderId: user.id
        );
      }
    };

    _webRTCService.onAddRemoteStream = (stream) {
      remoteRenderer.srcObject = stream;
    };

    _webRTCService.onConnectionState = (connState) {
      state = state.copyWith(connectionState: connState);
      if (connState == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _cleanupCall(CallStatus.callFailed);
      }
    };
  }

  Future<void> startCall(String peerId, String peerName, String? peerAvatar, String callType) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    state = state.copyWith(
      status: CallStatus.outgoingCalling,
      peerId: peerId,
      peerName: peerName,
      peerAvatar: peerAvatar,
      callType: callType,
    );

    try {
      final stream = await _webRTCService.getUserMedia(isVideo: callType == 'video');
      localRenderer.srcObject = stream;

      await _webRTCService.createConnection();
      final offer = await _webRTCService.createOffer();
      
      final roomId = await _signalingService.sendCallOffer(
        callerId: user.id,
        receiverId: peerId,
        offer: offer,
        callType: callType,
        callerName: user.name ?? 'User',
        callerAvatar: user.avatarUrl,
      );

      state = state.copyWith(roomId: roomId);
      _startTimeoutTimer();
      
      // Initial log
      await _callService.logCall(
        callerId: user.id,
        receiverId: peerId,
        type: callType,
        status: 'missed',
        roomId: roomId,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      _cleanupCall(CallStatus.callFailed);
    }
  }

  Future<void> acceptCall() async {
    if (state.status != CallStatus.incomingRinging || _pendingOffer == null) return;
    _timeoutTimer?.cancel();

    final user = ref.read(authProvider).value;
    if (user == null || state.peerId == null || state.roomId == null) return;

    try {
      state = state.copyWith(status: CallStatus.connecting);
      
      final stream = await _webRTCService.getUserMedia(isVideo: state.callType == 'video');
      localRenderer.srcObject = stream;

      await _webRTCService.createConnection();
      final answer = await _webRTCService.handleOffer(_pendingOffer!);
      
      await _signalingService.sendCallAnswer(
        callerId: state.peerId!, 
        answer: answer, 
        roomId: state.roomId!
      );

      state = state.copyWith(status: CallStatus.inCall);
      _startTimer();
      _pendingOffer = null;
      
      await _callService.updateCallLogStatus(state.roomId!, 'completed');
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      _cleanupCall(CallStatus.callFailed);
    }
  }

  void rejectCall() {
    final user = ref.read(authProvider).value;
    if (user != null && state.peerId != null && state.roomId != null) {
      _signalingService.sendCallState(
        targetId: state.peerId!, 
        type: 'rejected', 
        roomId: state.roomId!, 
        senderId: user.id
      );
      _callService.updateCallLogStatus(state.roomId!, 'rejected');
    }
    _cleanupCall(CallStatus.rejected);
  }

  void endCall() {
    final user = ref.read(authProvider).value;
    if (user != null && state.peerId != null && state.roomId != null) {
      _signalingService.sendCallState(
        targetId: state.peerId!, 
        type: 'ended', 
        roomId: state.roomId!, 
        senderId: user.id
      );
      final finalStatus = state.status == CallStatus.inCall ? 'completed' : 'missed';
      _callService.updateCallLogStatus(state.roomId!, finalStatus, state.durationSeconds);
    }
    _cleanupCall(CallStatus.callEnded);
  }

  void toggleMute() {
    _webRTCService.toggleMute(!state.isMuted);
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleCamera() {
    _webRTCService.toggleCamera(!state.isCameraOff);
    state = state.copyWith(isCameraOff: !state.isCameraOff);
  }

  void toggleSpeaker() {
    _webRTCService.toggleSpeaker(!state.isSpeakerOn);
    state = state.copyWith(isSpeakerOn: !state.isSpeakerOn);
  }

  Future<void> flipCamera() async {
    await _webRTCService.switchCamera();
  }

  Future<void> startScreenShare() async {
    try {
      final stream = await _webRTCService.getScreenShare();
      await _webRTCService.replaceVideoTrack(stream);
      state = state.copyWith(isScreenSharing: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void toggleBlurBg() {
    state = state.copyWith(isBlurBg: !state.isBlurBg);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(durationSeconds: state.durationSeconds + 1);
    });
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 45), () {
      if (state.status == CallStatus.outgoingCalling || state.status == CallStatus.incomingRinging) {
        final user = ref.read(authProvider).value;
        if (user != null && state.peerId != null && state.roomId != null) {
          _signalingService.sendCallState(
            targetId: state.peerId!, 
            type: 'timeout', 
            roomId: state.roomId!, 
            senderId: user.id
          );
        }
        _cleanupCall(CallStatus.missed);
      }
    });
  }

  void _cleanupCall(CallStatus endStatus) {
    _timer?.cancel();
    _timeoutTimer?.cancel();
    _webRTCService.cleanup();
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    _pendingOffer = null;
    
    state = state.copyWith(status: endStatus);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = ActiveCallState();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeoutTimer?.cancel();
    localRenderer.dispose();
    remoteRenderer.dispose();
    _webRTCService.cleanup();
    _signalingService.cleanup();
    super.dispose();
  }
}

final activeCallProvider = StateNotifierProvider<ActiveCallNotifier, ActiveCallState>((ref) {
  return ActiveCallNotifier(ref);
});
