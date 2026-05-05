import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_message.freezed.dart';
part 'group_message.g.dart';

@freezed
class GroupMessage with _$GroupMessage {
  const factory GroupMessage({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'sender_id') required String senderId,
    String? content,
    @JsonKey(name: 'message_type') @Default('text') String messageType,
    @JsonKey(name: 'media_url') String? mediaUrl,
    @JsonKey(name: 'file_name') String? fileName,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _GroupMessage;

  factory GroupMessage.fromJson(Map<String, dynamic> json) => _$GroupMessageFromJson(json);
}
