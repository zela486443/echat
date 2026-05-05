import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class StorageManagerScreen extends StatelessWidget {
  const StorageManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Storage Usage', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AuroraGradientBg(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildUsageOverview(),
            const SizedBox(height: 32),
            _buildSectionHeader('Breakdown'),
            _buildStorageItem('Media (Photos & Videos)', '2.4 GB', Icons.image, Colors.blue),
            _buildStorageItem('Voice Messages', '450 MB', Icons.mic, Colors.orange),
            _buildStorageItem('Files & Documents', '890 MB', Icons.description, Colors.green),
            _buildStorageItem('Database & Cache', '1.2 GB', Icons.storage, Colors.purple),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showClearConfirmation(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.1), side: const BorderSide(color: Colors.redAccent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Clear All Cache', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            const Center(child: Text('Clearing cache will not delete your messages.', style: TextStyle(color: Colors.white24, fontSize: 11))),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageOverview() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150, height: 150,
                child: CircularProgressIndicator(value: 0.7, strokeWidth: 12, backgroundColor: Colors.white10, color: AppTheme.primary),
              ),
              const Column(
                children: [
                  Text('4.94 GB', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Used of 64 GB', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatMini(label: 'Echats', val: '4.9 GB', color: Colors.blue),
              _StatMini(label: 'Other Apps', val: '42.1 GB', color: Colors.white12),
              _StatMini(label: 'Free', val: '17.0 GB', color: Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStorageItem(String label, String val, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
            Text(val, style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white12, size: 16),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
        content: const Text('This will delete all locally stored media and files to free up space. You can download them again from the cloud anytime.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Clear', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String val;
  final Color color;
  const _StatMini({required this.label, required this.val, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 12, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }
}
