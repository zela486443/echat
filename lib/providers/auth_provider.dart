import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as spb;
import '../models/profile.dart';
import '../services/supabase_service.dart';

// Provides the singleton instance of the service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Provides the current authenticated user from Supabase
final authUserProvider = StreamProvider<spb.User?>((ref) {
  return spb.Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session?.user);
});

final profileStreamProvider = StreamProvider.autoDispose<Profile?>((ref) {
  final user = ref.watch(authUserProvider).value;
  if (user == null) return Stream.value(null);
  
  return spb.Supabase.instance.client
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', user.id)
      .map((data) => data.isEmpty ? null : Profile.fromJson(data.first));
});

enum AuthStatus { initial, unauthenticated, authenticated }

// Auth State Notifier migrating Zustand's useAuth.ts logic
class AuthNotifier extends AutoDisposeAsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    final profileAsync = ref.watch(profileStreamProvider);
    
    // Side effect: update online status when user is authenticated
    final user = ref.read(authUserProvider).value;
    if (user != null) {
      ref.read(supabaseServiceProvider).updateOnlineStatus(user.id, true);
      ref.onDispose(() {
        ref.read(supabaseServiceProvider).updateOnlineStatus(user.id, false);
      });
    }

    return profileAsync.value;
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await spb.Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      state = const AsyncValue.loading();
      await spb.Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'username': name.toLowerCase().replaceAll(' ', '_')},
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    final user = ref.read(authUserProvider).value;
    if (user != null) {
      await ref.read(supabaseServiceProvider).updateOnlineStatus(user.id, false);
    }
    await spb.Supabase.instance.client.auth.signOut();
  }
}

final authProvider = AsyncNotifierProvider.autoDispose<AuthNotifier, Profile?>(AuthNotifier.new);
