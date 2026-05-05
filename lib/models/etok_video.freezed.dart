// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'etok_video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EtokVideo _$EtokVideoFromJson(Map<String, dynamic> json) {
  return _EtokVideo.fromJson(json);
}

/// @nodoc
mixin _$EtokVideo {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_id')
  String get authorId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get hashtags => throw _privateConstructorUsedError;
  @JsonKey(name: 'sound_name')
  String get soundName => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_url')
  String get videoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  double get duration => throw _privateConstructorUsedError;
  int get views => throw _privateConstructorUsedError;
  int get likes => throw _privateConstructorUsedError;
  int get comments => throw _privateConstructorUsedError;
  int get shares => throw _privateConstructorUsedError;
  String get privacy => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_comments')
  bool get allowComments => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_duet')
  bool get allowDuet => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_stitch')
  bool get allowStitch => throw _privateConstructorUsedError;
  @JsonKey(name: 'allow_download')
  bool get allowDownload => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_sponsored')
  bool get isSponsored => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // Joined profile
  Profile? get author => throw _privateConstructorUsedError;

  /// Serializes this EtokVideo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EtokVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EtokVideoCopyWith<EtokVideo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EtokVideoCopyWith<$Res> {
  factory $EtokVideoCopyWith(EtokVideo value, $Res Function(EtokVideo) then) =
      _$EtokVideoCopyWithImpl<$Res, EtokVideo>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'author_id') String authorId,
      String description,
      List<String> hashtags,
      @JsonKey(name: 'sound_name') String soundName,
      @JsonKey(name: 'video_url') String videoUrl,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      double duration,
      int views,
      int likes,
      int comments,
      int shares,
      String privacy,
      @JsonKey(name: 'allow_comments') bool allowComments,
      @JsonKey(name: 'allow_duet') bool allowDuet,
      @JsonKey(name: 'allow_stitch') bool allowStitch,
      @JsonKey(name: 'allow_download') bool allowDownload,
      @JsonKey(name: 'is_sponsored') bool isSponsored,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Profile? author});

  $ProfileCopyWith<$Res>? get author;
}

