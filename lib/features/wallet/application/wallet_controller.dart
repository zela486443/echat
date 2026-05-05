import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import '../../../models/wallet_model.dart';
import '../data/wallet_repository.dart';

final walletStreamProvider = StreamProvider.autoDispose<Wallet?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  
  return ref.watch(walletRepositoryProvider).watchWallet(user.id);
});

final walletControllerProvider = AsyncNotifierProvider<WalletController, void>(() {
  return WalletController();
});

class WalletController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> sendMoney(String recipientId, double amount, String note) async {
    final user = ref.read(currentUserProvider);
    if (user == null || amount <= 0) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      
      // Perform a secure Supabase RPC transaction
      await client.rpc('process_transfer', params: {
        'p_sender_id': user.id,
        'p_recipient_id': recipientId,
        'p_amount': amount,
        'p_note': note,
      });
    });
  }

  Future<void> requestMoney(String payerId, double amount, String note) async {
    final user = ref.read(currentUserProvider);
    if (user == null || amount <= 0) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      
      await client.from('payment_requests').insert({
        'requestor_id': user.id,
        'payer_id': payerId,
        'amount': amount,
        'note': note,
        'status': 'pending',
      });
    });
  }
}
