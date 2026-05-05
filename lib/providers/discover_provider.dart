import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';

final channelServiceProvider = Provider((ref) => ChannelService());

final discoverChannelsProvider = FutureProvider.autoDispose<List<Channel>>((ref) async {
  final service = ref.watch(channelServiceProvider);
  return service.fetchDiscoverChannels();
});
