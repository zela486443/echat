import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifiedAccount {
  final String userId;
  final bool isVerified;
  final String badgeType; // 'blue', 'gold', 'silver'
  final String? tier; // 'standard', 'premium', 'business'
  final DateTime? verifiedAt;

  VerifiedAccount({
    required this.userId,
    this.isVerified = false,
    this.badgeType = 'blue',
    this.tier,
    this.verifiedAt,
  });

  factory VerifiedAccount.fromJson(Map<String, dynamic> json) => VerifiedAccount(
    userId: json['id'] ?? '',
    isVerified: json['is_verified'] ?? false,
    badgeType: json['badge_type'] ?? 'blue',
    tier: json['verification_tier'],
    verifiedAt: json['verified_at'] != null ? DateTime.parse(json['verified_at']) : null,
  );
}

class VerificationService {
  static final VerificationService _instance = VerificationService._internal();
  factory VerificationService() => _instance;
  VerificationService._internal();

  final _client = Supabase.instance.client;
  final Map<String, VerifiedAccount?> _cache = {};

  /// Get verification status for a user
  Future<VerifiedAccount?> getVerification(String userId) async {
    if (_cache.containsKey(userId)) return _cache[userId];

    try {
      final response = await _client
          .from('profiles')
          .select('id, is_verified, badge_type, verification_tier, verified_at')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      final account = VerifiedAccount.fromJson(response);
      _cache[userId] = account.isVerified ? account : null;
      return account.isVerified ? account : null;
    } catch (e) {
      debugPrint('Verification check error: $e');
      return null;
    }
  }

  /// Check if user is premium
  Future<bool> isPremiumUser(String userId) async {
    final account = await getVerification(userId);
    return account?.tier == 'premium' || account?.tier == 'business';
  }

  /// Check if user is verified (quick check)
  Future<bool> isVerified(String userId) async {
    final account = await getVerification(userId);
    return account != null;
  }

  /// Add verification to a user (admin action)
  Future<void> addVerification(String userId, String badgeType, String tier) async {
    try {
      await _client.from('profiles').update({
        'is_verified': true,
        'badge_type': badgeType,
        'verification_tier': tier,
        'verified_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      _cache.remove(userId); // Invalidate cache
    } catch (e) {
      debugPrint('Add verification error: $e');
      rethrow;
    }
  }

  /// Remove verification from a user
  Future<void> removeVerification(String userId) async {
    try {
      await _client.from('profiles').update({
        'is_verified': false,
        'badge_type': null,
        'verification_tier': null,
        'verified_at': null,
      }).eq('id', userId);

      _cache.remove(userId);
    } catch (e) {
      debugPrint('Remove verification error: $e');
      rethrow;
    }
  }

  /// Clear cache
  void clearCache() => _cache.clear();
}
