import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../chat/call_overlay.dart';

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  String _activeTab = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildTabsSliver(),
          _buildCallLogSliver(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 10,
        backgroundColor: const Color(0xFF7C3AED),
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ).animate().scale(delay: 400.ms, curve: Curves.backOut),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calls', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          Text('50 records', style: TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(LucideIcons.userPlus, color: Colors.white38, size: 20), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabsSliver() {
    final tabs = ['All', 'Missed'];
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: tabs.map((t) {
            final active = _activeTab == t;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = t),
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: active ? [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 10)] : null,
                  ),
                  child: Text(t, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCallLogSliver() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) return _buildSectionHeader('TODAY');
            if (index == 4) return _buildSectionHeader('YESTERDAY');
            return _buildCallItem(index);
          },
          childCount: 10,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: Text(label, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildCallItem(int index) {
    final isMissed = index == 2 || index == 5;
    final isVideo = index % 3 == 0;
    final isOutgoing = index % 2 == 0;
    final isLive = index == 1;

    return GestureDetector(
      onTap: () {
        CallOverlay.show(
          context,
          peerName: 'Contact ${index + 1}',
          type: isVideo ? CallType.video : CallType.voice,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF151122),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isMissed ? Colors.redAccent : (isOutgoing ? const Color(0xFF7C3AED) : const Color(0xFF10B981)),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), bottomLeft: Radius.circular(22)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                              ),
                            ),
                            child: const Center(child: Icon(LucideIcons.user, color: Colors.white24, size: 20)),
                          ),
                          Positioned(
                            bottom: -1, right: -1,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: isMissed ? Colors.redAccent : (isVideo ? const Color(0xFF7C3AED) : (isOutgoing ? const Color(0xFF10B981) : const Color(0xFF10B981))),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF151122), width: 2),
                              ),
                              child: Icon(
                                isMissed ? LucideIcons.phoneMissed : (isVideo ? LucideIcons.video : (isOutgoing ? LucideIcons.phoneCall : LucideIcons.phoneIncoming)),
                                color: Colors.white, size: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Contact ${index + 1}',
                                  style: TextStyle(color: isMissed ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                if (isLive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.withOpacity(0.3))),
                                    child: const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.black)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${isOutgoing ? 'Outgoing' : 'Incoming'} · 10:${index + 10} AM',
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (index % 4 == 0)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
                              child: const Text('1:24', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          Icon(isVideo ? LucideIcons.video : LucideIcons.phone, color: const Color(0xFF7C3AED).withOpacity(0.7), size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }
}
