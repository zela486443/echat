import 'package:freezed_annotation/freezed_annotation.dart';

part 'bot.freezed.dart';
part 'bot.g.dart';

@freezed
class Bot with _$Bot {
  const factory Bot({
    required String id,
    required String name,
    required String username,
    String? description,
    @JsonKey(name: 'avatar_color') required String avatarColor,
    @JsonKey(name: 'created_by') required String createdBy,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @Default([]) List<BotCommand> commands,
  }) = _Bot;

  factory Bot.fromJson(Map<String, dynamic> json) => _$BotFromJson(json);
}

@freezed
class BotCommand with _$BotCommand {
  const factory BotCommand({
    required String command,
    required String description,
    required String response,
  }) = _BotCommand;

  factory BotCommand.fromJson(Map<String, dynamic> json) => _$BotCommandFromJson(json);
}
