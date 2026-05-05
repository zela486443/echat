import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalPersistenceService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _pinnedPrefix = 'echat_pinned_chats_';
  static const String _archivedPrefix = 'echat_archived_chats_';
  static const String _mutedPrefix = 'echat_muted_chats_';

  Future<Set<String>> getPinned(String userId) async {
    final raw = await _storage.read(key: '$_pinnedPrefix$userId');
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw));
  }

  Future<void> savePinned(String userId, Set<String> pinned) async {
    await _storage.write(key: '$_pinnedPrefix$userId', value: jsonEncode(pinned.toList()));
  }

  Future<Set<String>> getArchived(String userId) async {
    final raw = await _storage.read(key: '$_archivedPrefix$userId');
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw));
  }

  Future<void> saveArchived(String userId, Set<String> archived) async {
    await _storage.write(key: '$_archivedPrefix$userId', value: jsonEncode(archived.toList()));
  }

  Future<Set<String>> getMuted(String userId) async {
    final raw = await _storage.read(key: '$_mutedPrefix$userId');
    if (raw == null) return {};
    return Set<String>.from(jsonDecode(raw));
  }

  Future<void> saveMuted(String userId, Set<String> muted) async {
    await _storage.write(key: '$_mutedPrefix$userId', value: jsonEncode(muted.toList()));
  }
}

final persistenceServiceProvider = Provider((ref) => LocalPersistenceService());

class ChatMetadata {
  final Set<String> pinned;
  final Set<String> archived;
  final Set<String> muted;

  ChatMetadata({
    required this.pinned,
    required this.archived,
    required this.muted,
  });

  ChatMetadata copyWith({
    Set<String>? pinned,
    Set<String>? archived,
    Set<String>? muted,
  }) {
    return ChatMetadata(
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      muted: muted ?? this.muted,
    );
  }
}

class ChatMetadataNotifier extends FamilyAsyncNotifier<ChatMetadata, String> {
  @override
  Future<ChatMetadata> build(String arg) async {
    final service = ref.watch(persistenceServiceProvider);
    final pinned = await service.getPinned(arg);
    final archived = await service.getArchived(arg);
    final muted = await service.getMuted(arg);
    return ChatMetadata(pinned: pinned, archived: archived, muted: muted);
  }

  Future<void> togglePin(String chatId) async {
    final current = state.value!;
    final nextPinned = Set<String>.from(current.pinned);
    if (nextPinned.contains(chatId)) {
      nextPinned.remove(chatId);
    } else {
      nextPinned.add(chatId);
    }
    state = AsyncValue.data(current.copyWith(pinned: nextPinned));
    await ref.read(persistenceServiceProvider).savePinned(arg, nextPinned);
  }

  Future<void> toggleArchive(String chatId) async {
    final current = state.value!;
    final nextArchived = Set<String>.from(current.archived);
    if (nextArchived.contains(chatId)) {
      nextArchived.remove(chatId);
    } else {
      nextArchived.add(chatId);
    }
    state = AsyncValue.data(current.copyWith(archived: nextArchived));
    await ref.read(persistenceServiceProvider).saveArchived(arg, nextArchived);
  }

  Future<void> toggleMute(String chatId) async {
    final current = state.value!;
    final nextMuted = Set<String>.from(current.muted);
    if (nextMuted.contains(chatId)) {
      nextMuted.remove(chatId);
    } else {
      nextMuted.add(chatId);
    }
    state = AsyncValue.data(current.copyWith(muted: nextMuted));
    await ref.read(persistenceServiceProvider).saveMuted(arg, nextMuted);
  }
}

final chatMetadataProvider = AsyncNotifierProviderFamily<ChatMetadataNotifier, ChatMetadata, String>(ChatMetadataNotifier.new);
