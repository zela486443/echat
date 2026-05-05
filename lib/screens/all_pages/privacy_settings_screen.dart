import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/theme_provider.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  // Security
  bool _appLockEnabled = false;
  bool _walletLockEnabled = false;
  bool _twoFAEnabled = false;
  bool _autoDelete = false;

  // Privacy Options
  String _phoneNumber = 'contacts';
  String _lastSeen = 'contacts';
  String _profilePhoto = 'everyone';
  String _messages = 'everyone';
  String _groups = 'contacts';
  String _deleteIfAway = '18months';

  // Messaging privacy
  bool _readReceipts = true;
  bool _stealthMode = false;
  bool _anonReactions = false;

  // Ghost Mode
  bool _ghostMode = false;
  bool _hideReadReceipts = false;
  bool _hideTyping = false;
  bool _hideOnline = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _walletLockEnabled = prefs.getBool('wallet_lock_enabled') ?? false;
      _twoFAEnabled = prefs.getBool('two_fa_enabled') ?? false;
      _autoDelete = prefs.getBool('echat_auto_delete') ?? false;
      _phoneNumber = prefs.getString('priv_phone') ?? 'contacts';
      _lastSeen = prefs.getString('priv_lastseen') ?? 'contacts';
      _profilePhoto = prefs.getString('priv_photo') ?? 'everyone';
      _messages = prefs.getString('priv_msgs') ?? 'everyone';
      _groups = prefs.getString('priv_groups') ?? 'contacts';
      _deleteIfAway = prefs.getString('priv_delete_away') ?? '18months';
      _readReceipts = !(prefs.getBool('echat_read_receipts_off') ?? false);
      _stealthMode = prefs.getBool('echat_story_stealth') ?? false;
      _anonReactions = prefs.getBool('echat_anon_reactions') ?? false;
      _ghostMode = prefs.getBool('ghost_mode') ?? false;
      _hideReadReceipts = prefs.getBool('ghost_hide_read') ?? false;
      _hideTyping = prefs.getBool('ghost_hide_typing') ?? false;
      _hideOnline = prefs.getBool('ghost_hide_online') ?? false;
    });
  }

  Future<void> _saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<void> _saveString(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, val);
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Privacy and Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildSectionTitle('SECURITY'),
          _buildGroup([
            _buildActionRow(
              icon: LucideIcons.shieldCheck,
              iconBg: Colors.blue,
              label: 'Two-Step Verification',
              value: _twoFAEnabled ? 'On' : 'Off',
              onTap: () => _show2FADialog(),
            ),
            _buildDivider(),
            _buildSwitchRow(
              icon: LucideIcons.trash2,
              iconBg: Colors.red,
              label: 'Auto-Delete Messages',
              sub: 'Automatically remove chat history',
              value: _autoDelete,
              onChanged: (v) {
                setState(() => _autoDelete = v);
                _saveBool('echat_auto_delete', v);
              },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.lock,
              iconBg: Colors.purple,
              label: 'Passcode Lock',
              value: _appLockEnabled ? 'On' : 'Off',
              onTap: () {},
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.wallet,
              iconBg: const Color(0xFF10B981),
              label: 'Wallet Passcode',
              value: _walletLockEnabled ? 'On' : 'Off',
              onTap: () {},
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.monitor,
              iconBg: Colors.cyan,
              label: 'Active Sessions',
              value: '1 Device',
              onTap: () => context.push('/active-sessions'),
            ),
          ]),

          _buildSectionTitle('PRIVACY'),
          _buildGroup([
            _buildActionRow(
              icon: LucideIcons.phone,
              iconBg: Colors.green,
              label: 'Phone Number',
              value: _phoneNumber.toUpperCase(),
              onTap: () => _showPicker('Phone Number', ['everyone', 'contacts', 'nobody'], _phoneNumber, (v) {
                setState(() => _phoneNumber = v);
                _saveString('priv_phone', v);
              }),
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.eye,
              iconBg: Colors.indigo,
              label: 'Last Seen & Online',
              value: _lastSeen.toUpperCase(),
              onTap: () => _showPicker('Last Seen', ['everyone', 'contacts', 'nobody'], _lastSeen, (v) {
                setState(() => _lastSeen = v);
                _saveString('priv_lastseen', v);
              }),
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.user,
              iconBg: Colors.pink,
              label: 'Profile Photo',
              value: _profilePhoto.toUpperCase(),
              onTap: () => _showPicker('Profile Photo', ['everyone', 'contacts', 'nobody'], _profilePhoto, (v) {
                setState(() => _profilePhoto = v);
                _saveString('priv_photo', v);
              }),
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.messageSquare,
              iconBg: Colors.orange,
              label: 'Messages',
              value: _messages.toUpperCase(),
              onTap: () => _showPicker('Messages', ['everyone', 'contacts'], _messages, (v) {
                setState(() => _messages = v);
                _saveString('priv_msgs', v);
              }),
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.users,
              iconBg: Colors.teal,
              label: 'Groups & Channels',
              value: _groups.toUpperCase(),
              onTap: () => _showPicker('Groups', ['everyone', 'contacts'], _groups, (v) {
                setState(() => _groups = v);
                _saveString('priv_groups', v);
              }),
            ),
          ]),

          _buildSectionTitle('GHOST MODE'),
          _buildGroup([
            _buildSwitchRow(
              icon: LucideIcons.ghost,
              iconBg: const Color(0xFF64748B),
              label: 'Ghost Mode',
              sub: 'Read messages invisibly',
              value: _ghostMode,
              onChanged: (v) {
                setState(() => _ghostMode = v);
                _saveBool('ghost_mode', v);
              },
              activeColor: accent.color,
            ),
            if (_ghostMode) ...[
              _buildDivider(),
              _buildSwitchRow(
                icon: LucideIcons.checkCheck,
                iconBg: Colors.blue,
                label: 'Hide Read Receipts',
                sub: 'Others won\'t see when you read',
                value: _hideReadReceipts,
                onChanged: (v) {
                  setState(() => _hideReadReceipts = v);
                  _saveBool('ghost_hide_read', v);
                },
                activeColor: accent.color,
                isSmall: true,
              ),
              _buildDivider(),
              _buildSwitchRow(
                icon: LucideIcons.type,
                iconBg: Colors.purple,
                label: 'Hide Typing...',
                sub: 'Others won\'t see you typing',
                value: _hideTyping,
                onChanged: (v) {
                  setState(() => _hideTyping = v);
                  _saveBool('ghost_hide_typing', v);
                },
                activeColor: accent.color,
                isSmall: true,
              ),
            ],
          ]),

          _buildSectionTitle('MESSAGING PRIVACY'),
          _buildGroup([
            _buildSwitchRow(
              icon: LucideIcons.checkCheck,
              iconBg: Colors.blue,
              label: 'Read Receipts',
              sub: 'Show when you have read messages',
              value: _readReceipts,
              onChanged: (v) {
                setState(() => _readReceipts = v);
                _saveBool('echat_read_receipts_off', !v);
              },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildSwitchRow(
              icon: LucideIcons.smile,
              iconBg: Colors.amber,
              label: 'Anonymous Reactions',
              sub: 'Hide your name in reactions',
              value: _anonReactions,
              onChanged: (v) {
                setState(() => _anonReactions = v);
                _saveBool('echat_anon_reactions', v);
              },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildSwitchRow(
              icon: LucideIcons.eyeOff,
              iconBg: const Color(0xFF64748B),
              label: 'Story Stealth Mode',
              sub: 'View stories without being seen',
              value: _stealthMode,
              onChanged: (v) {
                setState(() => _stealthMode = v);
                _saveBool('echat_story_stealth', v);
              },
              activeColor: accent.color,
            ),
          ]),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF150D28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16);
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconBg, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: ref.watch(themeProvider).color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
    bool isSmall = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isSmall ? 8 : 12),
      child: Row(
        children: [
          Container(
            width: isSmall ? 30 : 36, height: isSmall ? 30 : 36,
            decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(isSmall ? 8 : 10)),
            child: Icon(icon, color: iconBg, size: isSmall ? 15 : 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white, fontSize: isSmall ? 13 : 14, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(color: Colors.white38, fontSize: isSmall ? 10 : 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      ),
    );
  }

  void _showPicker(String title, List<String> options, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFF150D28), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...options.map((opt) => ListTile(
              title: Text(opt.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14)),
              trailing: opt == current ? Icon(LucideIcons.check, color: ref.watch(themeProvider).color) : null,
              onTap: () { onSelect(opt); context.pop(); },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _show2FADialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '2FA',
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF150D28), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.shieldCheck, color: Colors.blue, size: 48),
                  const SizedBox(height: 16),
                  const Text('Two-Step Verification', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Protect your account with an extra layer of security.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 24),
                  Container(
                    width: 150, height: 150,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(LucideIcons.qrCode, color: Colors.black, size: 100), // Placeholder QR
                  ),
                  const SizedBox(height: 16),
                  const Text('Scan this QR code in your Authenticator app', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _saveBool('two_fa_enabled', true);
                      setState(() => _twoFAEnabled = true);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: ref.watch(themeProvider).color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Verify & Enable', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
