import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../core/security_utils.dart';

class WalletLockGate extends StatefulWidget {
  final Widget child;
  const WalletLockGate({super.key, required this.child});

  @override
  State<WalletLockGate> createState() => _WalletLockGateState();
}

class _WalletLockGateState extends State<WalletLockGate> {
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
      final isEnabled = prefs.getBool('wallet_lock_enabled') ?? false;
      final pinHash = prefs.getString('wallet_lock_pin');

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
    if (_pin.length < 4) setState(() => _pin.add(key));
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
        title: const Text('Forgot Wallet PIN?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Removing the wallet lock will allow access to the wallet features. You can set a new one later.',
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
      await prefs.setBool('wallet_lock_enabled', false);
      await prefs.remove('wallet_lock_pin');
      setState(() {
        _isLocked = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallet lock removed'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }
    if (!_isLocked) return widget.child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, color: Colors.blueAccent, size: 64),
            const SizedBox(height: 24),
            const Text('Wallet Locked', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter Wallet PIN', style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 48),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 12, height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _pin.length ? Colors.blueAccent : Colors.white10,
                ),
              )),
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: 240,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'].map((k) {
                    if (k == '') return const SizedBox.shrink();
                    return _buildKey(k);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: _handleForgotPin,
              child: const Text('Forgot PIN?', style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String label) {
    return InkWell(
      onTap: () {
        if (label == 'del') {
          if (_pin.isNotEmpty) setState(() => _pin.removeLast());
        } else {
          _handleKey(label);
        }
      },
      child: Center(
        child: label == 'del' 
          ? const Icon(Icons.backspace_outlined, color: Colors.white38) 
          : Text(label, style: const TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}

