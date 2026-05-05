import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String id,
    @JsonKey(name: 'participant_1') required String participant1,
    @JsonKey(name: 'participant_2') required String participant2,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
    @JsonKey(name: 'last_sender_id') String? lastSenderId,
    @JsonKey(name: 'unread_count_1') @Default(0) int unreadCount1,
    @JsonKey(name: 'unread_count_2') @Default(0) int unreadCount2,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}
