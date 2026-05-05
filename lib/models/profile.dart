import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String username,
    String? name,
    String? email,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    String? birthday,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'is_online', defaultValue: false) required bool isOnline,
    @JsonKey(name: 'last_seen') required DateTime lastSeen,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

@freezed
class PublicProfile with _$PublicProfile {
  const factory PublicProfile({
    required String id,
    required String username,
    String? name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    String? birthday,
    @JsonKey(name: 'is_active', defaultValue: true) required bool isActive,
    @JsonKey(name: 'is_online', defaultValue: false) required bool isOnline,
    @JsonKey(name: 'last_seen') required DateTime lastSeen,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _PublicProfile;

  factory PublicProfile.fromJson(Map<String, dynamic> json) => _$PublicProfileFromJson(json);
}
