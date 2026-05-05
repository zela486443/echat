import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = true;
  bool _showPassword = false;
  bool _loading = false;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _handleAuth() async {
    setState(() => _loading = true);
    final supabase = ref.read(supabaseServiceProvider);
    
    try {
      if (_isSignUp) {
        // Mock sign up logic
        await Future.delayed(const Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Welcome to Echats.')));
      } else {
        // Mock sign in logic
        await Future.delayed(const Duration(seconds: 1));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome back!')));
      }
      context.go('/chats');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(
        children: [
          _buildBackgroundBlobs(),
          _buildDotGrid(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildAuthCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        _buildBlob(const Color(0xFF7C3AED).withOpacity(0.18), -80, -80, 300),
        _buildBlob(Colors.purple.withOpacity(0.15), 100, 200, 250),
        _buildBlob(Colors.pink.withOpacity(0.14), -60, 400, 220),
      ],
    );
  }

  Widget _buildBlob(Color color, double top, double left, double size) {
    return Positioned(
      top: top, left: left,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ),
    );
  }

  Widget _buildDotGrid() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF151122).withOpacity(0.88),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 60, offset: const Offset(0, 30))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(height: 12),
          const Text('Echats', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          Text(_isSignUp ? 'Create your free account' : 'Welcome back 👋', style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 32),
          _buildTabToggle(),
          const SizedBox(height: 24),
          if (_isSignUp) ...[
            _buildInputField(LucideIcons.user, 'Username', _usernameController, '@username'),
            const SizedBox(height: 16),
          ],
          _buildInputField(LucideIcons.mail, 'Email', _emailController, 'your@email.com'),
          const SizedBox(height: 16),
          _buildInputField(LucideIcons.lock, 'Password', _passwordController, '••••••••', isPassword: true),
          if (_isSignUp) ...[
            const SizedBox(height: 16),
            _buildInputField(LucideIcons.lock, 'Confirm Password', _confirmPasswordController, '••••••••', isPassword: true),
          ],
          if (!_isSignUp) 
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          Text(
            _isSignUp ? 'By signing up you agree to our Terms of Service' : '🔒 End-to-end encrypted · Your data stays private',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 68, height: 68,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF6D28D9).withOpacity(0.4), blurRadius: 20)],
      ),
      child: const Icon(LucideIcons.messageSquare, color: Colors.white, size: 32),
    );
  }

  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Sign Up', _isSignUp, () => setState(() => _isSignUp = true))),
          Expanded(child: _buildTabButton('Sign In', !_isSignUp, () => setState(() => _isSignUp = false))),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: active ? const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]) : null,
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildInputField(IconData icon, String label, TextEditingController controller, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              Icon(icon, color: Colors.white24, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isPassword && !_showPassword,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white12), border: InputBorder.none),
                ),
              ),
              if (isPassword) 
                IconButton(icon: Icon(_showPassword ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.white24, size: 16), onPressed: () => setState(() => _showPassword = !_showPassword)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _loading ? null : _handleAuth,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF6D28D9).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: _loading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.sparkles, color: Colors.white, size: 18),
                  const SizedBox(width: 12),
                  Text(_isSignUp ? 'Create Account' : 'Sign In', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
        ),
      ),
    );
  }
}
