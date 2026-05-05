// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_highlight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StoryHighlight _$StoryHighlightFromJson(Map<String, dynamic> json) {
  return _StoryHighlight.fromJson(json);
}

/// @nodoc
mixin _$StoryHighlight {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_color')
  String get coverColor => throw _privateConstructorUsedError;
  List<String> get storyIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StoryHighlight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StoryHighlight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoryHighlightCopyWith<StoryHighlight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoryHighlightCopyWith<$Res> {
  factory $StoryHighlightCopyWith(
          StoryHighlight value, $Res Function(StoryHighlight) then) =
      _$StoryHighlightCopyWithImpl<$Res, StoryHighlight>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'cover_color') String coverColor,
      List<String> storyIds,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$StoryHighlightCopyWithImpl<$Res, $Val extends StoryHighlight>
    implements $StoryHighlightCopyWith<$Res> {
  _$StoryHighlightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoryHighlight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? coverColor = null,
    Object? storyIds = null,
    Object? createdAt = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      coverColor: null == coverColor
          ? _value.coverColor
          : coverColor // ignore: cast_nullable_to_non_nullable
              as String,
      storyIds: null == storyIds
          ? _value.storyIds
          : storyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoryHighlightImplCopyWith<$Res>
    implements $StoryHighlightCopyWith<$Res> {
  factory _$$StoryHighlightImplCopyWith(_$StoryHighlightImpl value,
          $Res Function(_$StoryHighlightImpl) then) =
      __$$StoryHighlightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      String name,
      @JsonKey(name: 'cover_color') String coverColor,
      List<String> storyIds,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$StoryHighlightImplCopyWithImpl<$Res>
    extends _$StoryHighlightCopyWithImpl<$Res, _$StoryHighlightImpl>
    implements _$$StoryHighlightImplCopyWith<$Res> {
  __$$StoryHighlightImplCopyWithImpl(
      _$StoryHighlightImpl _value, $Res Function(_$StoryHighlightImpl) _then)
      : super(_value, _then);

  /// Create a copy of StoryHighlight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? coverColor = null,
    Object? storyIds = null,
    Object? createdAt = null,
  }) {
    return _then(_$StoryHighlightImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      coverColor: null == coverColor
          ? _value.coverColor
          : coverColor // ignore: cast_nullable_to_non_nullable
              as String,
      storyIds: null == storyIds
          ? _value._storyIds
          : storyIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StoryHighlightImpl implements _StoryHighlight {
  const _$StoryHighlightImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      required this.name,
      @JsonKey(name: 'cover_color') required this.coverColor,
      final List<String> storyIds = const [],
      @JsonKey(name: 'created_at') required this.createdAt})
      : _storyIds = storyIds;

  factory _$StoryHighlightImpl.fromJson(Map<String, dynamic> json) =>
      _$$StoryHighlightImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String name;
  @override
  @JsonKey(name: 'cover_color')
  final String coverColor;
  final List<String> _storyIds;
  @override
  @JsonKey()
  List<String> get storyIds {
    if (_storyIds is EqualUnmodifiableListView) return _storyIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_storyIds);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'StoryHighlight(id: $id, userId: $userId, name: $name, coverColor: $coverColor, storyIds: $storyIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoryHighlightImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.coverColor, coverColor) ||
                other.coverColor == coverColor) &&
            const DeepCollectionEquality().equals(other._storyIds, _storyIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name, coverColor,
      const DeepCollectionEquality().hash(_storyIds), createdAt);

  /// Create a copy of StoryHighlight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoryHighlightImplCopyWith<_$StoryHighlightImpl> get copyWith =>
      __$$StoryHighlightImplCopyWithImpl<_$StoryHighlightImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StoryHighlightImplToJson(
      this,
    );
  }
}

abstract class _StoryHighlight implements StoryHighlight {
  const factory _StoryHighlight(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          required final String name,
          @JsonKey(name: 'cover_color') required final String coverColor,
          final List<String> storyIds,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$StoryHighlightImpl;

  factory _StoryHighlight.fromJson(Map<String, dynamic> json) =
      _$StoryHighlightImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get name;
  @override
  @JsonKey(name: 'cover_color')
  String get coverColor;
  @override
  List<String> get storyIds;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of StoryHighlight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoryHighlightImplCopyWith<_$StoryHighlightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
