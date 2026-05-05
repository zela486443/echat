import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/etok_video.dart';
import '../services/etok_service.dart';
import 'auth_provider.dart';

final etokServiceProvider = Provider((ref) => EtokService());

final creatorVideosProvider = FutureProvider.autoDispose<List<EtokVideo>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return [];
  
  final service = ref.watch(etokServiceProvider);
  return service.fetchUserVideos(user.id);
});

final creatorStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return {'likes': 0, 'followers': 0, 'following': 0};
  
  final service = ref.watch(etokServiceProvider);
  return service.fetchProfileStats(user.id);
});

// Mock analytics data for charts
final etokAnalyticsDataProvider = Provider((ref) {
  return {
    'views_history': [
      {'day': 'Mon', 'views': 1200},
      {'day': 'Tue', 'views': 1500},
      {'day': 'Wed', 'views': 1100},
      {'day': 'Thu', 'views': 1800},
      {'day': 'Fri', 'views': 2200},
      {'day': 'Sat', 'views': 2500},
      {'day': 'Sun', 'views': 2100},
    ],
    'audience_gender': [
      {'label': 'Female', 'value': 62.0},
      {'label': 'Male', 'value': 35.0},
      {'label': 'Other', 'value': 3.0},
    ],
    'audience_regions': [
      {'region': 'Addis Ababa', 'percent': 45},
      {'region': 'Nairobi', 'percent': 15},
      {'region': 'Dubai', 'percent': 10},
      {'region': 'Other', 'percent': 30},
    ]
  };
});
