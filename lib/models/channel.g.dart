// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChannelImpl _$$ChannelImplFromJson(Map<String, dynamic> json) =>
    _$ChannelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      avatarColor: json['avatar_color'] as String,
      createdBy: json['created_by'] as String,
      subscriberCount: (json['subscriber_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ChannelImplToJson(_$ChannelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'avatar_color': instance.avatarColor,
      'created_by': instance.createdBy,
      'subscriber_count': instance.subscriberCount,
      'created_at': instance.createdAt.toIso8601String(),
    };
