import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_room.freezed.dart';
part 'voice_room.g.dart';

@freezed
class VoiceRoom with _$VoiceRoom {
  const factory VoiceRoom({
    required String id,
    required String title,
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'group_name') required String groupName,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @Default([]) List<VoiceParticipant> participants,
  }) = _VoiceRoom;

  factory VoiceRoom.fromJson(Map<String, dynamic> json) => _$VoiceRoomFromJson(json);
}

@freezed
class VoiceParticipant with _$VoiceParticipant {
  const factory VoiceParticipant({
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'is_muted') @Default(true) bool isMuted,
    @JsonKey(name: 'is_speaking') @Default(false) bool isSpeaking,
    @JsonKey(name: 'is_hand_raised') @Default(false) bool isHandRaised,
  }) = _VoiceParticipant;

  factory VoiceParticipant.fromJson(Map<String, dynamic> json) => _$VoiceParticipantFromJson(json);
}
