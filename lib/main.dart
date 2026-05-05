import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/supabase_client.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'providers/background_services_provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/app_lock_gate.dart';
import 'widgets/call_overlay.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/push_notification_service.dart';
import 'widgets/offline_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load DotEnv safely to mimic Vite web app environment handling
  await dotenv.load(fileName: ".env").catchError((_) {
    // Fails silently if .env isn't present
  });

  // 2. Initialize Supabase
  try {
    await SupabaseCore.initialize();
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
  }

  // 3. Initialize Firebase & Push Notifications
  try {
    await Firebase.initializeApp();
    await PushNotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase/Push Initialization Error: $e');
  }

  runApp(
    const ProviderScope(
      child: EchatsApp(),
    ),
  );
}

class EchatsApp extends ConsumerWidget {
  const EchatsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize background services
    ref.watch(backgroundServicesProvider);
    
    // Watch dynamic theme
    final accent = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Echats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(accent.color),
      darkTheme: AppTheme.getTheme(accent.color),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        return AppLockGate(
          child: Stack(
            children: [
              if (child != null) child,
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: OfflineBanner(),
              ),
              const _NotificationOverlay(),
              const CallOverlay(),
            ],
          ),
        );
      },
    );
  }
}

class _NotificationOverlay extends ConsumerWidget {
  const _NotificationOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(backgroundNotificationProvider);
    if (notification == null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          key: Key(notification.timestamp.toString()),
          onDismissed: (_) => ref.read(backgroundNotificationProvider.notifier).clear(), 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notification.color.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(color: notification.color.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8, 
                  decoration: BoxDecoration(color: notification.color, shape: BoxShape.circle)
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.message, 
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.white38), 
                  onPressed: () => ref.read(backgroundNotificationProvider.notifier).clear()
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
