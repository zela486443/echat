import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet.dart';

class WalletService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Wallet?> getWallet(String userId) async {
    try {
      final res = await _client.from('wallets').select('*').eq('user_id', userId).maybeSingle();
      if (res == null) return null;
      return Wallet.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTransaction(String id) async {
    try {
      final res = await _client
          .from('wallet_transactions')
          .select('*, recipient:profiles(name, username, avatar_url)')
          .eq('id', id)
          .maybeSingle();
      return res;
    } catch (e) {
      print('Error fetching transaction: $e');
      return null;
    }
  }

  Future<List<WalletTransaction>> fetchTransactions(String walletId) async {
    try {
      final res = await _client
          .from('wallet_transactions')
          .select('*')
          .eq('wallet_id', walletId)
          .order('created_at', ascending: false)
          .limit(20);
      return (res as List).map((e) => WalletTransaction.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getWalletBalance({bool forceRefresh = false}) async {
    try {
      final response = await _client.functions.invoke('wallet-balance');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching wallet balance: $e');
      return {};
    }
  }

  Stream<List<Map<String, dynamic>>> subscribeToWalletTable(String userId) {
    return _client
        .from('wallets')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId);
  }

  Future<Map<String, dynamic>> activateWallet() async {
    try {
      final response = await _client.functions.invoke('wallet-activate', body: {
        'user_agent': 'Flutter Mobile App',
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error activating wallet: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deposit(double amount, String method) async {
    try {
      final response = await _client.functions.invoke('wallet-deposit', body: {
        'amount': amount,
        'method': method,
        'idempotency_key': _generateIdempotencyKey(),
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error depositing: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> transfer(String recipientId, double amount, String? note) async {
    try {
      final response = await _client.functions.invoke('wallet-transfer', body: {
        'recipient_id': recipientId,
        'amount': amount,
        'note': note,
        'idempotency_key': _generateIdempotencyKey(),
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error transferring: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> splitBill({
    required List<String> userIds,
    required double totalAmount,
    required String description,
  }) async {
    try {
      final response = await _client.functions.invoke('wallet-split-bill', body: {
        'user_ids': userIds,
        'total_amount': totalAmount,
        'description': description,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error splitting bill: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    try {
      final response = await _client.from('savings_goals').insert({
        'name': name,
        'target_amount': targetAmount,
        'target_date': targetDate.toIso8601String(),
        'user_id': _client.auth.currentUser?.id,
      }).select().single();
      return response;
    } catch (e) {
      print('Error creating savings goal: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> requestMoney(String recipientId, double amount, String? reason) async {
    try {
      final response = await _client.functions.invoke('wallet-request-money', body: {
        'recipient_id': recipientId,
        'amount': amount,
        'reason': reason,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error requesting money: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> getSavingsGoals() async {
    try {
      final res = await _client
          .from('savings_goals')
          .select('*')
          .eq('user_id', _client.auth.currentUser?.id ?? '')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('Error fetching savings goals: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getScheduledPayments() async {
    try {
      final res = await _client
          .from('scheduled_payments')
          .select('*, recipient:profiles(name, username, avatar_url)')
          .eq('user_id', _client.auth.currentUser?.id ?? '')
          .order('scheduled_for', ascending: true);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print('Error fetching scheduled payments: $e');
      return [];
    }
  }

  Future<void> schedulePayment({
    required String recipientId,
    required double amount,
    required DateTime date,
    required String frequency, // daily, weekly, monthly
  }) async {
    try {
      await _client.from('scheduled_payments').insert({
        'recipient_id': recipientId,
        'amount': amount,
        'scheduled_for': date.toIso8601String(),
        'frequency': frequency,
        'user_id': _client.auth.currentUser?.id,
      });
    } catch (e) {
      print('Error scheduling payment: $e');
    }
  }

  String _generateIdempotencyKey() {
    return '${DateTime.now().millisecondsSinceEpoch}-${_client.auth.currentUser?.id}';
  }
}
