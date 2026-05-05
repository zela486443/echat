import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';

class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  bool _twoFA = false;
  bool _appLock = true;
  bool _walletLock = false;
  bool _readReceipts = true;
  bool _ghostMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('SECURITY'),
                _buildSecurityGroup(),
                _buildSectionNote('Review the list of devices where you are logged in to your Echat account.'),
                
                _buildSectionTitle('PRIVACY'),
                _buildPrivacyGroup(),
                _buildSectionNote('You can restrict which users are allowed to see your personal info.'),
                
                _buildSectionTitle('GHOST MODE'),
                _buildGhostModeGroup(),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: const Text('Privacy and Security', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(title, style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildSectionNote(String note) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Text(note, style: const TextStyle(color: Colors.white24, fontSize: 11, height: 1.4)),
    );
  }

  Widget _buildSecurityGroup() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildRow('Two-Step Verification', value: _twoFA ? 'On' : 'Off', onTap: () => setState(() => _twoFA = !_twoFA)),
          _buildDivider(),
          _buildRow('Passcode Lock', value: _appLock ? 'On' : 'Off', onTap: () => setState(() => _appLock = !_appLock)),
          _buildDivider(),
          _buildRow('Wallet Passcode', value: _walletLock ? 'On' : 'Off', onTap: () => setState(() => _walletLock = !_walletLock)),
          _buildDivider(),
          _buildRow('Blocked Users', value: '12', onTap: () {}),
          _buildDivider(),
          _buildRow('Devices', value: '1 Active', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildPrivacyGroup() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildRow('Phone Number', value: 'My Contacts', onTap: () {}),
          _buildDivider(),
          _buildRow('Last Seen & Online', value: 'Everybody', onTap: () {}),
          _buildDivider(),
          _buildRow('Profile Photos', value: 'Everybody', onTap: () {}),
          _buildDivider(),
          _buildRow('Read Receipts', right: Switch(value: _readReceipts, onChanged: (v) => setState(() => _readReceipts = v), activeColor: const Color(0xFF7C3AED))),
        ],
      ),
    );
  }

  Widget _buildGhostModeGroup() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildRow('Ghost Mode', description: 'Read messages invisibly', right: Switch(value: _ghostMode, onChanged: (v) => setState(() => _ghostMode = v), activeColor: const Color(0xFF7C3AED))),
          if (_ghostMode) ...[
            _buildDivider(),
            _buildRow('Hide Typing Indicator', right: const Switch(value: true, onChanged: null, activeColor: Color(0xFF7C3AED))),
            _buildDivider(),
            _buildRow('Hide Online Status', right: const Switch(value: true, onChanged: null, activeColor: Color(0xFF7C3AED))),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, {String? value, String? description, Widget? right, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: description != null ? Text(description, style: const TextStyle(color: Colors.white24, fontSize: 11)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value, style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 13, fontWeight: FontWeight.bold)),
          if (right != null) right else const Icon(LucideIcons.chevronRight, color: Colors.white10, size: 16),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.03), indent: 20);
  }
}
