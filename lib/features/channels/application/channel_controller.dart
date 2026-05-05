import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';

final channelListProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  return ref.watch(supabaseClientProvider)
      .from('channels')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);
});

final channelControllerProvider = AsyncNotifierProvider<ChannelController, void>(() {
  return ChannelController();
});

class ChannelController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> createChannel(String name, String description) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseClientProvider).from('channels').insert({
        'name': name,
        'description': description,
        'owner_id': user.id,
      });
    });
  }

  Future<void> broadcastMessage(String channelId, String message) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(supabaseClientProvider).from('channel_messages').insert({
        'channel_id': channelId,
        'sender_id': user.id,
        'text': message,
      });
    });
  }
}
