import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_log.freezed.dart';
part 'call_log.g.dart';

@freezed
class CallLog with _$CallLog {
  const factory CallLog({
    required String id,
    @JsonKey(name: 'caller_id') required String callerId,
    @JsonKey(name: 'receiver_id') required String receiverId,
    @JsonKey(name: 'call_type') required String callType, // 'voice' or 'video'
    required String status, // 'completed', 'missed', 'rejected', 'failed'
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Joined profile data
    Map<String, dynamic>? caller,
    Map<String, dynamic>? receiver,
  }) = _CallLog;

  factory CallLog.fromJson(Map<String, dynamic> json) => _$CallLogFromJson(json);
}
