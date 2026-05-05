import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/etok_video.dart';
import '../services/etok_service.dart';
import 'auth_provider.dart';

final etokServiceProvider = Provider<EtokService>((ref) {
  return EtokService();
});

final fypVideosProvider = FutureProvider.autoDispose<List<EtokVideo>>((ref) async {
  final service = ref.watch(etokServiceProvider);
  return service.fetchFYPVideos();
});

final followingVideosProvider = FutureProvider.autoDispose<List<EtokVideo>>((ref) async {
  final userProfile = ref.watch(authProvider).value;
  if (userProfile == null) return [];

  final service = ref.watch(etokServiceProvider);
  return service.fetchFollowingVideos(userProfile.id);
});

final etokTabProvider = StateProvider<int>((ref) => 1); // 0: Following, 1: FYP
