// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Bot _$BotFromJson(Map<String, dynamic> json) {
  return _Bot.fromJson(json);
}

/// @nodoc
mixin _$Bot {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_color')
  String get avatarColor => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  List<BotCommand> get commands => throw _privateConstructorUsedError;

  /// Serializes this Bot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BotCopyWith<Bot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BotCopyWith<$Res> {
  factory $BotCopyWith(Bot value, $Res Function(Bot) then) =
      _$BotCopyWithImpl<$Res, Bot>;
  @useResult
  $Res call(
      {String id,
      String name,
      String username,
      String? description,
      @JsonKey(name: 'avatar_color') String avatarColor,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'is_active') bool isActive,
      List<BotCommand> commands});
}

/// @nodoc
class _$BotCopyWithImpl<$Res, $Val extends Bot> implements $BotCopyWith<$Res> {
  _$BotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? description = freezed,
    Object? avatarColor = null,
    Object? createdBy = null,
    Object? isActive = null,
    Object? commands = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarColor: null == avatarColor
          ? _value.avatarColor
          : avatarColor // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      commands: null == commands
          ? _value.commands
          : commands // ignore: cast_nullable_to_non_nullable
              as List<BotCommand>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BotImplCopyWith<$Res> implements $BotCopyWith<$Res> {
  factory _$$BotImplCopyWith(_$BotImpl value, $Res Function(_$BotImpl) then) =
      __$$BotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String username,
      String? description,
      @JsonKey(name: 'avatar_color') String avatarColor,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'is_active') bool isActive,
      List<BotCommand> commands});
}

/// @nodoc
class __$$BotImplCopyWithImpl<$Res> extends _$BotCopyWithImpl<$Res, _$BotImpl>
    implements _$$BotImplCopyWith<$Res> {
  __$$BotImplCopyWithImpl(_$BotImpl _value, $Res Function(_$BotImpl) _then)
      : super(_value, _then);

  /// Create a copy of Bot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? username = null,
    Object? description = freezed,
    Object? avatarColor = null,
    Object? createdBy = null,
    Object? isActive = null,
    Object? commands = null,
  }) {
    return _then(_$BotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarColor: null == avatarColor
          ? _value.avatarColor
          : avatarColor // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      commands: null == commands
          ? _value._commands
          : commands // ignore: cast_nullable_to_non_nullable
              as List<BotCommand>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BotImpl implements _Bot {
  const _$BotImpl(
      {required this.id,
      required this.name,
      required this.username,
      this.description,
      @JsonKey(name: 'avatar_color') required this.avatarColor,
      @JsonKey(name: 'created_by') required this.createdBy,
      @JsonKey(name: 'is_active') this.isActive = true,
      final List<BotCommand> commands = const []})
      : _commands = commands;

  factory _$BotImpl.fromJson(Map<String, dynamic> json) =>
      _$$BotImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String username;
  @override
  final String? description;
  @override
  @JsonKey(name: 'avatar_color')
  final String avatarColor;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<BotCommand> _commands;
  @override
  @JsonKey()
  List<BotCommand> get commands {
    if (_commands is EqualUnmodifiableListView) return _commands;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commands);
  }

  @override
  String toString() {
    return 'Bot(id: $id, name: $name, username: $username, description: $description, avatarColor: $avatarColor, createdBy: $createdBy, isActive: $isActive, commands: $commands)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.avatarColor, avatarColor) ||
                other.avatarColor == avatarColor) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality().equals(other._commands, _commands));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      username,
      description,
      avatarColor,
      createdBy,
      isActive,
      const DeepCollectionEquality().hash(_commands));

  /// Create a copy of Bot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BotImplCopyWith<_$BotImpl> get copyWith =>
      __$$BotImplCopyWithImpl<_$BotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BotImplToJson(
      this,
    );
  }
}

abstract class _Bot implements Bot {
  const factory _Bot(
      {required final String id,
      required final String name,
      required final String username,
      final String? description,
      @JsonKey(name: 'avatar_color') required final String avatarColor,
      @JsonKey(name: 'created_by') required final String createdBy,
      @JsonKey(name: 'is_active') final bool isActive,
      final List<BotCommand> commands}) = _$BotImpl;

  factory _Bot.fromJson(Map<String, dynamic> json) = _$BotImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get username;
  @override
  String? get description;
  @override
  @JsonKey(name: 'avatar_color')
  String get avatarColor;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  List<BotCommand> get commands;

  /// Create a copy of Bot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BotImplCopyWith<_$BotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BotCommand _$BotCommandFromJson(Map<String, dynamic> json) {
  return _BotCommand.fromJson(json);
}

/// @nodoc
mixin _$BotCommand {
  String get command => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get response => throw _privateConstructorUsedError;

  /// Serializes this BotCommand to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BotCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BotCommandCopyWith<BotCommand> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BotCommandCopyWith<$Res> {
  factory $BotCommandCopyWith(
          BotCommand value, $Res Function(BotCommand) then) =
      _$BotCommandCopyWithImpl<$Res, BotCommand>;
  @useResult
  $Res call({String command, String description, String response});
}

/// @nodoc
class _$BotCommandCopyWithImpl<$Res, $Val extends BotCommand>
    implements $BotCommandCopyWith<$Res> {
  _$BotCommandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BotCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? command = null,
    Object? description = null,
    Object? response = null,
  }) {
    return _then(_value.copyWith(
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      response: null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BotCommandImplCopyWith<$Res>
    implements $BotCommandCopyWith<$Res> {
  factory _$$BotCommandImplCopyWith(
          _$BotCommandImpl value, $Res Function(_$BotCommandImpl) then) =
      __$$BotCommandImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String command, String description, String response});
}

/// @nodoc
class __$$BotCommandImplCopyWithImpl<$Res>
    extends _$BotCommandCopyWithImpl<$Res, _$BotCommandImpl>
    implements _$$BotCommandImplCopyWith<$Res> {
  __$$BotCommandImplCopyWithImpl(
      _$BotCommandImpl _value, $Res Function(_$BotCommandImpl) _then)
      : super(_value, _then);

  /// Create a copy of BotCommand
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? command = null,
    Object? description = null,
    Object? response = null,
  }) {
    return _then(_$BotCommandImpl(
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      response: null == response
          ? _value.response
          : response // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BotCommandImpl implements _BotCommand {
  const _$BotCommandImpl(
      {required this.command,
      required this.description,
      required this.response});

  factory _$BotCommandImpl.fromJson(Map<String, dynamic> json) =>
      _$$BotCommandImplFromJson(json);

  @override
  final String command;
  @override
  final String description;
  @override
  final String response;

  @override
  String toString() {
    return 'BotCommand(command: $command, description: $description, response: $response)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BotCommandImpl &&
            (identical(other.command, command) || other.command == command) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.response, response) ||
                other.response == response));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, command, description, response);

  /// Create a copy of BotCommand
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BotCommandImplCopyWith<_$BotCommandImpl> get copyWith =>
      __$$BotCommandImplCopyWithImpl<_$BotCommandImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BotCommandImplToJson(
      this,
    );
  }
}

abstract class _BotCommand implements BotCommand {
  const factory _BotCommand(
      {required final String command,
      required final String description,
      required final String response}) = _$BotCommandImpl;

  factory _BotCommand.fromJson(Map<String, dynamic> json) =
      _$BotCommandImpl.fromJson;

  @override
  String get command;
  @override
  String get description;
  @override
  String get response;

  /// Create a copy of BotCommand
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BotCommandImplCopyWith<_$BotCommandImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
