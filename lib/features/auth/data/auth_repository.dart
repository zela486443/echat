import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../models/profile_model.dart';

class AuthRepository {
  final SupabaseClient client;
  final FlutterSecureStorage storage;

  AuthRepository({required this.client, required this.storage});

  static const String _authTokenKey = 'secure_auth_token';

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final response = await client.auth.signInWithPassword(email: email, password: password);
    await _cacheToken(response.session);
    return response;
  }

  Future<AuthResponse> signUpWithEmail(String email, String password, String name) async {
    final response = await client.auth.signUp(
      email: email, 
      password: password,
      data: {'name': name},
    );
    await _cacheToken(response.session);
    return response;
  }

  Future<bool> signInWithGoogle() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'echats://login-callback',
    );
    // Token caching is handled globally via onAuthStateChange stream.
  }

  Future<bool> signInWithApple() async {
    return await client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'echats://login-callback',
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
    await storage.delete(key: _authTokenKey);
  }

  Future<void> _cacheToken(Session? session) async {
    if (session != null) {
      await storage.write(key: _authTokenKey, value: session.accessToken);
    }
  }

  Future<bool> hasCachedToken() async {
    final token = await storage.read(key: _authTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<Profile?> getCurrentProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return Profile.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
