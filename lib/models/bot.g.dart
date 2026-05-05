// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BotImpl _$$BotImplFromJson(Map<String, dynamic> json) => _$BotImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      description: json['description'] as String?,
      avatarColor: json['avatar_color'] as String,
      createdBy: json['created_by'] as String,
      isActive: json['is_active'] as bool? ?? true,
      commands: (json['commands'] as List<dynamic>?)
              ?.map((e) => BotCommand.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$BotImplToJson(_$BotImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'username': instance.username,
      'description': instance.description,
      'avatar_color': instance.avatarColor,
      'created_by': instance.createdBy,
      'is_active': instance.isActive,
      'commands': instance.commands,
    };

_$BotCommandImpl _$$BotCommandImplFromJson(Map<String, dynamic> json) =>
    _$BotCommandImpl(
      command: json['command'] as String,
      description: json['description'] as String,
      response: json['response'] as String,
    );

Map<String, dynamic> _$$BotCommandImplToJson(_$BotCommandImpl instance) =>
    <String, dynamic>{
      'command': instance.command,
      'description': instance.description,
      'response': instance.response,
    };
