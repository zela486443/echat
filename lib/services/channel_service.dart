import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/channel.dart';

class ChannelService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Channel>> fetchMyChannels(String userId) async {
    try {
      final res = await _client.from('channels').select('*').eq('created_by', userId);
      return (res as List).map((e) => Channel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Channel>> fetchDiscoverChannels() async {
    try {
      final res = await _client.from('channels').select('*').limit(20);
      return (res as List).map((e) => Channel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Channel>> fetchSubscribedChannels(String userId) async {
    try {
      final res = await _client
          .from('channel_subscriptions')
          .select('channels(*)')
          .eq('user_id', userId);
      
      return (res as List).map((e) => Channel.fromJson(e['channels'])).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> createChannel(String name, String description, String userId) async {
    try {
      await _client.from('channels').insert({
        'name': name,
        'description': description,
        'created_by': userId,
        'avatar_color': '#FF0050',
      });
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<Channel?> getChannel(String id) async {
    try {
      final res = await _client.from('channels').select('*').eq('id', id).single();
      return Channel.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchChannelMessages(String channelId) async {
    try {
      final res = await _client
          .from('channel_messages')
          .select('*')
          .eq('channel_id', channelId)
          .order('created_at', ascending: true);
      return (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> sendChannelMessage(String channelId, String content, String authorId) async {
    try {
      await _client.from('channel_messages').insert({
        'channel_id': channelId,
        'content': content,
        'author_id': authorId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error sending channel message: $e');
    }
  }

  Future<bool> isSubscribed(String channelId, String userId) async {
    try {
      final res = await _client
          .from('channel_subscriptions')
          .select('id')
          .eq('channel_id', channelId)
          .eq('user_id', userId)
          .maybeSingle();
      return res != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleSubscription(String channelId, String userId) async {
    try {
      final sub = await isSubscribed(channelId, userId);
      if (sub) {
        await _client.from('channel_subscriptions').delete().eq('channel_id', channelId).eq('user_id', userId);
      } else {
        await _client.from('channel_subscriptions').insert({'channel_id': channelId, 'user_id': userId});
      }
    } catch (e) {
      print('Error toggling subscription: $e');
    }
  }
}
