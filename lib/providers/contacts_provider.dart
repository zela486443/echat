import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

final profileSearchQueryProvider = StateProvider<String>((ref) => '');

final profileSearchResultsProvider = FutureProvider.autoDispose<List<Profile>>((ref) async {
  final query = ref.watch(profileSearchQueryProvider);
  if (query.length < 2) return [];

  final service = ref.watch(supabaseServiceProvider);
  return service.searchProfiles(query);
});

final suggestionsProvider = FutureProvider.autoDispose<List<Profile>>((ref) async {
  // Static suggestions for now, or fetch random profiles
  final service = ref.watch(supabaseServiceProvider);
  // This is a simple implementation, ideally would fetch "mutuals" or "nearby"
  return service.searchProfiles(''); // Just gets first 20 profiles
});
