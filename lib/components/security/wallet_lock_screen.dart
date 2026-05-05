import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WalletLockScreen extends StatelessWidget {
  final VoidCallback onUnlock;
  const WalletLockScreen({super.key, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.gradientAurora,
                boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 40)],
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 64),
            ),
            const SizedBox(height: 32),
            const Text('Wallet Locked', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Verify your identity to access your funds.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: onUnlock,
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.fingerprint, color: Colors.blueAccent, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text('Use Biometrics', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: onUnlock, // Mocking PIN entry success for now
              child: const Text('Enter PIN', style: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
      ),
    );
  }
}
