import 'package:freezed_annotation/freezed_annotation.dart';
import 'reaction.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  @JsonValue('text') text,
  @JsonValue('image') image,
  @JsonValue('file') file,
  @JsonValue('voice') voice,
  @JsonValue('video_message') videoMessage,
  @JsonValue('poll') poll,
  @JsonValue('checklist') checklist,
  @JsonValue('sticker') sticker,
  @JsonValue('gift') gift,
  @JsonValue('location') location,
  @JsonValue('bill_split') billSplit,
}

enum MessageStatus {
  @JsonValue('sending') sending,
  @JsonValue('sent') sent,
  @JsonValue('delivered') delivered,
  @JsonValue('read') read,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'receiver_id') required String receiverId,
    String? content,
    @JsonKey(name: 'message_type') required MessageType messageType,
    @JsonKey(name: 'media_url') String? mediaUrl,
    @JsonKey(name: 'file_name') String? fileName,
    required MessageStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default([]) List<MessageReaction> reactions,
    Map<String, dynamic>? metadata,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}