/// @nodoc
class _$EtokVideoCopyWithImpl<$Res, $Val extends EtokVideo>
    implements $EtokVideoCopyWith<$Res> {
  _$EtokVideoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EtokVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? description = null,
    Object? hashtags = null,
    Object? soundName = null,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? duration = null,
    Object? views = null,
    Object? likes = null,
    Object? comments = null,
    Object? shares = null,
    Object? privacy = null,
    Object? allowComments = null,
    Object? allowDuet = null,
    Object? allowStitch = null,
    Object? allowDownload = null,
    Object? isSponsored = null,
    Object? createdAt = null,
    Object? author = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      hashtags: null == hashtags
          ? _value.hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      soundName: null == soundName
          ? _value.soundName
          : soundName // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as int,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as int,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      allowComments: null == allowComments
          ? _value.allowComments
          : allowComments // ignore: cast_nullable_to_non_nullable
              as bool,
      allowDuet: null == allowDuet
          ? _value.allowDuet
          : allowDuet // ignore: cast_nullable_to_non_nullable
              as bool,
      allowStitch: null == allowStitch
          ? _value.allowStitch
          : allowStitch // ignore: cast_nullable_to_non_nullable
              as bool,
      allowDownload: null == allowDownload
          ? _value.allowDownload
          : allowDownload // ignore: cast_nullable_to_non_nullable
              as bool,
      isSponsored: null == isSponsored
          ? _value.isSponsored
          : isSponsored // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as Profile?,
    ) as $Val);
  }

  /// Create a copy of EtokVideo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCopyWith<$Res>? get author {
    if (_value.author == null) {
      return null;
    }

    return $ProfileCopyWith<$Res>(_value.author!, (value) {
      return _then(_value.copyWith(author: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EtokVideoImplCopyWith<$Res>
    implements $EtokVideoCopyWith<$Res> {
  factory _$$EtokVideoImplCopyWith(
          _$EtokVideoImpl value, $Res Function(_$EtokVideoImpl) then) =
      __$$EtokVideoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'author_id') String authorId,
      String description,
      List<String> hashtags,
      @JsonKey(name: 'sound_name') String soundName,
      @JsonKey(name: 'video_url') String videoUrl,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      double duration,
      int views,
      int likes,
      int comments,
      int shares,
      String privacy,
      @JsonKey(name: 'allow_comments') bool allowComments,
      @JsonKey(name: 'allow_duet') bool allowDuet,
      @JsonKey(name: 'allow_stitch') bool allowStitch,
      @JsonKey(name: 'allow_download') bool allowDownload,
      @JsonKey(name: 'is_sponsored') bool isSponsored,
      @JsonKey(name: 'created_at') DateTime createdAt,
      Profile? author});

  @override
  $ProfileCopyWith<$Res>? get author;
}

/// @nodoc
class __$$EtokVideoImplCopyWithImpl<$Res>
    extends _$EtokVideoCopyWithImpl<$Res, _$EtokVideoImpl>
    implements _$$EtokVideoImplCopyWith<$Res> {
  __$$EtokVideoImplCopyWithImpl(
      _$EtokVideoImpl _value, $Res Function(_$EtokVideoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EtokVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? description = null,
    Object? hashtags = null,
    Object? soundName = null,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? duration = null,
    Object? views = null,
    Object? likes = null,
    Object? comments = null,
    Object? shares = null,
    Object? privacy = null,
    Object? allowComments = null,
    Object? allowDuet = null,
    Object? allowStitch = null,
    Object? allowDownload = null,
    Object? isSponsored = null,
    Object? createdAt = null,
    Object? author = freezed,
  }) {
    return _then(_$EtokVideoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      hashtags: null == hashtags
          ? _value._hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      soundName: null == soundName
          ? _value.soundName
          : soundName // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as double,
      views: null == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int,
      likes: null == likes
          ? _value.likes
          : likes // ignore: cast_nullable_to_non_nullable
              as int,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as int,
      shares: null == shares
          ? _value.shares
          : shares // ignore: cast_nullable_to_non_nullable
              as int,
      privacy: null == privacy
          ? _value.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as String,
      allowComments: null == allowComments
          ? _value.allowComments
          : allowComments // ignore: cast_nullable_to_non_nullable
              as bool,
      allowDuet: null == allowDuet
          ? _value.allowDuet
          : allowDuet // ignore: cast_nullable_to_non_nullable
              as bool,
      allowStitch: null == allowStitch
          ? _value.allowStitch
          : allowStitch // ignore: cast_nullable_to_non_nullable
              as bool,
      allowDownload: null == allowDownload
          ? _value.allowDownload
          : allowDownload // ignore: cast_nullable_to_non_nullable
              as bool,
      isSponsored: null == isSponsored
          ? _value.isSponsored
          : isSponsored // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      author: freezed == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as Profile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EtokVideoImpl implements _EtokVideo {
  const _$EtokVideoImpl(
      {required this.id,
      @JsonKey(name: 'author_id') required this.authorId,
      required this.description,
      final List<String> hashtags = const [],
      @JsonKey(name: 'sound_name') required this.soundName,
      @JsonKey(name: 'video_url') required this.videoUrl,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      required this.duration,
      this.views = 0,
      this.likes = 0,
      this.comments = 0,
      this.shares = 0,
      this.privacy = 'everyone',
      @JsonKey(name: 'allow_comments') this.allowComments = true,
      @JsonKey(name: 'allow_duet') this.allowDuet = true,
      @JsonKey(name: 'allow_stitch') this.allowStitch = true,
      @JsonKey(name: 'allow_download') this.allowDownload = true,
      @JsonKey(name: 'is_sponsored') this.isSponsored = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.author})
      : _hashtags = hashtags;

  factory _$EtokVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EtokVideoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'author_id')
  final String authorId;
  @override
  final String description;
  final List<String> _hashtags;
  @override
  @JsonKey()
  List<String> get hashtags {
    if (_hashtags is EqualUnmodifiableListView) return _hashtags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hashtags);
  }

  @override
  @JsonKey(name: 'sound_name')
  final String soundName;
  @override
  @JsonKey(name: 'video_url')
  final String videoUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  final double duration;
  @override
  @JsonKey()
  final int views;
  @override
  @JsonKey()
  final int likes;
  @override
  @JsonKey()
  final int comments;
  @override
  @JsonKey()
  final int shares;
  @override
  @JsonKey()
  final String privacy;
  @override
  @JsonKey(name: 'allow_comments')
  final bool allowComments;
  @override
  @JsonKey(name: 'allow_duet')
  final bool allowDuet;
  @override
  @JsonKey(name: 'allow_stitch')
  final bool allowStitch;
  @override
  @JsonKey(name: 'allow_download')
  final bool allowDownload;
  @override
  @JsonKey(name: 'is_sponsored')
  final bool isSponsored;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
// Joined profile
  @override
  final Profile? author;

  @override
  String toString() {
    return 'EtokVideo(id: $id, authorId: $authorId, description: $description, hashtags: $hashtags, soundName: $soundName, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, duration: $duration, views: $views, likes: $likes, comments: $comments, shares: $shares, privacy: $privacy, allowComments: $allowComments, allowDuet: $allowDuet, allowStitch: $allowStitch, allowDownload: $allowDownload, isSponsored: $isSponsored, createdAt: $createdAt, author: $author)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EtokVideoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._hashtags, _hashtags) &&
            (identical(other.soundName, soundName) ||
                other.soundName == soundName) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.likes, likes) || other.likes == likes) &&
            (identical(other.comments, comments) ||
                other.comments == comments) &&
            (identical(other.shares, shares) || other.shares == shares) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.allowComments, allowComments) ||
                other.allowComments == allowComments) &&
            (identical(other.allowDuet, allowDuet) ||
                other.allowDuet == allowDuet) &&
            (identical(other.allowStitch, allowStitch) ||
                other.allowStitch == allowStitch) &&
            (identical(other.allowDownload, allowDownload) ||
                other.allowDownload == allowDownload) &&
            (identical(other.isSponsored, isSponsored) ||
                other.isSponsored == isSponsored) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.author, author) || other.author == author));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        authorId,
        description,
        const DeepCollectionEquality().hash(_hashtags),
        soundName,
        videoUrl,
        thumbnailUrl,
        duration,
        views,
        likes,
        comments,
        shares,
        privacy,
        allowComments,
        allowDuet,
        allowStitch,
        allowDownload,
        isSponsored,
        createdAt,
        author
      ]);

  /// Create a copy of EtokVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EtokVideoImplCopyWith<_$EtokVideoImpl> get copyWith =>
      __$$EtokVideoImplCopyWithImpl<_$EtokVideoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EtokVideoImplToJson(
      this,
    );
  }
}

