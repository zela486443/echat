// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_highlight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryHighlightImpl _$$StoryHighlightImplFromJson(Map<String, dynamic> json) =>
    _$StoryHighlightImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      coverColor: json['cover_color'] as String,
      storyIds: (json['storyIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$StoryHighlightImplToJson(
        _$StoryHighlightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'cover_color': instance.coverColor,
      'storyIds': instance.storyIds,
      'created_at': instance.createdAt.toIso8601String(),
    };
