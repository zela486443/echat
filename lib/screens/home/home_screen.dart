import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/offline_banner.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/speed_dial_fab.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/glassmorphic_container.dart';
import 'chats_screen.dart';
import '../calls/calls_screen.dart';
import '../etok/etok_screen.dart';
import '../all_pages/wallet_screen.dart';
import '../all_pages/profile_screen.dart';
import '../../services/smart_notif_service.dart';

import '../../widgets/in_app_tour_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _showTour = true;

  final List<Widget> _screens = [
    const ChatsScreen(),
    const CallsScreen(),
    const EtokScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Phase 6: Mock smart notification for verification
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(smartNotificationProvider.notifier).addNotification(SmartNotification(
          id: 'mock_1',
          title: 'Echats Security',
          body: 'A new device logged into your account.',
          priority: NotificationPriority.high,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final accent = ref.watch(themeProvider);

    return InAppTourWidget(
      onComplete: () => setState(() => _showTour = false),
      steps: [
        TourStep(title: 'Welcome to Echats', description: 'Experience the new native mobile app with premium features.', alignment: Alignment.center),
        TourStep(title: 'Global Search', description: 'Find friends, channels, and bots across the entire network.', alignment: Alignment.topCenter),
        TourStep(title: 'Smart Navigation', description: 'Easily switch between chats, calls, and the Etok video feed.', alignment: Alignment.bottomCenter),
        TourStep(title: 'Digital Wallet', description: 'Manage your stars and transactions securely in one place.', alignment: Alignment.bottomRight),
      ],
      child: Scaffold(
        drawer: _PremiumDrawer(user: user, accent: accent),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onIndexChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        floatingActionButton: _currentIndex == 0 ? const SpeedDialFAB() : null,
      ),
    );
  }
}

class _PremiumDrawer extends StatelessWidget {
  final dynamic user;
  final AccentColor accent;

  const _PremiumDrawer({required this.user, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      width: MediaQuery.of(context).size.width * 0.85,
      child: GlassmorphicContainer(
        borderRadius: 0,
        borderWidth: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D0A1A).withOpacity(0.95),
                const Color(0xFF150D28).withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _drawerItem(context, LucideIcons.user, 'My Profile', '/profile'),
                      _drawerItem(context, LucideIcons.bookmark, 'Saved Messages', '/saved-messages'),
                      _drawerItem(context, LucideIcons.users, 'Contacts', '/contacts'),
                      _drawerItem(context, LucideIcons.phone, 'Calls History', '/calls'),
                      _drawerItem(context, LucideIcons.wallet, 'Wallet', '/wallet'),
                      _drawerItem(context, LucideIcons.video, 'Etok Creator', '/etok/profile'),
                      const Divider(color: Colors.white10, height: 32),
                      _drawerItem(context, LucideIcons.settings, 'Settings', '/settings'),
                      _drawerItem(context, LucideIcons.shieldCheck, 'Privacy', '/privacy-settings'),
                      _drawerItem(context, LucideIcons.helpCircle, 'Help & Feedback', '/features'),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.color.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: accent.color.withOpacity(0.3), blurRadius: 20),
                  ],
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: const Color(0xFF1C1130),
                  backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                  child: user?.avatarUrl == null
                      ? Text(user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.moon, color: Colors.white60),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Echats User',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'No email set',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.color.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.sparkles, color: accent.color, size: 12),
                const SizedBox(width: 6),
                Text('PREMIUM', style: TextStyle(color: accent.color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white60, size: 22),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.white10,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('v1.0.5 (Stable)', style: TextStyle(color: Colors.white24, fontSize: 11)),
          Text('Echats Mobile', style: TextStyle(color: accent.color.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
