import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallOffer {
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String callType; // 'voice' or 'video'
  final RTCSessionDescription offer;
  final String roomId;

  CallOffer({
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.callType,
    required this.offer,
    required this.roomId,
  });
}

class CallSignalingService {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _channel;
  String? _currentUserId;
  Timer? _reconnectTimer;
  bool _isDisposed = false;

  // Callbacks
  Function(CallOffer)? onIncomingCall;
  Function(RTCSessionDescription, String)? onCallAnswer;
  Function(RTCIceCandidate, String)? onIceCandidate;
  Function(String eventType, String roomId, String senderId)? onCallStateChange;

  void subscribeToSignaling(String userId) {
    if (_isDisposed) return;
    _currentUserId = userId;
    _cleanupChannel();

    _channel = _client.channel('calls:$userId', 
      opts: const RealtimeChannelConfig(self: false),
    );

    _channel!
      .onBroadcast(event: 'call_offer', callback: (payload) {
        final offer = RTCSessionDescription(payload['offer']['sdp'], payload['offer']['type']);
        onIncomingCall?.call(CallOffer(
          callerId: payload['callerId'],
          callerName: payload['callerName'],
          callerAvatar: payload['callerAvatar'],
          callType: payload['callType'],
          offer: offer,
          roomId: payload['roomId'],
        ));
      })
      .onBroadcast(event: 'call_answer', callback: (payload) {
        final answer = RTCSessionDescription(payload['answer']['sdp'], payload['answer']['type']);
        onCallAnswer?.call(answer, payload['roomId']);
      })
      .onBroadcast(event: 'ice_candidate', callback: (payload) {
        final candidateData = payload['candidate'];
        final candidate = RTCIceCandidate(
          candidateData['candidate'],
          candidateData['sdpMid'],
          candidateData['sdpMLineIndex'],
        );
        onIceCandidate?.call(candidate, payload['roomId']);
      })
      .onBroadcast(event: 'call_state', callback: (payload) {
        onCallStateChange?.call(payload['type'], payload['roomId'], payload['senderId']);
      })
      .subscribe((status, [error]) {
        if (status == RealtimeSubscribeStatus.channelError || status == RealtimeSubscribeStatus.closed) {
          _handleReconnect();
        }
      });
  }

  void _handleReconnect() {
    if (_isDisposed || _currentUserId == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      if (!_isDisposed && _currentUserId != null) {
        subscribeToSignaling(_currentUserId!);
      }
    });
  }

  Future<String> sendCallOffer({
    required String callerId,
    required String receiverId,
    required RTCSessionDescription offer,
    required String callType,
    required String callerName,
    String? callerAvatar,
    String? roomId,
  }) async {
    final finalRoomId = roomId ?? 'call_${callerId}_${receiverId}_${DateTime.now().millisecondsSinceEpoch}';
    final targetChannel = _client.channel('calls:$receiverId', opts: const RealtimeChannelConfig(self: false));
    
    await _sendMessage(targetChannel, 'call_offer', {
      'callerId': callerId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'callType': callType,
      'offer': {'type': offer.type, 'sdp': offer.sdp},
      'roomId': finalRoomId,
    });
    
    return finalRoomId;
  }

  Future<void> sendCallAnswer({
    required String callerId,
    required RTCSessionDescription answer,
    required String roomId,
  }) async {
    final targetChannel = _client.channel('calls:$callerId', opts: const RealtimeChannelConfig(self: false));
    await _sendMessage(targetChannel, 'call_answer', {
      'answer': {'type': answer.type, 'sdp': answer.sdp},
      'roomId': roomId,
    });
  }

  Future<void> sendIceCandidate({
    required String targetId,
    required RTCIceCandidate candidate,
    required String roomId,
    required String senderId,
  }) async {
    final targetChannel = _client.channel('calls:$targetId', opts: const RealtimeChannelConfig(self: false));
    await _sendMessage(targetChannel, 'ice_candidate', {
      'candidate': {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      },
      'senderId': senderId,
      'roomId': roomId,
    });
  }

  Future<void> sendCallState({
    required String targetId,
    required String type, // 'rejected', 'ended', 'busy', 'timeout'
    required String roomId,
    required String senderId,
  }) async {
    final targetChannel = _client.channel('calls:$targetId', opts: const RealtimeChannelConfig(self: false));
    await _sendMessage(targetChannel, 'call_state', {
      'type': type,
      'roomId': roomId,
      'senderId': senderId,
    });
  }

  Future<void> _sendMessage(RealtimeChannel channel, String event, Map<String, dynamic> payload) async {
    final completer = Completer<void>();
    channel.subscribe((status, [error]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await channel.sendBroadcastMessage(event: event, payload: payload);
        completer.complete();
        Future.delayed(const Duration(seconds: 1), () => channel.unsubscribe());
      } else if (error != null) {
        completer.completeError(error);
      }
    });
    return completer.future.timeout(const Duration(seconds: 5));
  }

  void _cleanupChannel() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void cleanup() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _cleanupChannel();
  }
}

