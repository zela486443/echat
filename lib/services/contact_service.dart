import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ContactService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<PublicProfile>> getContacts(String userId) async {
    try {
      // Assuming a "contacts" table linking users exists in Supabase.
      // E.g., user_id (me) -> contact_id (them)
      final data = await _client
          .from('contacts')
          .select('..., profiles:contact_id(*)')
          .eq('user_id', userId);

      if (data == null) return [];

      return (data as List).map((e) {
        return PublicProfile.fromJson(e['profiles']);
      }).toList();
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  Future<List<PublicProfile>> searchGlobalUsers(String query) async {
    if (query.isEmpty) return [];
    try {
      final term = query.replaceAll('@', '').toLowerCase().trim();
      final data = await _client.rpc('search_users_public', params: {
        'search_term': term,
      });

      return (data as List).map((e) => PublicProfile.fromJson(e)).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<bool> addContact(String userId, String contactId) async {
    try {
      await _client.from('contacts').insert({
        'user_id': userId,
        'contact_id': contactId,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding contact: $e');
      return false;
    }
  }
}
