// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VoiceRoom _$VoiceRoomFromJson(Map<String, dynamic> json) {
  return _VoiceRoom.fromJson(json);
}

/// @nodoc
mixin _$VoiceRoom {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String get groupId => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_name')
  String get groupName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  List<VoiceParticipant> get participants => throw _privateConstructorUsedError;

  /// Serializes this VoiceRoom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceRoomCopyWith<VoiceRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceRoomCopyWith<$Res> {
  factory $VoiceRoomCopyWith(VoiceRoom value, $Res Function(VoiceRoom) then) =
      _$VoiceRoomCopyWithImpl<$Res, VoiceRoom>;
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'group_id') String groupId,
      @JsonKey(name: 'group_name') String groupName,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'is_active') bool isActive,
      List<VoiceParticipant> participants});
}

/// @nodoc
class _$VoiceRoomCopyWithImpl<$Res, $Val extends VoiceRoom>
    implements $VoiceRoomCopyWith<$Res> {
  _$VoiceRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? groupId = null,
    Object? groupName = null,
    Object? createdBy = null,
    Object? isActive = null,
    Object? participants = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<VoiceParticipant>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoiceRoomImplCopyWith<$Res>
    implements $VoiceRoomCopyWith<$Res> {
  factory _$$VoiceRoomImplCopyWith(
          _$VoiceRoomImpl value, $Res Function(_$VoiceRoomImpl) then) =
      __$$VoiceRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      @JsonKey(name: 'group_id') String groupId,
      @JsonKey(name: 'group_name') String groupName,
      @JsonKey(name: 'created_by') String createdBy,
      @JsonKey(name: 'is_active') bool isActive,
      List<VoiceParticipant> participants});
}

/// @nodoc
class __$$VoiceRoomImplCopyWithImpl<$Res>
    extends _$VoiceRoomCopyWithImpl<$Res, _$VoiceRoomImpl>
    implements _$$VoiceRoomImplCopyWith<$Res> {
  __$$VoiceRoomImplCopyWithImpl(
      _$VoiceRoomImpl _value, $Res Function(_$VoiceRoomImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoiceRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? groupId = null,
    Object? groupName = null,
    Object? createdBy = null,
    Object? isActive = null,
    Object? participants = null,
  }) {
    return _then(_$VoiceRoomImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      groupName: null == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<VoiceParticipant>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceRoomImpl implements _VoiceRoom {
  const _$VoiceRoomImpl(
      {required this.id,
      required this.title,
      @JsonKey(name: 'group_id') required this.groupId,
      @JsonKey(name: 'group_name') required this.groupName,
      @JsonKey(name: 'created_by') required this.createdBy,
      @JsonKey(name: 'is_active') this.isActive = true,
      final List<VoiceParticipant> participants = const []})
      : _participants = participants;

  factory _$VoiceRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceRoomImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey(name: 'group_id')
  final String groupId;
  @override
  @JsonKey(name: 'group_name')
  final String groupName;
  @override
  @JsonKey(name: 'created_by')
  final String createdBy;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<VoiceParticipant> _participants;
  @override
  @JsonKey()
  List<VoiceParticipant> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  String toString() {
    return 'VoiceRoom(id: $id, title: $title, groupId: $groupId, groupName: $groupName, createdBy: $createdBy, isActive: $isActive, participants: $participants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, groupId, groupName,
      createdBy, isActive, const DeepCollectionEquality().hash(_participants));

  /// Create a copy of VoiceRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceRoomImplCopyWith<_$VoiceRoomImpl> get copyWith =>
      __$$VoiceRoomImplCopyWithImpl<_$VoiceRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceRoomImplToJson(
      this,
    );
  }
}

abstract class _VoiceRoom implements VoiceRoom {
  const factory _VoiceRoom(
      {required final String id,
      required final String title,
      @JsonKey(name: 'group_id') required final String groupId,
      @JsonKey(name: 'group_name') required final String groupName,
      @JsonKey(name: 'created_by') required final String createdBy,
      @JsonKey(name: 'is_active') final bool isActive,
      final List<VoiceParticipant> participants}) = _$VoiceRoomImpl;

  factory _VoiceRoom.fromJson(Map<String, dynamic> json) =
      _$VoiceRoomImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'group_id')
  String get groupId;
  @override
  @JsonKey(name: 'group_name')
  String get groupName;
  @override
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  List<VoiceParticipant> get participants;

  /// Create a copy of VoiceRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceRoomImplCopyWith<_$VoiceRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoiceParticipant _$VoiceParticipantFromJson(Map<String, dynamic> json) {
  return _VoiceParticipant.fromJson(json);
}

/// @nodoc
mixin _$VoiceParticipant {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_muted')
  bool get isMuted => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_speaking')
  bool get isSpeaking => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_hand_raised')
  bool get isHandRaised => throw _privateConstructorUsedError;

  /// Serializes this VoiceParticipant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceParticipantCopyWith<VoiceParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceParticipantCopyWith<$Res> {
  factory $VoiceParticipantCopyWith(
          VoiceParticipant value, $Res Function(VoiceParticipant) then) =
      _$VoiceParticipantCopyWithImpl<$Res, VoiceParticipant>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'is_muted') bool isMuted,
      @JsonKey(name: 'is_speaking') bool isSpeaking,
      @JsonKey(name: 'is_hand_raised') bool isHandRaised});
}

