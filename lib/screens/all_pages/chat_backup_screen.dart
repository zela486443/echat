import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class ChatBackupScreen extends StatefulWidget {
  const ChatBackupScreen({super.key});

  @override
  State<ChatBackupScreen> createState() => _ChatBackupScreenState();
}

class _ChatBackupScreenState extends State<ChatBackupScreen> {
  bool _backingUp = false;
  double _progress = 0.0;

  void _startBackup() async {
    setState(() { _backingUp = true; _progress = 0.0; });
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _progress = i / 100);
    }
    setState(() => _backingUp = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Backup completed successfully!'), backgroundColor: AppTheme.primary));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Chat Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(LucideIcons.cloudUpload, color: AppTheme.primary, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Back up your messages', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Back up your messages and media to your storage. If you lose your phone or switch to a new one, you can restore them.',
              style: TextStyle(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildLastBackupInfo(),
            const Spacer(),
            if (_backingUp) ...[
              LinearProgressIndicator(value: _progress, backgroundColor: Colors.white10, color: AppTheme.primary, minHeight: 6, borderRadius: BorderRadius.circular(3)),
              const SizedBox(height: 12),
              Text('Backing up... ${(_progress * 100).round()}%', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 32),
            ] else 
              _buildBackupButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLastBackupInfo() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _infoRow('Last Backup', 'May 5, 2026 at 10:30 AM'),
          const Divider(color: Colors.white10, height: 24),
          _infoRow('Size', '245 MB'),
          const Divider(color: Colors.white10, height: 24),
          _infoRow('Auto Backup', 'Weekly'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBackupButton() {
    return GestureDetector(
      onTap: _startBackup,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF9333EA)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: const Center(child: Text('BACK UP NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1))),
      ),
    );
  }
}
