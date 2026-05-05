import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math' as math;

class EtokOnboardingScreen extends ConsumerStatefulWidget {
  const EtokOnboardingScreen({super.key});

  @override
  ConsumerState<EtokOnboardingScreen> createState() => _EtokOnboardingScreenState();
}

class _EtokOnboardingScreenState extends ConsumerState<EtokOnboardingScreen> {
  int _step = 0; // 0: Welcome, 1: AccountType, 2: NewAccount, 3: Terms
  String? _accountType; // 'echat' or 'new'
  final PageController _pageController = PageController();
  
  final List<String> _avatars = ["🧑‍🎤", "👩‍🎨", "🧑‍💻", "👨‍🍳", "🧕", "👩‍🦱", "🧔", "👩‍🦰", "🧑‍🎨", "👩‍💻"];
  String _selectedAvatar = "🧑‍🎤";
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  void _nextStep() {
    if (_step < 3) {
      setState(() => _step++);
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glows
          _buildBackgroundDecoration(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcomeStep(),
                      _buildAccountTypeStep(),
                      _buildNewAccountStep(),
                      _buildTermsStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF0050).withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF20D5EC).withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _step > 0 
            ? InkWell(
                onTap: _prevStep,
                child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20)),
              )
            : const SizedBox(width: 40),
          Row(
            children: List.generate(3, (index) {
              bool active = (_step == index) || (_step == 2 && index == 1);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(color: active ? Colors.white : Colors.white24, borderRadius: BorderRadius.circular(2)),
              );
            }),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10),
              boxShadow: [BoxShadow(color: const Color(0xFFFF0050).withOpacity(0.3), blurRadius: 40)],
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF0050), Color(0xFF20D5EC)]).createShader(bounds),
                child: const Text('E', style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Etok', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
          const Text('by Echat', style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 20),
          const Text(
            'Share your moments. Discover amazing content. Connect with the world.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 60),
          _buildPrimaryButton('Get Started', onPressed: _nextStep),
        ],
      ),
    );
  }

  Widget _buildAccountTypeStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('How do you want to join Etok?', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Choose how to set up your Etok account', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 40),
          _buildOptionCard(
            title: 'Continue with Echat',
            subtitle: 'Use your existing Echat identity',
            icon: '👤',
            color: const Color(0xFFFF0050),
            isSelected: _accountType == 'echat',
            onTap: () => setState(() => _accountType = 'echat'),
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: 'Create new account',
            subtitle: 'Start fresh with a new identity',
            icon: '✨',
            color: const Color(0xFF20D5EC),
            isSelected: _accountType == 'new',
            onTap: () => setState(() => _accountType = 'new'),
          ),
          const Spacer(),
          _buildPrimaryButton('Continue', enabled: _accountType != null, onPressed: () {
            if (_accountType == 'new') {
              _nextStep();
            } else {
              setState(() => _step = 2); // Jump to terms
              _nextStep();
            }
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOptionCard({required String title, required String subtitle, required String icon, required Color color, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.white12, width: 2),
        ),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)), child: Center(child: Text(icon, style: const TextStyle(fontSize: 24)))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ]),
            ),
            if (isSelected) Icon(LucideIcons.check, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNewAccountStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('Create your profile', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 40),
          const Text('Profile Picture', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _avatars.length,
              itemBuilder: (context, i) => InkWell(
                onTap: () => setState(() => _selectedAvatar = _avatars[i]),
                child: Container(
                  width: 60, margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(color: _selectedAvatar == _avatars[i] ? const Color(0xFFFF0050).withOpacity(0.2) : Colors.white10, borderRadius: BorderRadius.circular(15), border: Border.all(color: _selectedAvatar == _avatars[i] ? const Color(0xFFFF0050) : Colors.transparent, width: 2)),
                  child: Center(child: Text(_avatars[i], style: const TextStyle(fontSize: 30))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField('Display Name', 'Your display name'),
          const SizedBox(height: 16),
          _buildTextField('Username', 'username', prefix: '@'),
          const Spacer(),
          _buildPrimaryButton('Continue', onPressed: _nextStep),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12)),
          child: Row(
            children: [
              if (prefix != null) Text(prefix, style: const TextStyle(color: Colors.white30, fontSize: 16)),
              Expanded(child: TextField(decoration: InputDecoration(hintText: placeholder, hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none), style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('Terms & Privacy', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
              child: const SingleChildScrollView(
                child: Text(
                  '1. Acceptance of Terms\nBy creating an Etok account or accessing Etok services, you confirm that you are at least 13 years of age...\n\n2. Your Account\nYou are responsible for maintaining the security of your account credentials...',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildCheckbox('I agree to the Terms of Service', _termsAccepted, (val) => setState(() => _termsAccepted = val!)),
          _buildCheckbox('I agree to the Privacy Policy', _privacyAccepted, (val) => setState(() => _privacyAccepted = val!)),
          const SizedBox(height: 24),
          _buildPrimaryButton('Create My Etok Account', enabled: _termsAccepted && _privacyAccepted, onPressed: () {
             context.go('/etok');
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: onChanged, activeColor: const Color(0xFFFF0050), side: const BorderSide(color: Colors.white30)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, {bool enabled = true, VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity, height: 56,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
