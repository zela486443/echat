// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'chat_id')
  String get chatId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_id')
  String get senderId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  MessageType get type =>
      throw _privateConstructorUsedError; // Complex state payload mapped from React components
  @JsonKey(name: 'media_url')
  String? get mediaUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'poll_data')
  Map<String, dynamic>? get pollData => throw _privateConstructorUsedError;
  @JsonKey(name: 'bill_split_data')
  Map<String, dynamic>? get billSplitData => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_data')
  Map<String, dynamic>? get locationData => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_edited')
  bool get isEdited => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_id') String chatId,
      @JsonKey(name: 'sender_id') String senderId,
      String text,
      MessageType type,
      @JsonKey(name: 'media_url') String? mediaUrl,
      @JsonKey(name: 'poll_data') Map<String, dynamic>? pollData,
      @JsonKey(name: 'bill_split_data') Map<String, dynamic>? billSplitData,
      @JsonKey(name: 'location_data') Map<String, dynamic>? locationData,
      @JsonKey(name: 'is_edited') bool isEdited,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? text = null,
    Object? type = null,
    Object? mediaUrl = freezed,
    Object? pollData = freezed,
    Object? billSplitData = freezed,
    Object? locationData = freezed,
    Object? isEdited = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pollData: freezed == pollData
          ? _value.pollData
          : pollData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      billSplitData: freezed == billSplitData
          ? _value.billSplitData
          : billSplitData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      locationData: freezed == locationData
          ? _value.locationData
          : locationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_id') String chatId,
      @JsonKey(name: 'sender_id') String senderId,
      String text,
      MessageType type,
      @JsonKey(name: 'media_url') String? mediaUrl,
      @JsonKey(name: 'poll_data') Map<String, dynamic>? pollData,
      @JsonKey(name: 'bill_split_data') Map<String, dynamic>? billSplitData,
      @JsonKey(name: 'location_data') Map<String, dynamic>? locationData,
      @JsonKey(name: 'is_edited') bool isEdited,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? text = null,
    Object? type = null,
    Object? mediaUrl = freezed,
    Object? pollData = freezed,
    Object? billSplitData = freezed,
    Object? locationData = freezed,
    Object? isEdited = null,
    Object? createdAt = null,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _value.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      pollData: freezed == pollData
          ? _value._pollData
          : pollData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      billSplitData: freezed == billSplitData
          ? _value._billSplitData
          : billSplitData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      locationData: freezed == locationData
          ? _value._locationData
          : locationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      isEdited: null == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      @JsonKey(name: 'chat_id') required this.chatId,
      @JsonKey(name: 'sender_id') required this.senderId,
      required this.text,
      this.type = MessageType.text,
      @JsonKey(name: 'media_url') this.mediaUrl,
      @JsonKey(name: 'poll_data') final Map<String, dynamic>? pollData,
      @JsonKey(name: 'bill_split_data')
      final Map<String, dynamic>? billSplitData,
      @JsonKey(name: 'location_data') final Map<String, dynamic>? locationData,
      @JsonKey(name: 'is_edited') this.isEdited = false,
      @JsonKey(name: 'created_at') required this.createdAt})
      : _pollData = pollData,
        _billSplitData = billSplitData,
        _locationData = locationData;

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'chat_id')
  final String chatId;
  @override
  @JsonKey(name: 'sender_id')
  final String senderId;
  @override
  final String text;
  @override
  @JsonKey()
  final MessageType type;
// Complex state payload mapped from React components
  @override
  @JsonKey(name: 'media_url')
  final String? mediaUrl;
  final Map<String, dynamic>? _pollData;
  @override
  @JsonKey(name: 'poll_data')
  Map<String, dynamic>? get pollData {
    final value = _pollData;
    if (value == null) return null;
    if (_pollData is EqualUnmodifiableMapView) return _pollData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _billSplitData;
  @override
  @JsonKey(name: 'bill_split_data')
  Map<String, dynamic>? get billSplitData {
    final value = _billSplitData;
    if (value == null) return null;
    if (_billSplitData is EqualUnmodifiableMapView) return _billSplitData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _locationData;
  @override
  @JsonKey(name: 'location_data')
  Map<String, dynamic>? get locationData {
    final value = _locationData;
    if (value == null) return null;
    if (_locationData is EqualUnmodifiableMapView) return _locationData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'is_edited')
  final bool isEdited;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'Message(id: $id, chatId: $chatId, senderId: $senderId, text: $text, type: $type, mediaUrl: $mediaUrl, pollData: $pollData, billSplitData: $billSplitData, locationData: $locationData, isEdited: $isEdited, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            const DeepCollectionEquality().equals(other._pollData, _pollData) &&
            const DeepCollectionEquality()
                .equals(other._billSplitData, _billSplitData) &&
            const DeepCollectionEquality()
                .equals(other._locationData, _locationData) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      chatId,
      senderId,
      text,
      type,
      mediaUrl,
      const DeepCollectionEquality().hash(_pollData),
      const DeepCollectionEquality().hash(_billSplitData),
      const DeepCollectionEquality().hash(_locationData),
      isEdited,
      createdAt);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      @JsonKey(name: 'chat_id') required final String chatId,
      @JsonKey(name: 'sender_id') required final String senderId,
      required final String text,
      final MessageType type,
      @JsonKey(name: 'media_url') final String? mediaUrl,
      @JsonKey(name: 'poll_data') final Map<String, dynamic>? pollData,
      @JsonKey(name: 'bill_split_data')
      final Map<String, dynamic>? billSplitData,
      @JsonKey(name: 'location_data') final Map<String, dynamic>? locationData,
      @JsonKey(name: 'is_edited') final bool isEdited,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'chat_id')
  String get chatId;
  @override
  @JsonKey(name: 'sender_id')
  String get senderId;
  @override
  String get text;
  @override
  MessageType get type; // Complex state payload mapped from React components
  @override
  @JsonKey(name: 'media_url')
  String? get mediaUrl;
  @override
  @JsonKey(name: 'poll_data')
  Map<String, dynamic>? get pollData;
  @override
  @JsonKey(name: 'bill_split_data')
  Map<String, dynamic>? get billSplitData;
  @override
  @JsonKey(name: 'location_data')
  Map<String, dynamic>? get locationData;
  @override
  @JsonKey(name: 'is_edited')
  bool get isEdited;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
