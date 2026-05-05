import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';
import 'auth_provider.dart';

final channelServiceProvider = Provider((ref) => ChannelService());

final myChannelsProvider = FutureProvider.autoDispose<List<Channel>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return ref.watch(channelServiceProvider).fetchMyChannels(user.id);
});

final subscribedChannelsProvider = FutureProvider.autoDispose<List<Channel>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  return ref.watch(channelServiceProvider).fetchSubscribedChannels(user.id);
});

final channelMessagesProvider = FutureProvider.family.autoDispose<List<Map<String, dynamic>>, String>((ref, channelId) async {
  return ref.watch(channelServiceProvider).fetchChannelMessages(channelId);
});
