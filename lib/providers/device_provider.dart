import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/device_service.dart';
import 'auth_provider.dart';

final deviceServiceProvider = Provider((ref) => DeviceService());

final deviceSessionsProvider = FutureProvider.autoDispose<List<DeviceSession>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  
  final service = ref.watch(deviceServiceProvider);
  return service.getSessions(user.id);
});

class DeviceActionNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> terminateSession(String sessionId) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    
    final service = ref.read(deviceServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.terminateSession(user.id, sessionId);
      state = const AsyncValue.data(null);
      ref.invalidate(deviceSessionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> terminateAllOthers() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    
    final service = ref.read(deviceServiceProvider);
    state = const AsyncValue.loading();
    try {
      await service.terminateAllOthers(user.id);
      state = const AsyncValue.data(null);
      ref.invalidate(deviceSessionsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final deviceActionProvider = AsyncNotifierProvider.autoDispose<DeviceActionNotifier, void>(DeviceActionNotifier.new);
