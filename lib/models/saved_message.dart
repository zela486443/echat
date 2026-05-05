import 'package:freezed_annotation/freezed_annotation.dart';


part 'saved_message.freezed.dart';
part 'saved_message.g.dart';

@freezed
class SavedMessage with _$SavedMessage {
  const factory SavedMessage({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'message_id') required String messageId,
    @JsonKey(name: 'chat_id') required String chatId,
    @JsonKey(name: 'saved_at') required DateTime savedAt,
    String? note,
    // Optional joined data
    Map<String, dynamic>? message,
  }) = _SavedMessage;

  factory SavedMessage.fromJson(Map<String, dynamic> json) => _$SavedMessageFromJson(json);
}
