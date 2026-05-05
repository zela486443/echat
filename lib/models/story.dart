import 'package:supabase_flutter/supabase_flutter.dart';

enum StoryType { text, image, video }

class UserStory {
  final String id;
  final String userId;
  final String? content;
  final String? mediaUrl;
  final StoryType storyType;
  final String? backgroundColor;
  final int viewsCount;
  final int? duration;
  final DateTime createdAt;
  final DateTime expiresAt;

  UserStory({
    required this.id,
    required this.userId,
    this.content,
    this.mediaUrl,
    required this.storyType,
    this.backgroundColor,
    this.viewsCount = 0,
    this.duration,
    required this.createdAt,
    required this.expiresAt,
  });

  factory UserStory.fromJson(Map<String, dynamic> json) {
    return UserStory(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      storyType: _parseType(json['story_type']),
      backgroundColor: json['background_color'],
      viewsCount: json['views_count'] ?? 0,
      duration: json['duration'],
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }

  static StoryType _parseType(String type) {
    switch (type) {
      case 'image': return StoryType.image;
      case 'video': return StoryType.video;
      default: return StoryType.text;
    }
  }
}

class StoryGroup {
  final String userId;
  final String name;
  final String? avatarUrl;
  final List<UserStory> stories;
  final bool hasUnviewed;

  StoryGroup({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.stories,
    required this.hasUnviewed,
  });
}

class StoryViewerInfo {
  final String viewerId;
  final DateTime viewedAt;
  final String? username;
  final String? name;
  final String? avatarUrl;

  StoryViewerInfo({
    required this.viewerId,
    required this.viewedAt,
    this.username,
    this.name,
    this.avatarUrl,
  });
}
