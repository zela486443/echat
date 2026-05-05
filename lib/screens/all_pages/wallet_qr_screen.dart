import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class WalletQRScreen extends ConsumerWidget {
  const WalletQRScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final walletId = user?.id ?? "0x7C3AED-WALLET-ID";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(top: -100, right: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF7C3AED).withOpacity(0.05), boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.1), blurRadius: 100, spreadRadius: 50)]))),
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                elevation: 0,
                leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
                title: const Text('My Wallet QR', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    children: [
                      const Text('Receive Payments', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      const Text('Show this QR code to any Echats user to receive instant transfers directly to your wallet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5)),
                      const SizedBox(height: 60),
                      
                      // QR Container
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 60, offset: const Offset(0, 20))],
                        ),
                        child: QrImageView(
                          data: walletId,
                          version: QrVersions.auto,
                          size: 240.0,
                          eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle, color: Color(0xFF0D0A1A)),
                          dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF0D0A1A)),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Wallet ID Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.wallet, color: Color(0xFF7C3AED), size: 18),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('WALLET ADDRESS', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)), Text(walletId, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'), maxLines: 1, overflow: TextOverflow.ellipsis)])),
                            IconButton(icon: const Icon(LucideIcons.copy, color: Colors.white38, size: 18), onPressed: () {}),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          onPressed: () {},
                          icon: const Icon(LucideIcons.share2, color: Colors.white, size: 20),
                          label: const Text('Share Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
