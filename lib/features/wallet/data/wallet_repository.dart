import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/wallet_model.dart';

class WalletRepository {
  final SupabaseClient client;

  WalletRepository({required this.client});

  Stream<Wallet?> watchWallet(String userId) {
    return client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data.isNotEmpty ? Wallet.fromJson(data.first) : null);
  }

  Future<void> addFunds(String userId, double amount) async {
    // In production, this goes through a secure server.
    // For mapping purposes, calling an RPC or direct update.
    await client.rpc('add_wallet_funds', params: {
      'p_user_id': userId,
      'p_amount': amount,
    });
  }
}
