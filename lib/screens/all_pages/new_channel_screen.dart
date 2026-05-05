import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class NewChannelScreen extends ConsumerStatefulWidget {
  const NewChannelScreen({super.key});

  @override
  ConsumerState<NewChannelScreen> createState() => _NewChannelScreenState();
}

class _NewChannelScreenState extends ConsumerState<NewChannelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isPublic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileUpload(),
                  const SizedBox(height: 40),
                  _buildTextField('Channel Name', _nameController, 'Enter channel name'),
                  const SizedBox(height: 24),
                  _buildTextField('Description', _descController, 'What is this channel about?', maxLines: 3),
                  const SizedBox(height: 40),
                  const Text('CHANNEL TYPE', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  _buildTypeOption(true, 'Public Channel', 'Anyone can find and join the channel', LucideIcons.globe),
                  _buildTypeOption(false, 'Private Channel', 'Only people with an invite link can join', LucideIcons.lock),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      onPressed: () {},
                      child: const Text('Create Channel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
      title: const Text('New Channel', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProfileUpload() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: const Color(0xFF151122), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05), width: 2)),
            child: const Icon(LucideIcons.camera, color: Colors.white24, size: 32),
          ),
          Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle), child: const Icon(LucideIcons.plus, color: Colors.white, size: 16))),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(bool value, String title, String sub, IconData icon) {
    bool isSelected = _isPublic == value;
    return GestureDetector(
      onTap: () => setState(() => _isPublic = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? const Color(0xFF7C3AED).withOpacity(0.3) : Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF7C3AED) : Colors.white24, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 11))])),
            if (isSelected) const Icon(LucideIcons.checkCircle, color: Color(0xFF7C3AED), size: 18),
          ],
        ),
      ),
    );
  }
}
