import 'package:freezed_annotation/freezed_annotation.dart';
import 'profile.dart';

part 'etok_video.freezed.dart';
part 'etok_video.g.dart';

@freezed
class EtokVideo with _$EtokVideo {
  const factory EtokVideo({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required String description,
    @Default([]) List<String> hashtags,
    @JsonKey(name: 'sound_name') required String soundName,
    @JsonKey(name: 'video_url') required String videoUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    required double duration,
    @Default(0) int views,
    @Default(0) int likes,
    @Default(0) int comments,
    @Default(0) int shares,
    @Default('everyone') String privacy,
    @JsonKey(name: 'allow_comments') @Default(true) bool allowComments,
    @JsonKey(name: 'allow_duet') @Default(true) bool allowDuet,
    @JsonKey(name: 'allow_stitch') @Default(true) bool allowStitch,
    @JsonKey(name: 'allow_download') @Default(true) bool allowDownload,
    @JsonKey(name: 'is_sponsored') @Default(false) bool isSponsored,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    // Joined profile
    Profile? author,
  }) = _EtokVideo;

  factory EtokVideo.fromJson(Map<String, dynamic> json) => _$EtokVideoFromJson(json);
}
