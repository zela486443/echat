import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/username_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';

class UsernameSettingsScreen extends ConsumerStatefulWidget {
  const UsernameSettingsScreen({super.key});

  @override
  ConsumerState<UsernameSettingsScreen> createState() => _UsernameSettingsScreenState();
}

class _UsernameSettingsScreenState extends ConsumerState<UsernameSettingsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isChecking = false;
  bool? _isAvailable;
  String? _errorText;
  final _usernameService = UsernameService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAvailability(String value) async {
    if (value.isEmpty) {
      setState(() {
        _isAvailable = null;
        _isChecking = false;
        _errorText = null;
      });
      return;
    }

    if (value.length < 5) {
      setState(() {
        _isAvailable = false;
        _errorText = 'Username must be at least 5 characters';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorText = null;
    });

    try {
      final available = await _usernameService.isUsernameAvailable(value);
      setState(() {
        _isAvailable = available;
        _isChecking = false;
        if (!available) {
          _errorText = 'Username is already taken';
        }
      });
    } catch (e) {
      setState(() {
        _isChecking = false;
        _errorText = 'Error checking availability';
      });
    }
  }

  void _saveUsername() async {
    if (_isAvailable != true) return;

    setState(() => _isChecking = true);
    try {
      final success = await _usernameService.updateUsername(_controller.text);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          setState(() {
            _isChecking = false;
            _errorText = 'Failed to update username';
          });
        }
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
        _errorText = 'Error updating username';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Username'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withOpacity(0.1),
              Colors.black,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose a unique username',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'You can use a-z, 0-9 and underscores. Minimum length is 5 characters.',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
              const SizedBox(height: 32),
              GlassmorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _controller,
                  onChanged: _checkAvailability,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    prefixText: '@',
                    prefixStyle: TextStyle(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.bold),
                    hintText: 'username',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                    suffixIcon: _isChecking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _isAvailable == true
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : _isAvailable == false
                                ? const Icon(Icons.error, color: Colors.red)
                                : null,
                  ),
                ),
              ),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isAvailable == true && !_isChecking) ? _saveUsername : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.3),
                  ),
                  child: const Text('Save Username', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'People will be able to find you by this username and contact you without knowing your phone number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
