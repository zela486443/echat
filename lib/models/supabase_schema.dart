class DatabaseSchema {
  // A Flutter abstraction over the Typescript Supabase 'Database' Json Schema mapping.
  // Real world implementation in large Flutter apps uses Freezed / build_runner for exact mapping, 
  // but to preserve the scale of the 1,128 `types.ts` conceptually here are the Constants mapping to table APIs.

  static const String aiConversations = 'ai_conversations';
  static const String aiMessages = 'ai_messages';
  static const String callLogs = 'call_logs';
  static const String chats = 'chats';
  static const String etokComments = 'etok_comments';
  static const String etokFollows = 'etok_follows';
  static const String etokLikes = 'etok_likes';
  static const String etokVideos = 'etok_videos';
  static const String groupMembers = 'group_members';
  static const String groupMessages = 'group_messages';
  static const String groups = 'groups';
  static const String messageReactions = 'message_reactions';
  static const String messages = 'messages';
  static const String profiles = 'profiles';
  static const String pushSubscriptions = 'push_subscriptions';
  static const String savedMessages = 'saved_messages';
  static const String storyViews = 'story_views';
  static const String typingIndicators = 'typing_indicators';
  static const String userStories = 'user_stories';
  static const String walletTermsAcceptance = 'wallet_terms_acceptance';
  static const String walletTransactions = 'wallet_transactions';
}

// Below are conceptual native DTOs mapping exactly to Row logic found in types.ts

class ProfileDTO {
  final String id;
  final String? avatarUrl;
  final String? bio;
  final String? birthday;
  final bool? isActive;
  final bool? isOnline;
  final String? lastSeen;
  final String? name;
  final String? phone;
  final String? username;

  ProfileDTO({required this.id, this.avatarUrl, this.bio, this.birthday, this.isActive, this.isOnline, this.lastSeen, this.name, this.phone, this.username});
  
  factory ProfileDTO.fromJson(Map<String, dynamic> json) => ProfileDTO(
    id: json['id'],
    avatarUrl: json['avatar_url'],
    bio: json['bio'],
    birthday: json['birthday'],
    isActive: json['is_active'],
    isOnline: json['is_online'],
    lastSeen: json['last_seen'],
    name: json['name'],
    phone: json['phone'],
    username: json['username'],
  );
}

class MessageDTO {
  final String id;
  final String chatId;
  final String? content;
  final String createdAt;
  final String? fileName;
  final String? mediaUrl;
  final String messageType;
  final String receiverId;
  final String senderId;
  final String status;

  MessageDTO({required this.id, required this.chatId, this.content, required this.createdAt, this.fileName, this.mediaUrl, required this.messageType, required this.receiverId, required this.senderId, required this.status});
  
  factory MessageDTO.fromJson(Map<String, dynamic> json) => MessageDTO(
    id: json['id'],
    chatId: json['chat_id'],
    content: json['content'],
    createdAt: json['created_at'],
    fileName: json['file_name'],
    mediaUrl: json['media_url'],
    messageType: json['message_type'],
    receiverId: json['receiver_id'],
    senderId: json['sender_id'],
    status: json['status'],
  );
}
