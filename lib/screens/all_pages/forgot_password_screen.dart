import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  void _handleReset() {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop())),
      body: _isSent ? _buildSuccessState() : _buildInputState(),
    );
  }

  Widget _buildInputState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.mail_outline, color: Colors.blue, size: 40)),
          const SizedBox(height: 32),
          const Text('Forgot Password?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Enter your email and we\'ll send you a link to reset your password', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('EMAIL', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                TextField(controller: _emailController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'your@email.com', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleReset,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), disabledBackgroundColor: Colors.grey.withOpacity(0.2)),
              child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Send Reset Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: () => context.pop(), child: const Text('Back to Sign In', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.mark_email_read_outlined, color: const Color(0xFF10B981), size: 40)),
          const SizedBox(height: 32),
          const Text('Check your email', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(children: [const Text('We\'ve sent a password reset link to', style: TextStyle(color: Colors.white38, fontSize: 14)), Text(_emailController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))]),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
            child: Column(
              children: [
                _buildTaskRow('Click the link in your email to reset your password'),
                const SizedBox(height: 16),
                _buildTaskRow('After resetting, return here to sign in'),
              ],
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => context.pop(), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))), child: const Text('Back to Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
        ],
      ),
    );
  }

  Widget _buildTaskRow(String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle, color: Color(0xFFFF0050), size: 20), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)))]);
  }
}
