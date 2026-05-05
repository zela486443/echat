import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/chat_screen.dart';

import 'screens/all_pages/add_account_screen.dart';
import 'screens/all_pages/update_profile_screen.dart';
import 'screens/all_pages/add_group_members_screen.dart';
import 'screens/all_pages/add_money_screen.dart';
import 'screens/all_pages/aiassistant_screen.dart';
import 'screens/all_pages/bot_chat_screen.dart';
import 'screens/all_pages/bots_screen.dart';
import 'screens/all_pages/broadcast_list_screen.dart';
import 'screens/all_pages/business_profile_settings_screen.dart';
import 'screens/all_pages/buy_stars_screen.dart';
import 'screens/calls/calls_screen.dart';
import 'screens/calls/active_call_screen.dart';
import 'screens/calls/incoming_call_screen.dart';
import 'screens/all_pages/channels_screen.dart';
import 'screens/all_pages/channel_view_screen.dart';
import 'screens/all_pages/chat_stats_screen.dart';
import 'screens/all_pages/close_friends_screen.dart';
import 'screens/all_pages/contacts_screen.dart';
import 'screens/all_pages/data_storage_settings_screen.dart';
import 'screens/etok/etok_screen.dart';
import 'screens/etok/etok_analytics_screen.dart';
import 'screens/etok/etok_camera_screen.dart';
import 'screens/etok/etok_live_screen.dart';
import 'screens/etok/etok_profile_screen.dart';
import 'screens/etok/etok_search_screen.dart';
import 'screens/etok/etok_settings_screen.dart';
import 'screens/etok/etok_onboarding_screen.dart';
import 'screens/all_pages/features_screen.dart';
import 'screens/all_pages/forgot_password_screen.dart';
import 'screens/all_pages/gifts_screen.dart';
import 'screens/all_pages/global_search_screen.dart';
import 'screens/all_pages/group_call_screen.dart';
import 'screens/all_pages/group_chat_screen.dart';
import 'screens/all_pages/index_screen.dart';
import 'screens/etok/live_stories_screen.dart';
import 'screens/all_pages/nearby_people_screen.dart';
import 'screens/all_pages/new_contact_screen.dart';
import 'screens/all_pages/not_found_screen.dart';
import 'screens/all_pages/notification_settings_screen.dart';
import 'screens/all_pages/payment_request_screen.dart';
import 'screens/all_pages/privacy_settings_screen.dart';
import 'screens/all_pages/appearance_settings_screen.dart';
import 'screens/etok/stories_screen.dart';
import 'screens/all_pages/profile_screen.dart';
import 'screens/all_pages/quick_replies_settings_screen.dart';
import 'screens/all_pages/reminders_screen.dart';
import 'screens/all_pages/request_money_screen.dart';
import 'screens/all_pages/savings_goals_screen.dart';
import 'screens/all_pages/scheduled_payments_screen.dart';
import 'screens/all_pages/send_money_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/active_sessions_screen.dart';
import 'screens/contacts/contact_profile_screen.dart';
import 'screens/contacts/new_message_screen.dart';
import 'screens/contacts/new_group_screen.dart';
import 'screens/chats/saved_messages_screen.dart';
import 'screens/wallet/transaction_history_screen.dart';
import 'screens/wallet/transaction_detail_screen.dart';
import 'screens/all_pages/sound_settings_screen.dart';
import 'screens/wallet/transaction_receipt_screen.dart';
import 'screens/all_pages/voice_chat_room_screen.dart';
import 'screens/all_pages/wallet_screen.dart' as wal;
import 'screens/all_pages/wallet_qr_screen.dart';
import 'screens/all_pages/new_channel_screen.dart';
import 'screens/groups/group_info_screen.dart';
import 'screens/settings/username_settings_screen.dart';
import 'widgets/wallet_lock_gate.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/chat/:id', builder: (context, state) => ChatScreen(chatId: state.pathParameters['id']!)),

      // Core Modules
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/username-settings', builder: (context, state) => const UsernameSettingsScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/profile/:userId', builder: (context, state) => ContactProfileScreen(userId: state.pathParameters['userId']!)),
      GoRoute(path: '/contact/:userId', builder: (context, state) => ContactProfileScreen(userId: state.pathParameters['userId']!)),
      GoRoute(path: '/contacts', builder: (context, state) => const ContactsScreen()),
      GoRoute(path: '/calls', builder: (context, state) => const CallsScreen()),
      
      // Wallet & Finance
      GoRoute(path: '/wallet', builder: (context, state) => const WalletLockGate(child: wal.WalletScreen())),
      GoRoute(path: '/wallet-qr', builder: (context, state) => const WalletLockGate(child: WalletQRScreen())),
      GoRoute(path: '/wallet/qr', builder: (context, state) => const WalletLockGate(child: WalletQRScreen())),
      GoRoute(path: '/add-money', builder: (context, state) => const WalletLockGate(child: AddMoneyScreen())),
      GoRoute(path: '/send-money', builder: (context, state) => const WalletLockGate(child: SendMoneyScreen())),
      GoRoute(path: '/request-money', builder: (context, state) => const WalletLockGate(child: RequestMoneyScreen())),
      GoRoute(path: '/payment-request', builder: (context, state) => const WalletLockGate(child: PaymentRequestScreen())),
      GoRoute(path: '/transaction-history', builder: (context, state) => const WalletLockGate(child: TransactionHistoryScreen())),
      GoRoute(path: '/transaction-detail/:transactionId', builder: (context, state) => WalletLockGate(child: TransactionDetailScreen(transactionId: state.pathParameters['transactionId']!))),
      GoRoute(
        path: '/transaction-receipt', 
        builder: (context, state) {
          final tx = state.extra as Map<String, dynamic>;
          return TransactionReceiptScreen(transaction: tx);
        }
      ),
      GoRoute(path: '/scheduled-payments', builder: (context, state) => const ScheduledPaymentsScreen()),
      GoRoute(path: '/savings-goals', builder: (context, state) => const SavingsGoalsScreen()),
      GoRoute(path: '/buy-stars', builder: (context, state) => const BuyStarsScreen()),
      GoRoute(path: '/gifts', builder: (context, state) => const GiftsPageScreen()),

      // Social & Etok
      GoRoute(path: '/etok', builder: (context, state) => const EtokScreen()),
      GoRoute(path: '/etok/analytics', builder: (context, state) => const EtokAnalyticsScreen()),
      GoRoute(path: '/etok/camera', builder: (context, state) => const EtokCameraScreen()),
      GoRoute(path: '/etok/live', builder: (context, state) => const EtokLiveScreen()),
      GoRoute(path: '/etok/profile', builder: (context, state) => const EtokProfileScreen()),
      GoRoute(path: '/etok/profile/:userId', builder: (context, state) => EtokProfileScreen(userId: state.pathParameters['userId']!)),
      GoRoute(path: '/etok/search', builder: (context, state) => const EtokSearchScreen()),
      GoRoute(path: '/etok/settings', builder: (context, state) => const EtokSettingsScreen()),
      GoRoute(path: '/stories', builder: (context, state) => const StoriesScreen()),
      GoRoute(path: '/etok/onboarding', builder: (context, state) => const EtokOnboardingScreen()),
      GoRoute(path: '/live-stories', builder: (context, state) => const LiveStoriesScreen()),
      GoRoute(path: '/close-friends', builder: (context, state) => const CloseFriendsScreen()),

      // Discovery & Utilities
      GoRoute(path: '/nearby', builder: (context, state) => const NearbyPeopleScreen()),
      GoRoute(path: '/global-search', builder: (context, state) => const GlobalSearchScreen()),
      GoRoute(path: '/ai-assistant', builder: (context, state) => const AIAssistantScreen()),
      GoRoute(path: '/reminders', builder: (context, state) => const RemindersScreen()),
      GoRoute(path: '/features', builder: (context, state) => const FeaturesScreen()),
      GoRoute(path: '/chat-stats', builder: (context, state) => const ChatStatsScreen()),
      GoRoute(path: '/chat-stats/:id', builder: (context, state) => const ChatStatsScreen()),
      GoRoute(path: '/broadcast', builder: (context, state) => const BroadcastListScreen()),

      // Communication Hub
      GoRoute(path: '/channels', builder: (context, state) => const ChannelsScreen()),
      GoRoute(path: '/channel/:id', builder: (context, state) => ChannelViewScreen(channelId: state.pathParameters['id']!)),
      GoRoute(path: '/new-channel', builder: (context, state) => const NewChannelScreen()),
      GoRoute(path: '/bots', builder: (context, state) => const BotsScreen()),
      GoRoute(path: '/bot/:id', builder: (context, state) => BotChatScreen(botId: state.pathParameters['id']!)),
      GoRoute(path: '/voice-chat/:id', builder: (context, state) => VoiceChatRoomScreen(roomId: state.pathParameters['id']!)),
      GoRoute(path: '/group-call/:roomId', builder: (context, state) => GroupCallScreen(roomId: state.pathParameters['roomId']!)),
      GoRoute(path: '/group-chat/:id', builder: (context, state) => GroupChatScreen(groupId: state.pathParameters['id']!)),
      GoRoute(path: '/add-group-members', builder: (context, state) => const AddGroupMembersScreen()),
      GoRoute(path: '/new-group', builder: (context, state) => const NewGroupScreen()),
      GoRoute(path: '/new-message', builder: (context, state) => const NewMessageScreen()),
      GoRoute(path: '/new-contact', builder: (context, state) => const NewContactScreen()),
      GoRoute(path: '/saved-messages', builder: (context, state) => const SavedMessagesScreen()),

      // Settings & Security
      GoRoute(path: '/notification-settings', builder: (context, state) => const NotificationSettingsScreen()),
      GoRoute(path: '/data-storage-settings', builder: (context, state) => const DataStorageSettingsScreen()),
      GoRoute(path: '/privacy-settings', builder: (context, state) => const PrivacySettingsScreen()),
      GoRoute(path: '/appearance-settings', builder: (context, state) => const AppearanceSettingsScreen()),
      GoRoute(path: '/sound-settings', builder: (context, state) => const SoundSettingsScreen()),
      GoRoute(path: '/quick-replies', builder: (context, state) => const QuickRepliesSettingsScreen()),
      GoRoute(path: '/active-sessions', builder: (context, state) => const ActiveSessionsScreen()),
      GoRoute(path: '/update-profile', builder: (context, state) => const UpdateProfileScreen()),
      GoRoute(path: '/add-account', builder: (context, state) => const UpdateProfileScreen()), // Reusing update profile
      GoRoute(path: '/delete-account', builder: (context, state) => const Scaffold(body: Center(child: Text('Delete Account')))),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/business-profile', builder: (context, state) => const BusinessProfileSettingsScreen()),
      GoRoute(path: '/active-call', builder: (context, state) => const ActiveCallScreen()),
      GoRoute(path: '/incoming-call', builder: (context, state) => const IncomingCallScreen()),
    ],
  );
});
