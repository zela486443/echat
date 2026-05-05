import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(authProvider).value;
      if (profile != null) {
        _nameController.text = profile.name ?? '';
        _usernameController.text = profile.username ?? '';
        _phoneController.text = profile.phoneNumber ?? '';
        _bioController.text = profile.bio ?? '';
      }
    });
  }

  void _handleUpdate() async {
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userId = ref.read(authProvider).value?.id;
      if (userId == null) return;

      final service = ref.read(supabaseServiceProvider);
      await service.updateProfile(userId, {
        'name': _nameController.text,
        'username': _usernameController.text,
        'phone': _phoneController.text,
        'bio': _bioController.text,
      });

      // Update provider state
      ref.invalidate(authProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF10B981))
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Update Profile', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.person_add_outlined, color: Colors.blue, size: 32)),
            const SizedBox(height: 16),
            const Text('Update Your Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter your profile details', style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 40),
            _buildInputSection('DISPLAY NAME', _nameController, hint: 'Enter your name'),
            const SizedBox(height: 20),
            _buildUsernameSection(),
            const SizedBox(height: 20),
            _buildInputSection('BIO', _bioController, hint: 'Tell us about yourself...', maxLines: 3),
            const SizedBox(height: 20),
            _buildCountrySection(),
            const SizedBox(height: 20),
            _buildPhoneSection(),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleUpdate,
                icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.person, color: Colors.white),
                label: Text(_isLoading ? 'Updating...' : 'Update Profile', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), disabledBackgroundColor: Colors.grey.withOpacity(0.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(String label, TextEditingController controller, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, 
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white), 
          decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
      ],
    );
  }

  Widget _buildUsernameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('USERNAME (UNIQUE)', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: _usernameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: const Text('@', style: TextStyle(color: Colors.white38, fontSize: 16))),
            hintText: 'username',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Must be unique. Others can find you with this.', style: TextStyle(color: Colors.white24, fontSize: 11)),
      ],
    );
  }

  Widget _buildCountrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('COUNTRY', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
          child: const Row(children: [Text('🇪🇹', style: TextStyle(fontSize: 18)), SizedBox(width: 12), Text('Ethiopia', style: TextStyle(color: Colors.white, fontSize: 14))]),
        ),
      ],
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PHONE NUMBER', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: const Text('+251', style: TextStyle(color: Colors.white38, fontSize: 14))),
            hintText: '9 XX XXX XXX',
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
