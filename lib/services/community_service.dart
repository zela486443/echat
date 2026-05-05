import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Consolidated: closeFriendsService, storyHighlightService, topicService, groupBoostService, pollService, groupExtService
class CommunityService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addToCloseFriends(String contactId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('close_friends').insert({'user_id': userId, 'friend_id': contactId});
  }

  Future<void> createStoryHighlight(String title, List<String> storyIds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    final highlight = await _client.from('story_highlights').insert({
      'user_id': userId,
      'title': title
    }).select().single();

    for (var storyId in storyIds) {
      await _client.from('highlight_stories').insert({'highlight_id': highlight['id'], 'story_id': storyId});
    }
  }

  Future<void> createGroupTopic(String groupId, String topicName) async {
    await _client.from('group_topics').insert({'group_id': groupId, 'name': topicName});
  }

  Future<void> boostGroup(String groupId, int starsAmount) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.rpc('boost_group', params: {
      'p_user_id': userId,
      'p_group_id': groupId,
      'p_stars': starsAmount,
    });
  }

  Future<void> createPoll(String chatId, String question, List<String> options, bool multipleChoice) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final poll = await _client.from('polls').insert({
      'chat_id': chatId,
      'creator_id': userId,
      'question': question,
      'allow_multiple': multipleChoice,
    }).select().single();

    for (var option in options) {
      await _client.from('poll_options').insert({'poll_id': poll['id'], 'text': option});
    }
  }

  Future<void> voteOnPoll(String optionId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('poll_votes').insert({'option_id': optionId, 'user_id': userId});
  }
}

final communityProvider = Provider((ref) => CommunityService());
