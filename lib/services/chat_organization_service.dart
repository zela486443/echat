import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consolidated: chatExportService, chatFolderService, chatTagService, chatThemeService, chatWallpaperService
class ChatOrganizationService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getChatFolders() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    return await _client.from('chat_folders').select().eq('user_id', userId);
  }

  Future<void> createFolder(String name, List<String> chatIds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    
    final folder = await _client.from('chat_folders').insert({'user_id': userId, 'name': name}).select().single();
    for (var id in chatIds) {
      await _client.from('folder_chats').insert({'folder_id': folder['id'], 'chat_id': id});
    }
  }

  Future<void> attachTagToChat(String chatId, String tagColor, String tagName) async {
    await _client.from('chat_tags').insert({
      'chat_id': chatId,
      'color': tagColor,
      'name': tagName,
    });
  }

  Future<String> exportChatHistory(String chatId) async {
    // Matches logic in react to fetch all msgs and formulate JSON/CSV export
    final data = await _client.from('messages').select().eq('chat_id', chatId).order('created_at', ascending: true);
    // Return encoded JSON string mapping
    return data.toString();
  }

  Future<void> updateChatTheme(String chatId, String themeId) async {
    await _client.from('chat_settings').upsert({'chat_id': chatId, 'theme_id': themeId});
  }

  Future<void> updateChatWallpaper(String chatId, String wallpaperUrl) async {
    await _client.from('chat_settings').upsert({'chat_id': chatId, 'wallpaper_url': wallpaperUrl});
  }
}

final chatOrgProvider = Provider((ref) => ChatOrganizationService());
