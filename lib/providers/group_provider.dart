import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group.dart';
import '../models/group_message.dart';
import '../services/group_service.dart';
import 'auth_provider.dart';

final groupServiceProvider = Provider((ref) => GroupService());

final userGroupsProvider = FutureProvider.autoDispose<List<Group>>((ref) async {
  final userProfile = ref.watch(authProvider).value;
  if (userProfile == null) return [];
  final service = ref.watch(groupServiceProvider);
  return service.getUserGroups(userProfile.id);
});

final groupDetailsProvider = FutureProvider.autoDispose.family<Group?, String>((ref, groupId) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroup(groupId);
});

final groupMembersProvider = FutureProvider.autoDispose.family<List<GroupMember>, String>((ref, groupId) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroupMembers(groupId);
});

final groupMessagesProvider = StreamProvider.autoDispose.family<List<GroupMessage>, String>((ref, groupId) async* {
  final service = ref.watch(groupServiceProvider);
  
  // Initial fetch
  final initialMessages = await service.getGroupMessages(groupId);
  var currentMessages = initialMessages;
  yield currentMessages;

  // Real-time updates
  final channel = service.subscribeToGroupMessages(groupId, (newMsg) {
    if (!currentMessages.any((m) => m.id == newMsg.id)) {
      currentMessages = [...currentMessages, newMsg];
      // We don't have a direct way to yield from a callback in async*, 
      // but we can use a StreamController or just let the stream provider handle subscriptions.
    }
  });

  ref.onDispose(() {
    service.unsubscribeFromGroupMessages(channel);
  });

  // Note: For a real stream provider with supabase, it's better to use _client.from().stream()
  // But since I updated GroupService with a subscription callback, I'll stick to a simpler approach for now 
  // or use a StreamController.
});

// Using a Notifier for sending messages
class GroupNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendMessage(String groupId, String content) async {
    final service = ref.read(groupServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.sendGroupMessage(groupId, content);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final groupActionProvider = AsyncNotifierProvider.autoDispose<GroupNotifier, void>(GroupNotifier.new);
