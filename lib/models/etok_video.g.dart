// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'etok_video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EtokVideoImpl _$$EtokVideoImplFromJson(Map<String, dynamic> json) =>
    _$EtokVideoImpl(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      description: json['description'] as String,
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      soundName: json['sound_name'] as String,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: (json['duration'] as num).toDouble(),
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      privacy: json['privacy'] as String? ?? 'everyone',
      allowComments: json['allow_comments'] as bool? ?? true,
      allowDuet: json['allow_duet'] as bool? ?? true,
      allowStitch: json['allow_stitch'] as bool? ?? true,
      allowDownload: json['allow_download'] as bool? ?? true,
      isSponsored: json['is_sponsored'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      author: json['author'] == null
          ? null
          : Profile.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$EtokVideoImplToJson(_$EtokVideoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': instance.authorId,
      'description': instance.description,
      'hashtags': instance.hashtags,
      'sound_name': instance.soundName,
      'video_url': instance.videoUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'duration': instance.duration,
      'views': instance.views,
      'likes': instance.likes,
      'comments': instance.comments,
      'shares': instance.shares,
      'privacy': instance.privacy,
      'allow_comments': instance.allowComments,
      'allow_duet': instance.allowDuet,
      'allow_stitch': instance.allowStitch,
      'allow_download': instance.allowDownload,
      'is_sponsored': instance.isSponsored,
      'created_at': instance.createdAt.toIso8601String(),
      'author': instance.author,
    };
