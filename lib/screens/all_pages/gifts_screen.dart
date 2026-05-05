import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stars_provider.dart';

// --- Design Tokens ---
const _kBg = Color(0xFF0D0A1A);
const _kCard = Color(0xFF16102A);
const _kPrimary = Color(0xFF7C3AED);

class GiftsPageScreen extends ConsumerStatefulWidget {
  const GiftsPageScreen({super.key});

  @override
  ConsumerState<GiftsPageScreen> createState() => _GiftsPageScreenState();
}

class _GiftsPageScreenState extends ConsumerState<GiftsPageScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _receivedGifts = [
    {'id': 'g1', 'name': 'Super Star', 'from': 'Alex Rivera', 'stars': 100, 'icon': LucideIcons.trophy},
    {'id': 'g2', 'name': 'Great Friend', 'from': 'Sarah Chen', 'stars': 250, 'icon': LucideIcons.heart},
    {'id': 'g3', 'name': 'Top Supporter', 'from': 'Jordan Lee', 'stars': 150, 'icon': LucideIcons.award},
    {'id': 'g4', 'name': 'Nitro Boost', 'from': 'Emily White', 'stars': 150, 'icon': LucideIcons.rocket},
  ];

  final List<Map<String, dynamic>> _sentGifts = [
    {'id': 's1', 'name': 'Birthday Cake', 'from': 'Mia Johnson', 'stars': 25, 'icon': LucideIcons.gift},
    {'id': 's2', 'name': 'Shooting Star', 'from': 'Carlos Kim', 'stars': 25, 'icon': LucideIcons.star},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          // Aurora background
          Positioned(top: -50, right: -50, child: _buildAurora(200, _kPrimary.withOpacity(0.1))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Column(
                    children: [
                      _buildTotalBalanceCard(),
                      _buildTabs(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildGiftGrid(_receivedGifts, "received"),
                            _buildGiftGrid(_sentGifts, "sent"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Spacing for bottom nav
              ],
            ),
          ),
          _buildSendGiftButton(),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildAurora(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 40)]),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: const Offset(0,0), end: const Offset(20,20), duration: 5.seconds);
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              'My Gifts',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.moreVertical, color: Colors.white38, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    final starsBalance = ref.watch(starsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [_kPrimary.withOpacity(0.3), _kPrimary.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: _kPrimary.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(color: _kPrimary.withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOTAL BALANCE',
              style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.8),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)],
                  ),
                  child: const Icon(LucideIcons.star, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  '$starsBalance Stars',
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().scale(delay: 100.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: _kPrimary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: _kPrimary,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          labelPadding: const EdgeInsets.only(right: 32),
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
          dividerColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildGiftGrid(List<Map<String, dynamic>> items, String type) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.gift, color: _kPrimary.withOpacity(0.2), size: 64),
            const SizedBox(height: 20),
            const Text('No gifts yet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              type == "received" ? "Gifts sent to you will appear here" : "Gifts you send will appear here",
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final gift = items[index];
        return _buildGiftCard(gift, index);
      },
    );
  }

  Widget _buildGiftCard(Map<String, dynamic> gift, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kPrimary.withOpacity(0.12)),
              ),
              child: Icon(gift['icon'], color: _kPrimary, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Text(gift['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: 'From: ',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              children: [
                TextSpan(text: gift['from'], style: const TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _kPrimary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.3), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.star, color: Colors.white, size: 10),
                const SizedBox(width: 6),
                Text('${gift['stars']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms).scale(delay: (index * 80).ms, curve: Curves.easeOut);
  }

  Widget _buildSendGiftButton() {
    return Positioned(
      bottom: 110,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: _kPrimary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 8)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Select a contact to send a gift'), backgroundColor: _kPrimary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.gift, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Send a Gift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0C1F).withOpacity(0.85),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(LucideIcons.wallet, 'WALLET', false, '/wallet'),
                _buildNavItem(LucideIcons.star, 'STARS', true, '/buy-stars'),
                _buildNavItem(LucideIcons.history, 'ACTIVITY', false, '/transaction-history'),
                _buildNavItem(LucideIcons.user, 'PROFILE', false, '/profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active, String route) {
    final color = active ? _kPrimary : Colors.white38;
    return GestureDetector(
      onTap: () => context.push(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: active ? FontWeight.w900 : FontWeight.bold, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}
