// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CallLogImpl _$$CallLogImplFromJson(Map<String, dynamic> json) =>
    _$CallLogImpl(
      id: json['id'] as String,
      callerId: json['caller_id'] as String,
      receiverId: json['receiver_id'] as String,
      callType: json['call_type'] as String,
      status: json['status'] as String,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      caller: json['caller'] as Map<String, dynamic>?,
      receiver: json['receiver'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$CallLogImplToJson(_$CallLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'caller_id': instance.callerId,
      'receiver_id': instance.receiverId,
      'call_type': instance.callType,
      'status': instance.status,
      'duration_seconds': instance.durationSeconds,
      'created_at': instance.createdAt.toIso8601String(),
      'caller': instance.caller,
      'receiver': instance.receiver,
    };