abstract class _EtokVideo implements EtokVideo {
  const factory _EtokVideo(
      {required final String id,
      @JsonKey(name: 'author_id') required final String authorId,
      required final String description,
      final List<String> hashtags,
      @JsonKey(name: 'sound_name') required final String soundName,
      @JsonKey(name: 'video_url') required final String videoUrl,
      @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
      required final double duration,
      final int views,
      final int likes,
      final int comments,
      final int shares,
      final String privacy,
      @JsonKey(name: 'allow_comments') final bool allowComments,
      @JsonKey(name: 'allow_duet') final bool allowDuet,
      @JsonKey(name: 'allow_stitch') final bool allowStitch,
      @JsonKey(name: 'allow_download') final bool allowDownload,
      @JsonKey(name: 'is_sponsored') final bool isSponsored,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      final Profile? author}) = _$EtokVideoImpl;

  factory _EtokVideo.fromJson(Map<String, dynamic> json) =
      _$EtokVideoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'author_id')
  String get authorId;
  @override
  String get description;
  @override
  List<String> get hashtags;
  @override
  @JsonKey(name: 'sound_name')
  String get soundName;
  @override
  @JsonKey(name: 'video_url')
  String get videoUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  double get duration;
  @override
  int get views;
  @override
  int get likes;
  @override
  int get comments;
  @override
  int get shares;
  @override
  String get privacy;
  @override
  @JsonKey(name: 'allow_comments')
  bool get allowComments;
  @override
  @JsonKey(name: 'allow_duet')
  bool get allowDuet;
  @override
  @JsonKey(name: 'allow_stitch')
  bool get allowStitch;
  @override
  @JsonKey(name: 'allow_download')
  bool get allowDownload;
  @override
  @JsonKey(name: 'is_sponsored')
  bool get isSponsored;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Joined profile
  @override
  Profile? get author;

  /// Create a copy of EtokVideo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EtokVideoImplCopyWith<_$EtokVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
