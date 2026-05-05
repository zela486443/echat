import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// Provides the real-time stream of chats for the logged in user
final userChatsStreamProvider = StreamProvider.autoDispose<List<Chat>>((ref) {
  final userProfile = ref.watch(authProvider).value;
  if (userProfile == null) return const Stream.empty();

  final service = ref.watch(supabaseServiceProvider);
  return service.subscribeToChats(userProfile.id);
});

// A family provider to stream messages for a specific chat ID
final chatMessagesStreamProvider = StreamProvider.autoDispose.family<List<Message>, String>((ref, chatId) {
  final service = ref.watch(supabaseServiceProvider);
  
  // Real-time stream maps Map<String, dynamic> to Message model safely
  return service.messagesStream(chatId).map((dataList) {
    // Reverse sorting because UI list view builder builds from bottom-up
    return dataList.reversed.toList();
  });
});

// An action runner for chat-related mutations
class ChatNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    String? fileName,
    Map<String, dynamic>? metadata,
  }) async {
    final userProfile = ref.read(authProvider).value;
    if (userProfile == null) return null;

    final service = ref.read(supabaseServiceProvider);
    state = const AsyncValue.loading();
    
    try {
      final message = await service.sendMessage(
        chatId: chatId,
        senderId: userProfile.id,
        receiverId: receiverId,
        content: content,
        messageType: messageType,
        mediaUrl: mediaUrl,
        fileName: fileName,
        metadata: metadata,
      );
      state = const AsyncValue.data(null);
      return message?.id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final chatActionProvider = AsyncNotifierProvider.autoDispose<ChatNotifier, void>(ChatNotifier.new);

// Added: Provider to fetch profile for any given user ID
final profileProvider = FutureProvider.family<Profile?, String>((ref, userId) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getProfile(userId);
});

// Added: Search for profiles
final profileSearchQueryProvider = StateProvider<String>((ref) => '');

final searchProfilesProvider = FutureProvider.autoDispose<List<PublicProfile>>((ref) async {
  final query = ref.watch(profileSearchQueryProvider);
  if (query.length < 2) return [];
  
  final service = ref.watch(supabaseServiceProvider);
  return service.searchProfiles(query);
});
