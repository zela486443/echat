import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  // Callbacks
  Function(RTCIceCandidate)? onIceCandidate;
  Function(MediaStream)? onAddRemoteStream;
  Function(RTCPeerConnectionState)? onConnectionState;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {
        'urls': 'turn:openrelay.metered.ca:80',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
      {
        'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
        'username': 'openrelayproject',
        'credential': 'openrelayproject',
      },
    ],
    'iceCandidatePoolSize': 10,
  };

  Future<MediaStream> getUserMedia({required bool isVideo}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': isVideo ? {
        'facingMode': 'user',
        'width': {'min': 640},
        'height': {'min': 480},
      } : false,
    };

    try {
      if (isVideo) {
        await [Permission.camera, Permission.microphone].request();
      } else {
        await Permission.microphone.request();
      }
      
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      return localStream!;
    } catch (e) {
      throw Exception('Failed to access camera or microphone: $e');
    }
  }

  Future<MediaStream> getScreenShare() async {
    try {
      final stream = await navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': false,
      });
      return stream;
    } catch (e) {
      throw Exception('Failed to start screen share: $e');
    }
  }

  Future<RTCPeerConnection> createConnection() async {
    peerConnection?.close();
    peerConnection = await createPeerConnection(_iceServers);

    peerConnection!.onIceCandidate = (candidate) {
      onIceCandidate?.call(candidate);
    };

    peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
        onAddRemoteStream?.call(remoteStream!);
      }
    };

    peerConnection!.onConnectionState = (state) {
      onConnectionState?.call(state);
    };

    if (localStream != null) {
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });
    }

    return peerConnection!;
  }

  Future<RTCSessionDescription> createOffer() async {
    if (peerConnection == null) throw Exception('Peer connection is null');
    final offer = await peerConnection!.createOffer({
      'offerToReceiveAudio': 1,
      'offerToReceiveVideo': 1,
    });
    await peerConnection!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> handleOffer(RTCSessionDescription offer) async {
    if (peerConnection == null) throw Exception('Peer connection is null');
    await peerConnection!.setRemoteDescription(offer);
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    return answer;
  }

  Future<void> handleAnswer(RTCSessionDescription answer) async {
    if (peerConnection == null) throw Exception('Peer connection is null');
    await peerConnection!.setRemoteDescription(answer);
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    if (peerConnection == null) return;
    await peerConnection!.addCandidate(candidate);
  }

  void toggleMute(bool isMuted) {
    localStream?.getAudioTracks().forEach((track) => track.enabled = !isMuted);
  }

  void toggleCamera(bool isCameraOff) {
    localStream?.getVideoTracks().forEach((track) => track.enabled = !isCameraOff);
  }

  Future<void> switchCamera() async {
    final videoTrack = localStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
    }
  }

  void toggleSpeaker(bool isSpeakerOn) {
    Helper.setSpeakerphoneOn(isSpeakerOn);
  }

  Future<void> replaceVideoTrack(MediaStream newStream) async {
    if (peerConnection == null) return;
    
    final newVideoTrack = newStream.getVideoTracks().first;
    final senders = await peerConnection!.getSenders();
    
    for (var sender in senders) {
      if (sender.track?.kind == 'video') {
        await sender.replaceTrack(newVideoTrack);
      }
    }
    
    // Update local stream reference for UI
    final oldTracks = localStream?.getVideoTracks() ?? [];
    for (var track in oldTracks) {
      track.stop();
    }
    
    // Note: In a real app, you'd want to merge tracks properly
    // For now, we'll just swap the video track in the localStream if possible
  }

  void cleanup() {
    localStream?.getTracks().forEach((track) => track.stop());
    localStream?.dispose();
    remoteStream?.getTracks().forEach((track) => track.stop());
    remoteStream?.dispose();
    peerConnection?.close();
    
    localStream = null;
    remoteStream = null;
    peerConnection = null;
  }
}

