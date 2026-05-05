import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType { text, image, video, voice, poll, bill_split, sticker, gif, location }

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'chat_id') required String chatId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String text,
    @Default(MessageType.text) MessageType type,
    
    // Complex state payload mapped from React components
    @JsonKey(name: 'media_url') String? mediaUrl,
    @JsonKey(name: 'poll_data') Map<String, dynamic>? pollData,
    @JsonKey(name: 'bill_split_data') Map<String, dynamic>? billSplitData,
    @JsonKey(name: 'location_data') Map<String, dynamic>? locationData,
    
    @JsonKey(name: 'is_edited') @Default(false) bool isEdited,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}
