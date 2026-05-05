import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/etok_privacy_service.dart';
import '../../providers/auth_provider.dart';

final etokPrivacyServiceProvider = Provider((ref) => EtokPrivacyService());

class EtokSettingsScreen extends ConsumerStatefulWidget {
  const EtokSettingsScreen({super.key});

  @override
  ConsumerState<EtokSettingsScreen> createState() => _EtokSettingsScreenState();
}

class _EtokSettingsScreenState extends ConsumerState<EtokSettingsScreen> {
  String _currentSection = 'main';
  
  // Privacy Settings
  bool _privateAccount = false;
  bool _allowDownloads = true;
  String _commentPerm = 'everyone';
  String _duetPerm = 'everyone';
  String _stitchPerm = 'everyone';
  
  // Comments & Keywords
  bool _filterSpam = true;
  List<String> _keywords = [];
  final _keywordCtrl = TextEditingController();

  // Screen Time
  int _dailyLimit = 0; // 0 means no limit
  bool _breakReminders = true;
  int _todayMinutes = 45; // Mock data for now

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    
    final service = ref.read(etokPrivacyServiceProvider);
    final isPrivate = await service.getSetting(user.id, 'privateAccount', false);
    final canDownload = await service.getSetting(user.id, 'allowDownloads', true);
    final comms = await service.getSetting(user.id, 'allowComments', 'everyone');
    final duet = await service.getSetting(user.id, 'duetPermission', 'everyone');
    final stitch = await service.getSetting(user.id, 'stitchPermission', 'everyone');
    final filter = await service.getSetting(user.id, 'filterSpam', true);
    final kws = await service.getSetting(user.id, 'commentKeywords', <String>[]);
    final limit = await service.getSetting(user.id, 'screenTimeLimit', 0);
    final reminders = await service.getSetting(user.id, 'breakReminders', true);
    
