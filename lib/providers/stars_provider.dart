import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stars_service.dart';

final starsServiceProvider = Provider((ref) => StarsService());

class StarsNotifier extends StateNotifier<int> {
  final StarsService _service;

  StarsNotifier(this._service) : super(100) {
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    state = await _service.getBalance();
  }

  Future<void> addStars(int amount) async {
    await _service.addStars(amount);
    state = await _service.getBalance();
  }

  Future<bool> deductStars(int amount) async {
    final success = await _service.deductStars(amount);
    if (success) {
      state = await _service.getBalance();
    }
    return success;
  }
}

final starsProvider = StateNotifierProvider<StarsNotifier, int>((ref) {
  final service = ref.watch(starsServiceProvider);
  return StarsNotifier(service);
});
