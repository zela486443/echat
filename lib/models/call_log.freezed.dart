// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CallLog _$CallLogFromJson(Map<String, dynamic> json) {
  return _CallLog.fromJson(json);
}

/// @nodoc
mixin _$CallLog {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'caller_id')
  String get callerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'receiver_id')
  String get receiverId => throw _privateConstructorUsedError;
  @JsonKey(name: 'call_type')
  String get callType =>
      throw _privateConstructorUsedError; // 'voice' or 'video'
  String get status =>
      throw _privateConstructorUsedError; // 'completed', 'missed', 'rejected', 'failed'
  @JsonKey(name: 'duration_seconds')
  int? get durationSeconds => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Joined profile data
  Map<String, dynamic>? get caller => throw _privateConstructorUsedError;
  Map<String, dynamic>? get receiver => throw _privateConstructorUsedError;

  /// Serializes this CallLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallLogCopyWith<CallLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallLogCopyWith<$Res> {
  factory $CallLogCopyWith(CallLog value, $Res Function(CallLog) then) =
      _$CallLogCopyWithImpl<$Res, CallLog>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'caller_id') String callerId,
      @JsonKey(name: 'receiver_id') String receiverId,
      @JsonKey(name: 'call_type') String callType,
      String status,
      @JsonKey(name: 'duration_seconds') int? durationSeconds,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Map<String, dynamic>? caller,
      Map<String, dynamic>? receiver});
}

/// @nodoc
class _$CallLogCopyWithImpl<$Res, $Val extends CallLog>
    implements $CallLogCopyWith<$Res> {
  _$CallLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? callerId = null,
    Object? receiverId = null,
    Object? callType = null,
    Object? status = null,
    Object? durationSeconds = freezed,
    Object? createdAt = null,
    Object? caller = freezed,
    Object? receiver = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      callerId: null == callerId
          ? _value.callerId
          : callerId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      callType: null == callType
          ? _value.callType
          : callType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      caller: freezed == caller
          ? _value.caller
          : caller // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      receiver: freezed == receiver
          ? _value.receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CallLogImplCopyWith<$Res> implements $CallLogCopyWith<$Res> {
  factory _$$CallLogImplCopyWith(
          _$CallLogImpl value, $Res Function(_$CallLogImpl) then) =
      __$$CallLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'caller_id') String callerId,
      @JsonKey(name: 'receiver_id') String receiverId,
      @JsonKey(name: 'call_type') String callType,
      String status,
      @JsonKey(name: 'duration_seconds') int? durationSeconds,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Map<String, dynamic>? caller,
      Map<String, dynamic>? receiver});
}

/// @nodoc
class __$$CallLogImplCopyWithImpl<$Res>
    extends _$CallLogCopyWithImpl<$Res, _$CallLogImpl>
    implements _$$CallLogImplCopyWith<$Res> {
  __$$CallLogImplCopyWithImpl(
      _$CallLogImpl _value, $Res Function(_$CallLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? callerId = null,
    Object? receiverId = null,
    Object? callType = null,
    Object? status = null,
    Object? durationSeconds = freezed,
    Object? createdAt = null,
    Object? caller = freezed,
    Object? receiver = freezed,
  }) {
    return _then(_$CallLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      callerId: null == callerId
          ? _value.callerId
          : callerId // ignore: cast_nullable_to_non_nullable
              as String,
      receiverId: null == receiverId
          ? _value.receiverId
          : receiverId // ignore: cast_nullable_to_non_nullable
              as String,
      callType: null == callType
          ? _value.callType
          : callType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      caller: freezed == caller
          ? _value._caller
          : caller // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      receiver: freezed == receiver
          ? _value._receiver
          : receiver // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CallLogImpl implements _CallLog {
  const _$CallLogImpl(
      {required this.id,
      @JsonKey(name: 'caller_id') required this.callerId,
      @JsonKey(name: 'receiver_id') required this.receiverId,
      @JsonKey(name: 'call_type') required this.callType,
      required this.status,
      @JsonKey(name: 'duration_seconds') this.durationSeconds,
      @JsonKey(name: 'created_at') required this.createdAt,
      final Map<String, dynamic>? caller,
      final Map<String, dynamic>? receiver})
      : _caller = caller,
        _receiver = receiver;

  factory _$CallLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$CallLogImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'caller_id')
  final String callerId;
  @override
  @JsonKey(name: 'receiver_id')
  final String receiverId;
  @override
  @JsonKey(name: 'call_type')
  final String callType;
// 'voice' or 'video'
  @override
  final String status;
// 'completed', 'missed', 'rejected', 'failed'
  @override
  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Joined profile data
  final Map<String, dynamic>? _caller;
// Joined profile data
  @override
  Map<String, dynamic>? get caller {
    final value = _caller;
    if (value == null) return null;
    if (_caller is EqualUnmodifiableMapView) return _caller;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _receiver;
  @override
  Map<String, dynamic>? get receiver {
    final value = _receiver;
    if (value == null) return null;
    if (_receiver is EqualUnmodifiableMapView) return _receiver;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'CallLog(id: $id, callerId: $callerId, receiverId: $receiverId, callType: $callType, status: $status, durationSeconds: $durationSeconds, createdAt: $createdAt, caller: $caller, receiver: $receiver)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.callerId, callerId) ||
                other.callerId == callerId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.callType, callType) ||
                other.callType == callType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._caller, _caller) &&
            const DeepCollectionEquality().equals(other._receiver, _receiver));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      callerId,
      receiverId,
      callType,
      status,
      durationSeconds,
      createdAt,
      const DeepCollectionEquality().hash(_caller),
      const DeepCollectionEquality().hash(_receiver));

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallLogImplCopyWith<_$CallLogImpl> get copyWith =>
      __$$CallLogImplCopyWithImpl<_$CallLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CallLogImplToJson(
      this,
    );
  }
}

abstract class _CallLog implements CallLog {
  const factory _CallLog(
      {required final String id,
      @JsonKey(name: 'caller_id') required final String callerId,
      @JsonKey(name: 'receiver_id') required final String receiverId,
      @JsonKey(name: 'call_type') required final String callType,
      required final String status,
      @JsonKey(name: 'duration_seconds') final int? durationSeconds,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final Map<String, dynamic>? caller,
      final Map<String, dynamic>? receiver}) = _$CallLogImpl;

  factory _CallLog.fromJson(Map<String, dynamic> json) = _$CallLogImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'caller_id')
  String get callerId;
  @override
  @JsonKey(name: 'receiver_id')
  String get receiverId;
  @override
  @JsonKey(name: 'call_type')
  String get callType; // 'voice' or 'video'
  @override
  String get status; // 'completed', 'missed', 'rejected', 'failed'
  @override
  @JsonKey(name: 'duration_seconds')
  int? get durationSeconds;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Joined profile data
  @override
  Map<String, dynamic>? get caller;
  @override
  Map<String, dynamic>? get receiver;

  /// Create a copy of CallLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallLogImplCopyWith<_$CallLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