    setState(() {
      _privateAccount = isPrivate;
      _allowDownloads = canDownload;
      _commentPerm = comms;
      _duetPerm = duet;
      _stitchPerm = stitch;
      _filterSpam = filter;
      _keywords = List<String>.from(kws);
      _dailyLimit = limit;
      _breakReminders = reminders;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    await ref.read(etokPrivacyServiceProvider).saveSetting(user.id, key, value);
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            if (_currentSection == 'main') {
              context.pop();
            } else {
              setState(() => _currentSection = 'main');
            }
          },
        ),
        title: Text(
          _currentSection == 'main' ? 'Privacy & Settings' : _getTitle(_currentSection),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: _buildBody(),
    );
  }

  String _getTitle(String section) {
    switch (section) {
      case 'privacy': return 'Privacy';
      case 'comments': return 'Comments & Keywords';
      case 'screen_time': return 'Screen Time';
      case 'blocked': return 'Blocked Accounts';
      case 'data': return 'Data & Privacy';
      default: return 'Settings';
    }
  }

  Widget _buildBody() {
    switch (_currentSection) {
      case 'main': return _buildMainSection();
      case 'privacy': return _buildPrivacySection();
      case 'comments': return _buildCommentsSection();
      case 'screen_time': return _buildScreenTimeSection();
      case 'data': return _buildDataSection();
      default: return const Center(child: Text('Coming Soon', style: TextStyle(color: Colors.white)));
    }
  }

  Widget _buildMainSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingCard('Privacy', 'Account, interactions & permissions', LucideIcons.shield, () => setState(() => _currentSection = 'privacy')),
        const SizedBox(height: 12),
        _buildSettingCard('Comments & Keywords', 'Filter spam and keywords', LucideIcons.messageCircle, () => setState(() => _currentSection = 'comments')),
        const SizedBox(height: 12),
        _buildSettingCard('Screen Time', 'Usage today: $_todayMinutes min', LucideIcons.clock, () => setState(() => _currentSection = 'screen_time')),
        const SizedBox(height: 12),
        _buildSettingCard('Data & Privacy', 'Download data, delete account', LucideIcons.download, () => setState(() => _currentSection = 'data')),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
          child: Column(
            children: [
              _buildSimpleRow('Notifications', LucideIcons.bell),
              _buildSimpleRow('Account & Security', LucideIcons.lock),
              _buildSimpleRow('Language', LucideIcons.globe),
              _buildSimpleRow('Search History', LucideIcons.search),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSignOutButton(),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToggleRow('Private Account', 'Only followers can see your content', _privateAccount, (v) => _saveSetting('privateAccount', v)),
        _buildToggleRow('Allow Downloads', 'Let others download your videos', _allowDownloads, (v) => _saveSetting('allowDownloads', v)),
        const SizedBox(height: 12),
        _buildRadioRow('Who can comment', ['everyone', 'friends', 'no_one'], _commentPerm, (v) => _saveSetting('allowComments', v)),
        _buildRadioRow('Who can Duet', ['everyone', 'friends', 'no_one'], _duetPerm, (v) => _saveSetting('duetPermission', v)),
        _buildRadioRow('Who can Stitch', ['everyone', 'friends', 'no_one'], _stitchPerm, (v) => _saveSetting('stitchPermission', v)),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildToggleRow('Filter spam', 'Auto-hide spam and scam comments', _filterSpam, (v) => _saveSetting('filterSpam', v)),
        const SizedBox(height: 24),
        const Text('Keyword Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const Text('Hide comments containing these words', style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _keywordCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add keyword...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_keywordCtrl.text.trim().isNotEmpty) {
                  final kws = [..._keywords, _keywordCtrl.text.trim().toLowerCase()];
                  _saveSetting('commentKeywords', kws);
                  _keywordCtrl.clear();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050)),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _keywords.map((kw) => _buildKeywordChip(kw)).toList(),
        ),
      ],
    );
  }

  Widget _buildScreenTimeSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TODAY'S USAGE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('${_todayMinutes ~/ 60}h ${_todayMinutes % 60}m', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _dailyLimit > 0 ? (_todayMinutes / _dailyLimit).clamp(0.0, 1.0) : 0.45,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFFFF0050),
                  minHeight: 8,
                ),
              ),
              if (_dailyLimit > 0) ...[
                const SizedBox(height: 8),
                Text('of $_dailyLimit min daily limit', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Daily Limit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [30, 60, 90, 120, 180, 0].map((min) => _buildLimitOption(min)).toList(),
        ),
        const SizedBox(height: 24),
        _buildToggleRow('Break reminders', 'Remind me to take breaks', _breakReminders, (v) => _saveSetting('breakReminders', v)),
      ],
    );
  }

  Widget _buildDataSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingCard('Download your data', 'Get a copy of your Etok data', LucideIcons.download, () {}),
        const SizedBox(height: 12),
        _buildSettingCard('Your activity', 'View screen time & interactions', LucideIcons.eye, () => setState(() => _currentSection = 'screen_time')),
        const SizedBox(height: 24),
        _buildSignOutButton(label: 'Delete Account', color: Colors.redAccent, onTap: () {}),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildSettingCard(String label, String sub, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white70, size: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ]),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, String sub, bool val, Function(bool) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ])),
          Switch(value: val, onChanged: onChange, activeColor: const Color(0xFFFF0050)),
        ],
      ),
    );
  }

  Widget _buildRadioRow(String label, List<String> options, String current, Function(String) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: options.map((opt) => ChoiceChip(
            label: Text(opt.replaceAll('_', ' ')),
            selected: current == opt,
            onSelected: (s) { if (s) onChange(opt); },
            backgroundColor: Colors.white.withOpacity(0.05),
            selectedColor: const Color(0xFFFF0050),
            labelStyle: TextStyle(color: current == opt ? Colors.white : Colors.white60, fontSize: 12),
          )).toList(),
        ),
        const Divider(color: Colors.white10, height: 32),
      ],
    );
  }

  Widget _buildKeywordChip(String kw) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(kw, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(width: 6),
          GestureDetector(onTap: () {
            final kws = _keywords.where((k) => k != kw).toList();
            _saveSetting('commentKeywords', kws);
          }, child: const Icon(LucideIcons.x, color: Colors.white38, size: 14)),
        ],
      ),
    );
  }

  Widget _buildLimitOption(int min) {
    final isSelected = _dailyLimit == min;
    return GestureDetector(
      onTap: () => _saveSetting('screenTimeLimit', min),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF0050) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFFF0050) : Colors.white12),
        ),
        child: Text(min == 0 ? 'No limit' : '$min min', style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildSimpleRow(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54, size: 20),
      title: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.white10, size: 16),
      onTap: () {},
    );
  }

  Widget _buildSignOutButton({String label = 'Log out', Color color = Colors.redAccent, VoidCallback? onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}
