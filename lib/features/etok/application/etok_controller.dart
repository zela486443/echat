import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers.dart';
import 'package:camera/camera.dart';

final etokControllerProvider = AsyncNotifierProvider<EtokController, void>(() {
  return EtokController();
});

class EtokController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> publishVideo(String filePath, String caption) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Logic from etokCreatorService.ts
      final client = ref.read(supabaseClientProvider);
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final fileData = await XFile(filePath).readAsBytes();
      
      await client.storage.from('etok_videos').uploadBinary(fileName, fileData);
      final videoUrl = client.storage.from('etok_videos').getPublicUrl(fileName);
      
      await client.from('etok_posts').insert({
        'user_id': user.id,
        'video_url': videoUrl,
        'caption': caption,
        'likes': 0,
        'shares': 0,
      });
    });
  }

  Future<void> likePost(String postId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Fire and forget optimistic update mapping from React
    final client = ref.read(supabaseClientProvider);
    try {
      await client.rpc('increment_etok_like', params: {'p_post_id': postId});
    } catch (_) {
      // Silently handle error for optimistic UI
    }
  }
}

// Stream provider mapping etokService.ts global feed
final etokFeedProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.read(supabaseClientProvider)
      .from('etok_posts')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .limit(10);
});
