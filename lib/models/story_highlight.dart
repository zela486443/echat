import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_highlight.freezed.dart';
part 'story_highlight.g.dart';

@freezed
class StoryHighlight with _$StoryHighlight {
  const factory StoryHighlight({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'cover_color') required String coverColor,
    @Default([]) List<String> storyIds,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _StoryHighlight;

  factory StoryHighlight.fromJson(Map<String, dynamic> json) => _$StoryHighlightFromJson(json);
}
