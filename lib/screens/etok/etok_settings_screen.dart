import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EtokSettingsScreen extends ConsumerStatefulWidget {
  const EtokSettingsScreen({super.key});

  @override
  ConsumerState<EtokSettingsScreen> createState() => _EtokSettingsScreenState();
}

class _EtokSettingsScreenState extends ConsumerState<EtokSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Privacy & Settings', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSettingItem(Icons.shield, 'Privacy', 'Account, interactions & permissions', Colors.blue),
            _buildSettingItem(Icons.comment, 'Comments & Keywords', 'Filter spam and keywords', Colors.teal),
            _buildSettingItem(Icons.timer, 'Screen Time', 'Today: 42 min', Colors.purple),
            _buildSettingItem(Icons.block, 'Blocked Accounts', '0 accounts blocked', Colors.red),
            _buildSettingItem(Icons.download, 'Data & Privacy', 'Download data, delete account', Colors.green),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: Column(
                children: [
                  _buildSimpleRow(Icons.notifications, 'Notifications'),
                  _buildSimpleRow(Icons.lock, 'Account & Security'),
                  _buildSimpleRow(Icons.language, 'Language'),
                  _buildSimpleRow(Icons.search, 'Search History', showDivider: false),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Log out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String sub, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(IconData icon, String label, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white60, size: 20),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14))),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: Colors.white.withOpacity(0.08), indent: 52),
      ],
    );
  }
}
