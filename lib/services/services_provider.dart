import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'undo_send_service.dart';
import 'link_preview_service.dart';
import 'silent_message_service.dart';
import 'sharing_prevention_service.dart';
import 'secret_chat_service.dart';
import 'verification_service.dart';
import 'username_service.dart';
import 'reminder_service.dart';
import 'reaction_service.dart';
import 'admin_service.dart';
import 'group_ext_service.dart';
import 'checklist_service.dart';
import 'per_message_timer_service.dart';
import 'profile_music_service.dart';
import 'chat_tag_service.dart';
import 'game_service.dart';

// Unified services provider file for easy imports throughout the app.

final appServicesProvider = Provider((ref) => {
  'undo': ref.watch(undoSendServiceProvider),
  'link': ref.watch(linkPreviewServiceProvider),
  'silent': ref.watch(silentMessageServiceProvider),
  'sharing': ref.watch(sharingPreventionServiceProvider),
  'secret': ref.watch(secretChatServiceProvider),
  'verification': ref.watch(verificationServiceProvider),
  'username': ref.watch(usernameServiceProvider),
  'reminder': ref.watch(reminderServiceProvider),
  'reaction': ref.watch(reactionServiceProvider),
  'admin': ref.watch(adminServiceProvider),
  'group_ext': ref.watch(groupExtServiceProvider),
  'checklist': ref.watch(checklistServiceProvider),
  'timer': ref.watch(perMessageTimerServiceProvider),
  'music': ref.watch(profileMusicServiceProvider),
  'tags': ref.watch(chatTagServiceProvider),
  'game': ref.watch(gameServiceProvider),
});
