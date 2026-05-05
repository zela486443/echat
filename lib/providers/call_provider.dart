import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_log.dart';
import '../services/call_service.dart';
import 'auth_provider.dart';

final callServiceProvider = Provider<CallService>((ref) {
  return CallService();
});

final callLogsProvider = FutureProvider.autoDispose<List<CallLog>>((ref) async {
  final userProfile = ref.watch(authProvider).value;
  if (userProfile == null) return [];
  final service = ref.watch(callServiceProvider);
  return service.fetchCallLogs(userProfile.id);
});

final callLogsStreamProvider = StreamProvider.autoDispose<void>((ref) {
  final userProfile = ref.watch(authProvider).value;
  if (userProfile == null) return Stream.value(null);
  
  final service = ref.watch(callServiceProvider);
  return service.subscribeToCallLogs(userProfile.id);
});

