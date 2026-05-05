// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Chat _$ChatFromJson(Map<String, dynamic> json) {
  return _Chat.fromJson(json);
}

/// @nodoc
mixin _$Chat {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_1')
  String get participant1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'participant_2')
  String get participant2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message')
  String? get lastMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_time')
  DateTime? get lastMessageTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_sender_id')
  String? get lastSenderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count_1')
  int get unreadCount1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count_2')
  int get unreadCount2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Chat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatCopyWith<Chat> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatCopyWith<$Res> {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) then) =
      _$ChatCopyWithImpl<$Res, Chat>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'participant_1') String participant1,
      @JsonKey(name: 'participant_2') String participant2,
      @JsonKey(name: 'last_message') String? lastMessage,
      @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
      @JsonKey(name: 'last_sender_id') String? lastSenderId,
      @JsonKey(name: 'unread_count_1') int unreadCount1,
      @JsonKey(name: 'unread_count_2') int unreadCount2,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$ChatCopyWithImpl<$Res, $Val extends Chat>
    implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participant1 = null,
    Object? participant2 = null,
    Object? lastMessage = freezed,
    Object? lastMessageTime = freezed,
    Object? lastSenderId = freezed,
    Object? unreadCount1 = null,
    Object? unreadCount2 = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      participant1: null == participant1
          ? _value.participant1
          : participant1 // ignore: cast_nullable_to_non_nullable
              as String,
      participant2: null == participant2
          ? _value.participant2
          : participant2 // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSenderId: freezed == lastSenderId
          ? _value.lastSenderId
          : lastSenderId // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount1: null == unreadCount1
          ? _value.unreadCount1
          : unreadCount1 // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount2: null == unreadCount2
          ? _value.unreadCount2
          : unreadCount2 // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatImplCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$$ChatImplCopyWith(
          _$ChatImpl value, $Res Function(_$ChatImpl) then) =
      __$$ChatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'participant_1') String participant1,
      @JsonKey(name: 'participant_2') String participant2,
      @JsonKey(name: 'last_message') String? lastMessage,
      @JsonKey(name: 'last_message_time') DateTime? lastMessageTime,
      @JsonKey(name: 'last_sender_id') String? lastSenderId,
      @JsonKey(name: 'unread_count_1') int unreadCount1,
      @JsonKey(name: 'unread_count_2') int unreadCount2,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$ChatImplCopyWithImpl<$Res>
    extends _$ChatCopyWithImpl<$Res, _$ChatImpl>
    implements _$$ChatImplCopyWith<$Res> {
  __$$ChatImplCopyWithImpl(_$ChatImpl _value, $Res Function(_$ChatImpl) _then)
      : super(_value, _then);

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participant1 = null,
    Object? participant2 = null,
    Object? lastMessage = freezed,
    Object? lastMessageTime = freezed,
    Object? lastSenderId = freezed,
    Object? unreadCount1 = null,
    Object? unreadCount2 = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ChatImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      participant1: null == participant1
          ? _value.participant1
          : participant1 // ignore: cast_nullable_to_non_nullable
              as String,
      participant2: null == participant2
          ? _value.participant2
          : participant2 // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTime: freezed == lastMessageTime
          ? _value.lastMessageTime
          : lastMessageTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSenderId: freezed == lastSenderId
          ? _value.lastSenderId
          : lastSenderId // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount1: null == unreadCount1
          ? _value.unreadCount1
          : unreadCount1 // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount2: null == unreadCount2
          ? _value.unreadCount2
          : unreadCount2 // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatImpl implements _Chat {
  const _$ChatImpl(
      {required this.id,
      @JsonKey(name: 'participant_1') required this.participant1,
      @JsonKey(name: 'participant_2') required this.participant2,
      @JsonKey(name: 'last_message') this.lastMessage,
      @JsonKey(name: 'last_message_time') this.lastMessageTime,
      @JsonKey(name: 'last_sender_id') this.lastSenderId,
      @JsonKey(name: 'unread_count_1') this.unreadCount1 = 0,
      @JsonKey(name: 'unread_count_2') this.unreadCount2 = 0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$ChatImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'participant_1')
  final String participant1;
  @override
  @JsonKey(name: 'participant_2')
  final String participant2;
  @override
  @JsonKey(name: 'last_message')
  final String? lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  final DateTime? lastMessageTime;
  @override
  @JsonKey(name: 'last_sender_id')
  final String? lastSenderId;
  @override
  @JsonKey(name: 'unread_count_1')
  final int unreadCount1;
  @override
  @JsonKey(name: 'unread_count_2')
  final int unreadCount2;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Chat(id: $id, participant1: $participant1, participant2: $participant2, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, lastSenderId: $lastSenderId, unreadCount1: $unreadCount1, unreadCount2: $unreadCount2, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.participant1, participant1) ||
                other.participant1 == participant1) &&
            (identical(other.participant2, participant2) ||
                other.participant2 == participant2) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            (identical(other.lastSenderId, lastSenderId) ||
                other.lastSenderId == lastSenderId) &&
            (identical(other.unreadCount1, unreadCount1) ||
                other.unreadCount1 == unreadCount1) &&
            (identical(other.unreadCount2, unreadCount2) ||
                other.unreadCount2 == unreadCount2) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      participant1,
      participant2,
      lastMessage,
      lastMessageTime,
      lastSenderId,
      unreadCount1,
      unreadCount2,
      createdAt,
      updatedAt);

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatImplCopyWith<_$ChatImpl> get copyWith =>
      __$$ChatImplCopyWithImpl<_$ChatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatImplToJson(
      this,
    );
  }
}

abstract class _Chat implements Chat {
  const factory _Chat(
          {required final String id,
          @JsonKey(name: 'participant_1') required final String participant1,
          @JsonKey(name: 'participant_2') required final String participant2,
          @JsonKey(name: 'last_message') final String? lastMessage,
          @JsonKey(name: 'last_message_time') final DateTime? lastMessageTime,
          @JsonKey(name: 'last_sender_id') final String? lastSenderId,
          @JsonKey(name: 'unread_count_1') final int unreadCount1,
          @JsonKey(name: 'unread_count_2') final int unreadCount2,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$ChatImpl;

  factory _Chat.fromJson(Map<String, dynamic> json) = _$ChatImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'participant_1')
  String get participant1;
  @override
  @JsonKey(name: 'participant_2')
  String get participant2;
  @override
  @JsonKey(name: 'last_message')
  String? get lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  DateTime? get lastMessageTime;
  @override
  @JsonKey(name: 'last_sender_id')
  String? get lastSenderId;
  @override
  @JsonKey(name: 'unread_count_1')
  int get unreadCount1;
  @override
  @JsonKey(name: 'unread_count_2')
  int get unreadCount2;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of Chat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatImplCopyWith<_$ChatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
