import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class LinkDesktopScreen extends StatelessWidget {
  const LinkDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Link a Device', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AuroraGradientBg(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.laptop_mac, size: 100, color: Colors.white24),
              const SizedBox(height: 32),
              const Text(
                'Use Echats on multiple devices',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Open echats.com on your computer and scan the QR code to link your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _openScanner(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Link a Device', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
              _buildHelpItem('1. Open echats.com on your computer'),
              _buildHelpItem('2. Go to Menu > Link Device'),
              _buildHelpItem('3. Point your phone to the screen to scan the code'),
            ],
          ),
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) {
    // Show a mock scanner overlay
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Spacer(),
            Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.primary, width: 2), borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.qr_code_scanner, color: Colors.white10, size: 150),
            ),
            const SizedBox(height: 24),
            const Text('Scan QR Code', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white24, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}
