import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/stars_provider.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

class BuyStarsScreen extends ConsumerStatefulWidget {
  const BuyStarsScreen({super.key});

  @override
  ConsumerState<BuyStarsScreen> createState() => _BuyStarsScreenState();
}

class _BuyStarsScreenState extends ConsumerState<BuyStarsScreen> {
  
  void _showConfirmSheet(StarsPackage pkg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => _buildConfirmDialog(pkg),
    );
  }

  Widget _buildConfirmDialog(StarsPackage pkg) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        decoration: BoxDecoration(
          color: const Color(0xFF150D28).withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Confirm Purchase', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  _buildConfirmRow('Package', pkg.name),
                  const Divider(color: Colors.white10),
                  _buildConfirmRow('Stars', '${pkg.stars} ⭐'),
                  const Divider(color: Colors.white10),
                  _buildConfirmRow('Total Price', '${pkg.price} ETB', isPrice: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await ref.read(starsProvider.notifier).addStars(pkg.stars);
                if (mounted) {
                  Navigator.pop(context);
                  _showSuccessOverlay(pkg.stars);
                }
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                shadowColor: const Color(0xFF7C3AED).withOpacity(0.3),
              ), 
              child: const Text('Confirm & Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessOverlay(int amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('Success! Added $amount Stars to your wallet.', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: isPrice ? const Color(0xFF10B981) : Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final starsBalance = ref.watch(starsProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(
        children: [
          // Aurora background
          Positioned(top: -100, right: -50, child: _buildAurora(300, const Color(0xFF7C3AED).withOpacity(0.15))),
          Positioned(bottom: 100, left: -50, child: _buildAurora(250, const Color(0xFF10B981).withOpacity(0.1))),

          CustomScrollView(
            slivers: [
              _buildHeader(starsBalance),
              SliverToBoxAdapter(child: _buildHeroSection()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPackageCard(buyStarsPackages[index], index),
                    childCount: buyStarsPackages.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildPromoSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAurora(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: const Offset(0, 0), end: const Offset(30, 30), duration: 4.seconds);
  }

  Widget _buildHeader(int balance) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: const Text('Buy Stars', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ), 
            child: Row(children: [
              const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14), 
              const SizedBox(width: 6), 
              Text('$balance', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900))
            ])
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF10B981)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
            ),
            child: const Center(child: Icon(Icons.star, color: Colors.white, size: 40)),
          ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
          const SizedBox(height: 32),
          const Text('Virtual Currency for Gifts', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            'Stars are used to send gifts to friends and creators.\nSupports local payments in ETB.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(StarsPackage pkg, int index) {
    final isPopular = pkg.popular;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showConfirmSheet(pkg),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF150D28).withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isPopular ? const Color(0xFF7C3AED).withOpacity(0.5) : Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPopular ? [const Color(0xFF7C3AED), const Color(0xFF4C1D95)] : [Colors.white10, Colors.white.withOpacity(0.05)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.star, color: isPopular ? Colors.white : const Color(0xFFFBBF24), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(pkg.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF7C3AED), borderRadius: BorderRadius.circular(6)),
                            child: const Text('BEST VALUE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${pkg.stars} Stars in your wallet', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isPopular ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('${pkg.price.toInt()} ETB', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildPromoSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            const Icon(LucideIcons.gift, color: Color(0xFF7C3AED), size: 30),
            const SizedBox(height: 12),
            const Text('Have a promotional code?', style: TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Redeem Rewards', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}
