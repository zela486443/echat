// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VoiceRoomImpl _$$VoiceRoomImplFromJson(Map<String, dynamic> json) =>
    _$VoiceRoomImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
      createdBy: json['created_by'] as String,
      isActive: json['is_active'] as bool? ?? true,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => VoiceParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$VoiceRoomImplToJson(_$VoiceRoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'group_id': instance.groupId,
      'group_name': instance.groupName,
      'created_by': instance.createdBy,
      'is_active': instance.isActive,
      'participants': instance.participants,
    };

_$VoiceParticipantImpl _$$VoiceParticipantImplFromJson(
        Map<String, dynamic> json) =>
    _$VoiceParticipantImpl(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      isMuted: json['is_muted'] as bool? ?? true,
      isSpeaking: json['is_speaking'] as bool? ?? false,
      isHandRaised: json['is_hand_raised'] as bool? ?? false,
    );

Map<String, dynamic> _$$VoiceParticipantImplToJson(
        _$VoiceParticipantImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'is_muted': instance.isMuted,
      'is_speaking': instance.isSpeaking,
      'is_hand_raised': instance.isHandRaised,
    };
