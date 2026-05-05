import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../core/security_utils.dart';

class AppLockGate extends ConsumerStatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _isLocked = false;
  bool _isLoading = true;
  final List<String> _pin = [];
  String? _correctPinHash;

  @override
  void initState() {
    super.initState();
    _checkLockStatus();
  }

  Future<void> _checkLockStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('app_lock_enabled') ?? false;
      final pinHash = prefs.getString('app_lock_pin');

      if (mounted) {
        setState(() {
          if (isEnabled && pinHash != null && pinHash.isNotEmpty) {
            _isLocked = true;
            _correctPinHash = pinHash;
          } else {
            _isLocked = false;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleKey(String key) {
    if (_pin.length < 4) {
      setState(() => _pin.add(key));
    }
    
    if (_pin.length == 4) {
      final inputPin = _pin.join();
      if (_correctPinHash != null && SecurityUtils.verifyPin(inputPin, _correctPinHash!)) {
        setState(() => _isLocked = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect PIN'), backgroundColor: Colors.redAccent)
        );
        setState(() => _pin.clear());
      }
    }
  }

  Future<void> _handleForgotPin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Forgot PIN?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You will need to remove the lock. You can set a new one in Privacy Settings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove Lock', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_lock_enabled', false);
      await prefs.remove('app_lock_pin');
      setState(() {
        _isLocked = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App lock removed'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    if (!_isLocked) return widget.child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F0F), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white24, size: 64),
              const SizedBox(height: 24),
              const Text('Echats Locked', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter your PIN to continue', style: TextStyle(color: Colors.white38, fontSize: 14)),
              const SizedBox(height: 48),
              
              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  bool active = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? AppTheme.primary : Colors.white10,
                      border: Border.all(color: active ? AppTheme.primary : Colors.white24),
                      boxShadow: active ? [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 10)] : null,
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 64),
              
              // Keypad
              SizedBox(
                width: 280,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.2,
                  children: [
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((k) => _buildKey(k)),
                    const SizedBox.shrink(),
                    _buildKey('0'),
                    _buildKey('del', icon: Icons.backspace_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _handleForgotPin,
                child: Text('Forgot PIN?', style: TextStyle(color: AppTheme.primary.withOpacity(0.7), decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String label, {IconData? icon}) {
    return InkWell(
      onTap: () {
        if (label == 'del') {
          if (_pin.isNotEmpty) setState(() => _pin.removeLast());
        } else {
          _handleKey(label);
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Center(
        child: icon != null 
          ? Icon(icon, color: Colors.white54, size: 24)
          : Text(label, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300)),
      ),
    );
  }
}

