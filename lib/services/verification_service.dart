import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationService {
  final _client = Supabase.instance.client;

  /// Fetches the verification status of a user.
  /// Reads the `is_verified` column from the `profiles` table.
  Future<bool> isVerified(String userId) async {
    final res = await _client
        .from('profiles')
        .select('is_verified')
        .match({'id': userId})
        .maybeSingle();
    return res?['is_verified'] ?? false;
  }

  /// Checks if the user has a premium subscription.
  Future<bool> isPremiumUser(String userId) async {
    final res = await _client
        .from('profiles')
        .select('is_premium')
        .match({'id': userId})
        .maybeSingle();
    return res?['is_premium'] ?? false;
  }

  /// Get the verification level (e.g., 'standard', 'official', 'government').
  Future<String?> getVerificationType(String userId) async {
    final res = await _client
        .from('profiles')
        .select('verification_type')
        .match({'id': userId})
        .maybeSingle();
    return res?['verification_type'];
  }
}

final verificationServiceProvider = Provider<VerificationService>((ref) => VerificationService());
