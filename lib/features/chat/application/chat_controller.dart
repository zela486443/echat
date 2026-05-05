import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../models/chat_model.dart';
import '../../../models/message_model.dart';
import '../data/chat_repository.dart';

// WebSocket Stream Providers
final chatListStreamProvider = StreamProvider.autoDispose<List<Chat>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  
  return ref.watch(chatRepositoryProvider).watchChats(user.id);
});

final chatMessagesStreamProvider = StreamProvider.family.autoDispose<List<Message>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
});

// Write Controller 
final chatControllerProvider = AsyncNotifierProvider<ChatController, void>(() {
  return ChatController();
});

class ChatController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> sendTextMessage(String chatId, String text) async {
    final user = ref.read(currentUserProvider);
    if (user == null || text.trim().isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(chatRepositoryProvider).sendTextMessage(chatId, user.id, text);
    });
  }

  Future<void> sendVoiceNote(String chatId, File audioFile, int durationMs) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(chatRepositoryProvider).sendVoiceNote(chatId, user.id, audioFile, durationMs);
    });
  }

  Future<void> createPoll(String chatId, String question, List<String> options) async {
    final user = ref.read(currentUserProvider);
    if (user == null || question.trim().isEmpty || options.isEmpty) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(chatRepositoryProvider).sendPoll(chatId, user.id, question, options);
    });
  }

  Future<void> createBillSplit(String chatId, String title, double totalAmount) async {
    final user = ref.read(currentUserProvider);
    if (user == null || title.trim().isEmpty || totalAmount <= 0) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(chatRepositoryProvider).sendBillSplit(chatId, user.id, title, totalAmount);
    });
  }
}
