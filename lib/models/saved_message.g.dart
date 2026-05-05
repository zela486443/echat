// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavedMessageImpl _$$SavedMessageImplFromJson(Map<String, dynamic> json) =>
    _$SavedMessageImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      messageId: json['message_id'] as String,
      chatId: json['chat_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      note: json['note'] as String?,
      message: json['message'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$SavedMessageImplToJson(_$SavedMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'message_id': instance.messageId,
      'chat_id': instance.chatId,
      'saved_at': instance.savedAt.toIso8601String(),
      'note': instance.note,
      'message': instance.message,
    };
