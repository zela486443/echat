import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/auth_controller.dart';
import 'dart:io' show Platform;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true; // Mobile UX Enhancement
  
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  Future<void> _submit() async {
    final controller = ref.read(authControllerProvider.notifier);
    
    if (_isLogin) {
      await controller.signIn(_email.text.trim().toLowerCase(), _password.text);
    } else {
      await controller.signUp(_email.text.trim().toLowerCase(), _password.text, _name.text.trim());
    }
  }

  void _handleError(AsyncError error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.error.toString()), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Listen for state changes to navigate or show errors
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, state) {
      state.when(
        data: (_) {
          if (previous is AsyncLoading) context.go('/home');
        },
        error: (err, st) => _handleError(AsyncError(err, st)),
        loading: () {},
      );
    });

    final isLoading = ref.watch(authControllerProvider) is AsyncLoading;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Ornaments
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.primaryColor.withOpacity(0.3)),
            ),
          ),
          Positioned(
            bottom: -50, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.secondary.withOpacity(0.3)),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create Account',
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        if (!_isLogin) ...[
                          TextField(
                            controller: _name,
                            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                        ),
                        const SizedBox(height: 16),
                        
                        // Mobile UX Optimization: Single password field with visibility toggle
                        TextField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (_isLogin)
                          TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text('Forgot Password?', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
                          ),
                          
                        TextButton(
                          onPressed: () => setState(() {
                             _isLogin = !_isLogin;
                             _name.clear();
                             _password.clear();
                          }),
                          child: Text(_isLogin ? 'Need an account? Sign up' : 'Already have an account? Sign in', 
                            style: TextStyle(color: theme.primaryColor)),
                        ),
                        
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text('OR', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5))),
                            ),
                            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // OAuth Providers mapping
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        if (Platform.isIOS) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).signInWithApple(),
                            icon: const Icon(Icons.apple, size: 24),
                            label: const Text('Continue with Apple'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
