import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_message.dart';
import '../services/saved_messages_service.dart';
import 'auth_provider.dart';

final savedMessagesServiceProvider = Provider((ref) => SavedMessagesService());

final savedMessagesProvider = FutureProvider.autoDispose<List<SavedMessage>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];

  final service = ref.watch(savedMessagesServiceProvider);
  return service.getSavedMessages(user.id);
});
