// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryImpl _$$StoryImplFromJson(Map<String, dynamic> json) => _$StoryImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String?,
      mediaUrl: json['media_url'] as String?,
      storyType: json['story_type'] as String,
      backgroundColor: json['background_color'] as String,
      viewsCount: (json['views_count'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$$StoryImplToJson(_$StoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'content': instance.content,
      'media_url': instance.mediaUrl,
      'story_type': instance.storyType,
      'background_color': instance.backgroundColor,
      'views_count': instance.viewsCount,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
    };
