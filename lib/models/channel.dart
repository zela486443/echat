import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel.freezed.dart';
part 'channel.g.dart';

@freezed
class Channel with _$Channel {
  const factory Channel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'avatar_color') required String avatarColor,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'subscriber_count') @Default(0) int subscriberCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Channel;

  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);
}
