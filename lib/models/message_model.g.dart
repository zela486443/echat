// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      text: json['text'] as String,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      mediaUrl: json['media_url'] as String?,
      pollData: json['poll_data'] as Map<String, dynamic>?,
      billSplitData: json['bill_split_data'] as Map<String, dynamic>?,
      locationData: json['location_data'] as Map<String, dynamic>?,
      isEdited: json['is_edited'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_id': instance.chatId,
      'sender_id': instance.senderId,
      'text': instance.text,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'media_url': instance.mediaUrl,
      'poll_data': instance.pollData,
      'bill_split_data': instance.billSplitData,
      'location_data': instance.locationData,
      'is_edited': instance.isEdited,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.voice: 'voice',
  MessageType.poll: 'poll',
  MessageType.bill_split: 'bill_split',
  MessageType.sticker: 'sticker',
  MessageType.gif: 'gif',
  MessageType.location: 'location',
};
