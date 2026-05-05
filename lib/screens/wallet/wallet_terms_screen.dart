import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class WalletTermsScreen extends StatefulWidget {
  final VoidCallback onAccept;

  const WalletTermsScreen({super.key, required this.onAccept});

  @override
  State<WalletTermsScreen> createState() => _WalletTermsScreenState();
}

class _WalletTermsScreenState extends State<WalletTermsScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraGradientBg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 48),
                const SizedBox(height: 24),
                const Text(
                  'Wallet Terms of Service',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please review and accept our terms to activate your Echats Wallet.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GlassmorphicContainer(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTermSection('1. Digital Assets', 'The Echats Wallet allows you to store, send, and receive digital assets. We do not hold your private keys.'),
                          _buildTermSection('2. Fees', 'Transaction fees may apply for outgoing transfers. These are paid to the network nodes.'),
                          _buildTermSection('3. Security', 'You are responsible for maintaining the security of your account and PIN. Lost PINs cannot be recovered.'),
                          _buildTermSection('4. Liability', 'Echats is not responsible for any loss of funds due to user error or unauthorized access.'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Checkbox(
                      value: _accepted,
                      onChanged: (val) => setState(() => _accepted = val ?? false),
                      side: const BorderSide(color: Colors.white30),
                      activeColor: AppTheme.primary,
                    ),
                    const Expanded(
                      child: Text('I have read and agree to the Terms of Service', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _accepted ? widget.onAccept : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Accept & Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Decline', style: TextStyle(color: Colors.white38)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
