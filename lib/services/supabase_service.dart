import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:async/async.dart';
import 'dart:async';
import '../models/profile.dart';
import '../models/chat.dart';
import '../models/message.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // =============================================
  // AUTH FUNCTIONS
  // =============================================

  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    if (res.user != null) {
      await _client.from('profiles').upsert({
        'id': res.user!.id,
        'name': name,
        'email': email,
        'username': email.split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_'),
      });
    }
  }


  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return Profile.fromJson(data);
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<List<PublicProfile>> searchProfiles(String query) async {
    try {
      final term = query.replaceAll('@', '').toLowerCase().trim();
      if (term.isEmpty) return [];

      final data = await _client.rpc('search_users_public', params: {
        'search_term': term,
      });

      return (data as List).map((e) => PublicProfile.fromJson(e)).toList();
    } catch (e) {
      print('Error searching profiles: $e');
      return [];
    }
  }

  Future<Profile?> getProfileByUsername(String username) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('username', username)
          .maybeSingle();
          
      if (data == null) return null;
      return Profile.fromJson(data);
    } catch (e) {
      print('Error fetching profile by username: $e');
      return null;
    }
  }

  Future<Profile?> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final data = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
          
      return Profile.fromJson(data);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _client.from('profiles').update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      print('Error updating online status: $e');
    }
  }

  Future<List<Profile>> fetchNearbyProfiles() async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('is_online', true)
          .order('last_seen', ascending: false)
          .limit(20);
      return (res as List).map((p) => Profile.fromJson(p)).toList();
    } catch (e) {
      print('Nearby profiles error: $e');
      return [];
    }
  }

  // =============================================
  // CHAT FUNCTIONS
  // =============================================

  Future<String?> findOrCreateChat(String currentUserId, String otherUserId) async {
    try {
      final response = await _client.rpc('find_or_create_chat', params: {
        'user1_id': currentUserId,
        'user2_id': otherUserId,
      });
      return response as String?;
    } catch (e) {
      print('Error finding/creating chat: $e');
      return null;
    }
  }

  Future<List<Chat>> getChats(String userId) async {
    try {
      final data = await _client
          .from('chats')
          .select()
          .or('participant_1.eq.$userId,participant_2.eq.$userId')
          .order('last_message_time', ascending: false);
          
      return (data as List<dynamic>).map((e) => Chat.fromJson(e)).toList();
    } catch (e) {
      print('Error fetching chats: $e');
      return [];
    }
  }

  // Realtime subscription mapping
  Stream<List<Chat>> subscribeToChats(String userId) {
    final s1 = _client.from('chats').stream(primaryKey: ['id']).eq('participant_1', userId);
    final s2 = _client.from('chats').stream(primaryKey: ['id']).eq('participant_2', userId);

    // Combine streams manually to avoid one replacing the other
    List<Chat> list1 = [];
    List<Chat> list2 = [];

    final controller = StreamController<List<Chat>>.broadcast();

    void update() {
      final combined = [...list1, ...list2];
      final seen = <String>{};
      final unique = combined.where((c) => seen.add(c.id)).toList();
      unique.sort((a, b) => (b.lastMessageTime ?? b.createdAt).compareTo(a.lastMessageTime ?? a.createdAt));
      controller.add(unique);
    }

    final sub1 = s1.listen((data) {
      list1 = data.map((e) => Chat.fromJson(e)).toList();
      update();
    });

    final sub2 = s2.listen((data) {
      list2 = data.map((e) => Chat.fromJson(e)).toList();
      update();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // =============================================
  // MESSAGE FUNCTIONS
  // =============================================

  Future<Message?> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    String? fileName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final Map<String, dynamic> insertData = {
        'chat_id': chatId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'message_type': messageType.name,
        'status': 'sent',
      };

      if (mediaUrl != null) insertData['media_url'] = mediaUrl;
      if (fileName != null) insertData['file_name'] = fileName;
      if (metadata != null) insertData['metadata'] = metadata;

      final data = await _client.from('messages').insert(insertData).select().single();

      // Update chat's last message atomically
      await _client.from('chats').update({
        'last_message': messageType == MessageType.text ? content : '[Media]',
        'last_message_time': DateTime.now().toUtc().toIso8601String(),
        'last_sender_id': senderId,
      }).eq('id', chatId);

      return Message.fromJson(data);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  Future<List<Message>> getMessages(String chatId, {int limit = 50}) async {
    try {
      final data = await _client
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .limit(limit);

      // Reversing the list to match the UI flow
      final messages = (data as List<dynamic>).map((e) => Message.fromJson(e)).toList();
      return messages.reversed.toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<void> markAsRead(String chatId, String userId) async {
    try {
      await _client
          .from('messages')
          .update({'status': 'read'})
          .eq('chat_id', chatId)
          .neq('sender_id', userId)
          .neq('status', 'read');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Stream<List<Message>> messagesStream(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .map((data) => data.map((e) => Message.fromJson(e)).toList());
  }

  Future<String?> createGroup(String name, String description, List<String> memberIds) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _client.from('groups').insert({
        'name': name,
        'description': description,
        'creator_id': userId,
      }).select('id').single();

      final groupId = data['id'];

      for (var mid in {...memberIds, userId}) {
        await _client.from('group_members').insert({
          'group_id': groupId,
          'user_id': mid,
        });
      }
      return groupId;
    } catch (e) {
      print('Error creating group: $e');
      return null;
    }
  }
  // =============================================
  // REACTION FUNCTIONS
  // =============================================

  Future<void> addReaction(String messageId, String emoji) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('message_reactions').upsert({
        'message_id': messageId,
        'user_id': userId,
        'emoji': emoji,
      });
    } catch (e) {
      print('Error adding reaction: $e');
    }
  }

  Future<void> removeReaction(String messageId, String emoji) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client.from('message_reactions').delete().match({
        'message_id': messageId,
        'user_id': userId,
        'emoji': emoji,
      });
    } catch (e) {
      print('Error removing reaction: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> subscribeToReactions(String messageId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('id', messageId); // Simplified subscription
  }

  // =============================================
  // MEDIA FUNCTIONS
  // =============================================

  Future<String?> uploadFile(String bucket, String path, dynamic file) async {
    try {
      await _client.storage.from(bucket).upload(path, file);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // =============================================
  // BLOCK SERVICE
  // =============================================

  Future<void> blockUser(String userId) async {
    final currentId = _client.auth.currentUser?.id;
    if (currentId == null) return;
    try {
      await _client.from('blocked_users').insert({
        'blocker_id': currentId,
        'blocked_id': userId,
      });
    } catch (e) {
      print('Error blocking user: $e');
    }
  }
  // =============================================
  // PRESENCE FUNCTIONS (Typing Indicators)
  // =============================================

  RealtimeChannel subscribeToPresence(String chatId, Function(List<String>) onTypingChanged) {
    final userId = _client.auth.currentUser?.id;
    final channel = _client.channel('presence-$chatId');

    channel.onPresenceSync((payload) {
      final state = channel.presenceState();
      final typingIds = <String>[];
      
      for (final presence in state) {
        if (presence.key == userId) continue;
        for (final p in presence.presences) {
          final payload = p.payload;
          if (payload['is_typing'] == true && payload['user_id'] != null) {
            typingIds.add(payload['user_id'] as String);
          }
        }
      }
      onTypingChanged(typingIds.toSet().toList());
    }).subscribe();

    return channel;
  }

  Future<void> setTypingStatus(RealtimeChannel channel, bool isTyping) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await channel.track({
      'user_id': userId,
      'is_typing': isTyping,
    });
  }
}
