import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_sound_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _msgNotifs = true;
  bool _msgPreview = true;
  String _msgSound = 'default';
  bool _vibrate = true;
  bool _grpNotifs = true;
  String _grpSound = 'default';
  bool _callNotifs = true;
  String _ringtone = 'default';
  bool _smartFilter = false;
  List<String> _keywords = [];
  final _keywordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _msgNotifs = prefs.getBool('notif_msg_enabled') ?? true;
      _msgPreview = prefs.getBool('notif_msg_preview') ?? true;
      _msgSound = prefs.getString('notif_msg_sound') ?? 'default';
      _vibrate = prefs.getBool('notif_vibrate') ?? true;
      _grpNotifs = prefs.getBool('notif_grp_enabled') ?? true;
      _grpSound = prefs.getString('notif_grp_sound') ?? 'default';
      _callNotifs = prefs.getBool('notif_call_enabled') ?? true;
      _ringtone = prefs.getString('notif_ringtone') ?? 'default';
      _smartFilter = prefs.getBool('notif_smart_filter') ?? false;
      _keywords = prefs.getStringList('notif_keywords') ?? [];
    });
  }

  Future<void> _saveBool(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<void> _saveStringList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notif_keywords', _keywords);
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
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildSectionTitle('MESSAGES'),
          _buildGroup([
            _buildSwitchRow(
              icon: _msgNotifs ? LucideIcons.bell : LucideIcons.bellOff,
              iconBg: Colors.blue,
              label: 'Message Notifications',
              sub: 'Get notified for new messages',
              value: _msgNotifs,
              onChanged: (v) {
                setState(() => _msgNotifs = v);
                _saveBool('notif_msg_enabled', v);
              },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildSwitchRow(
              icon: LucideIcons.messageSquare,
              iconBg: const Color(0xFF0EA5E9),
              label: 'Message Preview',
              sub: 'Show content in notification',
              value: _msgPreview,
              onChanged: (v) {
                setState(() => _msgPreview = v);
                _saveBool('notif_msg_preview', v);
              },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: LucideIcons.volume2,
              iconBg: Colors.orange,
              label: 'Message Sound',
              value: _msgSound.toUpperCase(),
              onTap: () => _showSoundPicker('Message Sound', (id) {
                setState(() => _msgSound = id);
                final prefs = SharedPreferences.getInstance().then((p) => p.setString('notif_msg_sound', id));
              }),
            ),
            _buildDivider(),
            _buildSwitchRow(
              icon: LucideIcons.vibrate,
              iconBg: const Color(0xFF8B5CF6),
              label: 'Vibrate',
              sub: 'Vibrate on new messages',
              value: _vibrate,
              onChanged: (v) {
                setState(() => _vibrate = v);
                _saveBool('notif_vibrate', v);
              },
              activeColor: accent.color,
            ),
          ]),

          _buildSectionTitle('GROUPS'),
          _buildGroup([
            _buildSwitchRow(
              icon: LucideIcons.users,
              iconBg: const Color(0xFF10B981),
              label: 'Group Notifications',
              sub: 'Notifications for group messages',
              value: _grpNotifs,
              onChanged: (v) {
                setState(() => _grpNotifs = v);
                _saveBool('notif_grp_enabled', v);
              },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: LucideIcons.volume2,
              iconBg: Colors.teal,
              label: 'Group Sound',
              value: _grpSound.toUpperCase(),
              onTap: () => _showSoundPicker('Group Sound', (id) {
                setState(() => _grpSound = id);
                final prefs = SharedPreferences.getInstance().then((p) => p.setString('notif_grp_sound', id));
              }),
            ),
          ]),

          _buildSectionTitle('CALLS'),
          _buildGroup([
            _buildSwitchRow(
              icon: LucideIcons.phone,
              iconBg: const Color(0xFFF43F5E),
              label: 'Call Notifications',
              sub: 'Get notified for incoming calls',
              value: _callNotifs,
              onChanged: (v) {
                setState(() => _callNotifs = v);
                _saveBool('notif_call_enabled', v);
              },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildSettingRow(
              icon: LucideIcons.music,
              iconBg: Colors.pink,
              label: 'Ringtone',
              value: _ringtone.toUpperCase(),
              onTap: () => _showSoundPicker('Ringtone', (id) {
                setState(() => _ringtone = id);
                final prefs = SharedPreferences.getInstance().then((p) => p.setString('notif_ringtone', id));
              }),
            ),
          ]),

          _buildSectionTitle('SMART NOTIFICATION FILTER'),
          _buildGroup([
            _buildSwitchRow(
              icon: LucideIcons.zap,
              iconBg: Colors.amber,
              label: 'Smart Filter',
              sub: 'Only notify for important messages',
              value: _smartFilter,
              onChanged: (v) {
                setState(() => _smartFilter = v);
                _saveBool('notif_smart_filter', v);
              },
              activeColor: accent.color,
            ),
            if (_smartFilter) ...[
              _buildDivider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keyword triggers (tap to remove)',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _keywords.map((kw) => _buildKeywordChip(kw)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _keywordCtrl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Add keyword...',
                              hintStyle: const TextStyle(color: Colors.white24),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (v) => _addKeyword(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _addKeyword,
                          icon: Icon(LucideIcons.plus, color: accent.color),
                          style: IconButton.styleFrom(
                            backgroundColor: accent.color.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _addKeyword() {
    final kw = _keywordCtrl.text.trim().toLowerCase();
    if (kw.isNotEmpty && !_keywords.contains(kw)) {
      setState(() {
        _keywords.add(kw);
        _keywordCtrl.clear();
      });
      _saveStringList();
    }
  }

  Widget _buildKeywordChip(String kw) {
    return GestureDetector(
      onTap: () {
        setState(() => _keywords.remove(kw));
        _saveStringList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: ref.watch(themeProvider).color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ref.watch(themeProvider).color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(kw, style: TextStyle(color: ref.watch(themeProvider).color, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Icon(LucideIcons.x, color: ref.watch(themeProvider).color, size: 12),
          ],
        ),
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
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16);
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconBg, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: activeColor),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconBg.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
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

  void _showSoundPicker(String title, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF150D28),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...presetSounds.map((s) => _buildSoundOption(s.name, s.id, onSelect)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOption(String name, String id, Function(String) onSelect) {
    final isSelected = (_msgSound == id); // Simple check
    return ListTile(
      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: isSelected ? Icon(LucideIcons.check, color: ref.watch(themeProvider).color) : null,
      onTap: () {
        onSelect(id);
        context.pop();
      },
    );
  }
}
