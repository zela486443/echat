import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/wallet_service.dart';
import 'auth_provider.dart';
import 'stars_provider.dart';

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

final walletDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final userProfile = ref.watch(authProvider).value;
  if (userProfile == null) return {};

  final service = ref.watch(walletServiceProvider);
  final data = await service.getWalletBalance(forceRefresh: true);
  final stars = ref.watch(starsProvider);
  
  return {
    ...data,
    'stars': stars,
  };
});

final walletBalanceStreamProvider = StreamProvider.autoDispose<WalletBalance?>((ref) {
  final userProfile = ref.watch(authProvider).value;
  if (userProfile == null) return const Stream.empty();

  final service = ref.watch(walletServiceProvider);
  return service.subscribeToWalletTable(userProfile.id).map((event) {
    if (event.isEmpty) return null;
    return WalletBalance.fromJson(event.first);
  });
});

final transactionHistoryProvider = FutureProvider.autoDispose<List<Transaction>>((ref) async {
  final walletData = await ref.watch(walletDataProvider.future);
  final txns = walletData['transactions'] as List<dynamic>?;
  if (txns == null) return [];

  return txns.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
});

final savingsGoalsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getSavingsGoals();
});

final scheduledPaymentsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getScheduledPayments();
});

class WalletNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> sendMoney({
    required String receiverId,
    required double amount,
    String? description,
  }) async {
    final userProfile = ref.read(authProvider).value;
    if (userProfile == null) return;

    final service = ref.read(walletServiceProvider);
    state = const AsyncValue.loading();
    
    try {
      final res = await service.transfer(
        receiverId,
        amount,
        description,
      );
      
      if (res['success'] != true) throw Exception(res['error'] ?? 'Transaction failed');
      state = const AsyncValue.data(null);
      
      // Invalidate transaction history so it refetches
      ref.invalidate(transactionHistoryProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    final service = ref.read(walletServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.createSavingsGoal(
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(savingsGoalsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final walletActionProvider = AsyncNotifierProvider.autoDispose<WalletNotifier, void>(WalletNotifier.new);
