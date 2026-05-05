import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EtokOnboardingScreen extends ConsumerStatefulWidget {
  const EtokOnboardingScreen({super.key});

  @override
  ConsumerState<EtokOnboardingScreen> createState() => _EtokOnboardingScreenState();
}

class _EtokOnboardingScreenState extends ConsumerState<EtokOnboardingScreen> {
  int _currentStep = 0;
  String? _accountType;
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackgroundDecoration(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildCurrentStep(),
          ),
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [const Color(0xFFFF0050).withOpacity(0.1), Colors.transparent],
            center: const Alignment(1, -0.8),
            radius: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentStep == index ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(color: _currentStep == index ? Colors.white : Colors.white24, borderRadius: BorderRadius.circular(2)),
        )),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildWelcomeStep();
      case 1: return _buildAccountTypeStep();
      case 2: return _buildTermsStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12), boxShadow: [BoxShadow(color: const Color(0xFFFF0050).withOpacity(0.3), blurRadius: 40)]),
            child: const Center(child: Text('E', style: TextStyle(color: Color(0xFFFF0050), fontSize: 60, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(height: 40),
          const Text('Welcome to Etok', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('Share your moments. Discover amazing content. Connect with the world.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 60),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How do you want to join?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildTypeOption('Continue with Echat', 'Use your existing profile', LucideIcons.user, 'echat'),
          const SizedBox(height: 16),
          _buildTypeOption('Create new account', 'Start fresh with a new identity', LucideIcons.plus, 'new'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _accountType != null ? () => setState(() => _currentStep = 2) : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String title, String subtitle, IconData icon, String type) {
    final active = _accountType == type;
    return GestureDetector(
      onTap: () => setState(() => _accountType = type),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: active ? const Color(0xFFFF0050).withOpacity(0.1) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? const Color(0xFFFF0050) : Colors.white12, width: 2)),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFFFF0050) : Colors.white38, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ),
            if (active) const Icon(LucideIcons.checkCircle, color: Color(0xFFFF0050), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Terms & Privacy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: const SingleChildScrollView(
                child: Text('Terms of Service...\n\nBy joining, you confirm you are 13 years or older...', style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Checkbox(value: _termsAccepted, onChanged: (v) => setState(() => _termsAccepted = v!), activeColor: const Color(0xFFFF0050)),
              const Expanded(child: Text('I accept the Terms and Privacy Policy', style: TextStyle(color: Colors.white70, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _termsAccepted ? () => context.go('/etok') : null,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Complete Onboarding', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