/// @nodoc
class _$VoiceParticipantCopyWithImpl<$Res, $Val extends VoiceParticipant>
    implements $VoiceParticipantCopyWith<$Res> {
  _$VoiceParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? isMuted = null,
    Object? isSpeaking = null,
    Object? isHandRaised = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeaking: null == isSpeaking
          ? _value.isSpeaking
          : isSpeaking // ignore: cast_nullable_to_non_nullable
              as bool,
      isHandRaised: null == isHandRaised
          ? _value.isHandRaised
          : isHandRaised // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoiceParticipantImplCopyWith<$Res>
    implements $VoiceParticipantCopyWith<$Res> {
  factory _$$VoiceParticipantImplCopyWith(_$VoiceParticipantImpl value,
          $Res Function(_$VoiceParticipantImpl) then) =
      __$$VoiceParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'is_muted') bool isMuted,
      @JsonKey(name: 'is_speaking') bool isSpeaking,
      @JsonKey(name: 'is_hand_raised') bool isHandRaised});
}

/// @nodoc
class __$$VoiceParticipantImplCopyWithImpl<$Res>
    extends _$VoiceParticipantCopyWithImpl<$Res, _$VoiceParticipantImpl>
    implements _$$VoiceParticipantImplCopyWith<$Res> {
  __$$VoiceParticipantImplCopyWithImpl(_$VoiceParticipantImpl _value,
      $Res Function(_$VoiceParticipantImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoiceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? name = null,
    Object? isMuted = null,
    Object? isSpeaking = null,
    Object? isHandRaised = null,
  }) {
    return _then(_$VoiceParticipantImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeaking: null == isSpeaking
          ? _value.isSpeaking
          : isSpeaking // ignore: cast_nullable_to_non_nullable
              as bool,
      isHandRaised: null == isHandRaised
          ? _value.isHandRaised
          : isHandRaised // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceParticipantImpl implements _VoiceParticipant {
  const _$VoiceParticipantImpl(
      {@JsonKey(name: 'user_id') required this.userId,
      required this.name,
      @JsonKey(name: 'is_muted') this.isMuted = true,
      @JsonKey(name: 'is_speaking') this.isSpeaking = false,
      @JsonKey(name: 'is_hand_raised') this.isHandRaised = false});

  factory _$VoiceParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceParticipantImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'is_muted')
  final bool isMuted;
  @override
  @JsonKey(name: 'is_speaking')
  final bool isSpeaking;
  @override
  @JsonKey(name: 'is_hand_raised')
  final bool isHandRaised;

  @override
  String toString() {
    return 'VoiceParticipant(userId: $userId, name: $name, isMuted: $isMuted, isSpeaking: $isSpeaking, isHandRaised: $isHandRaised)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceParticipantImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isSpeaking, isSpeaking) ||
                other.isSpeaking == isSpeaking) &&
            (identical(other.isHandRaised, isHandRaised) ||
                other.isHandRaised == isHandRaised));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, name, isMuted, isSpeaking, isHandRaised);

  /// Create a copy of VoiceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceParticipantImplCopyWith<_$VoiceParticipantImpl> get copyWith =>
      __$$VoiceParticipantImplCopyWithImpl<_$VoiceParticipantImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceParticipantImplToJson(
      this,
    );
  }
}

abstract class _VoiceParticipant implements VoiceParticipant {
  const factory _VoiceParticipant(
          {@JsonKey(name: 'user_id') required final String userId,
          required final String name,
          @JsonKey(name: 'is_muted') final bool isMuted,
          @JsonKey(name: 'is_speaking') final bool isSpeaking,
          @JsonKey(name: 'is_hand_raised') final bool isHandRaised}) =
      _$VoiceParticipantImpl;

  factory _VoiceParticipant.fromJson(Map<String, dynamic> json) =
      _$VoiceParticipantImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'is_muted')
  bool get isMuted;
  @override
  @JsonKey(name: 'is_speaking')
  bool get isSpeaking;
  @override
  @JsonKey(name: 'is_hand_raised')
  bool get isHandRaised;

  /// Create a copy of VoiceParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceParticipantImplCopyWith<_$VoiceParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
