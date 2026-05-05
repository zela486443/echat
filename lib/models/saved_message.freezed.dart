// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SavedMessage _$SavedMessageFromJson(Map<String, dynamic> json) {
  return _SavedMessage.fromJson(json);
}

/// @nodoc
mixin _$SavedMessage {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'message_id')
  String get messageId => throw _privateConstructorUsedError;
  @JsonKey(name: 'chat_id')
  String get chatId => throw _privateConstructorUsedError;
  @JsonKey(name: 'saved_at')
  DateTime get savedAt => throw _privateConstructorUsedError;
  String? get note =>
      throw _privateConstructorUsedError; // Optional joined data
  Map<String, dynamic>? get message => throw _privateConstructorUsedError;

  /// Serializes this SavedMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedMessageCopyWith<SavedMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedMessageCopyWith<$Res> {
  factory $SavedMessageCopyWith(
          SavedMessage value, $Res Function(SavedMessage) then) =
      _$SavedMessageCopyWithImpl<$Res, SavedMessage>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'message_id') String messageId,
      @JsonKey(name: 'chat_id') String chatId,
      @JsonKey(name: 'saved_at') DateTime savedAt,
      String? note,
      Map<String, dynamic>? message});
}

/// @nodoc
class _$SavedMessageCopyWithImpl<$Res, $Val extends SavedMessage>
    implements $SavedMessageCopyWith<$Res> {
  _$SavedMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? messageId = null,
    Object? chatId = null,
    Object? savedAt = null,
    Object? note = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      savedAt: null == savedAt
          ? _value.savedAt
          : savedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SavedMessageImplCopyWith<$Res>
    implements $SavedMessageCopyWith<$Res> {
  factory _$$SavedMessageImplCopyWith(
          _$SavedMessageImpl value, $Res Function(_$SavedMessageImpl) then) =
      __$$SavedMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'message_id') String messageId,
      @JsonKey(name: 'chat_id') String chatId,
      @JsonKey(name: 'saved_at') DateTime savedAt,
      String? note,
      Map<String, dynamic>? message});
}

/// @nodoc
class __$$SavedMessageImplCopyWithImpl<$Res>
    extends _$SavedMessageCopyWithImpl<$Res, _$SavedMessageImpl>
    implements _$$SavedMessageImplCopyWith<$Res> {
  __$$SavedMessageImplCopyWithImpl(
      _$SavedMessageImpl _value, $Res Function(_$SavedMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SavedMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? messageId = null,
    Object? chatId = null,
    Object? savedAt = null,
    Object? note = freezed,
    Object? message = freezed,
  }) {
    return _then(_$SavedMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      messageId: null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      savedAt: null == savedAt
          ? _value.savedAt
          : savedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value._message
          : message // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavedMessageImpl implements _SavedMessage {
  const _$SavedMessageImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'message_id') required this.messageId,
      @JsonKey(name: 'chat_id') required this.chatId,
      @JsonKey(name: 'saved_at') required this.savedAt,
      this.note,
      final Map<String, dynamic>? message})
      : _message = message;

  factory _$SavedMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedMessageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'message_id')
  final String messageId;
  @override
  @JsonKey(name: 'chat_id')
  final String chatId;
  @override
  @JsonKey(name: 'saved_at')
  final DateTime savedAt;
  @override
  final String? note;
// Optional joined data
  final Map<String, dynamic>? _message;
// Optional joined data
  @override
  Map<String, dynamic>? get message {
    final value = _message;
    if (value == null) return null;
    if (_message is EqualUnmodifiableMapView) return _message;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'SavedMessage(id: $id, userId: $userId, messageId: $messageId, chatId: $chatId, savedAt: $savedAt, note: $note, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.savedAt, savedAt) || other.savedAt == savedAt) &&
            (identical(other.note, note) || other.note == note) &&
            const DeepCollectionEquality().equals(other._message, _message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, messageId, chatId,
      savedAt, note, const DeepCollectionEquality().hash(_message));

  /// Create a copy of SavedMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedMessageImplCopyWith<_$SavedMessageImpl> get copyWith =>
      __$$SavedMessageImplCopyWithImpl<_$SavedMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedMessageImplToJson(
      this,
    );
  }
}

abstract class _SavedMessage implements SavedMessage {
  const factory _SavedMessage(
      {required final String id,
      @JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'message_id') required final String messageId,
      @JsonKey(name: 'chat_id') required final String chatId,
      @JsonKey(name: 'saved_at') required final DateTime savedAt,
      final String? note,
      final Map<String, dynamic>? message}) = _$SavedMessageImpl;

  factory _SavedMessage.fromJson(Map<String, dynamic> json) =
      _$SavedMessageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'message_id')
  String get messageId;
  @override
  @JsonKey(name: 'chat_id')
  String get chatId;
  @override
  @JsonKey(name: 'saved_at')
  DateTime get savedAt;
  @override
  String? get note; // Optional joined data
  @override
  Map<String, dynamic>? get message;

  /// Create a copy of SavedMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedMessageImplCopyWith<_$SavedMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
