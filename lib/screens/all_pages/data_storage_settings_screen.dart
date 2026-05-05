import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/theme_provider.dart';

class DataStorageSettingsScreen extends ConsumerStatefulWidget {
  const DataStorageSettingsScreen({super.key});

  @override
  ConsumerState<DataStorageSettingsScreen> createState() => _DataStorageSettingsScreenState();
}

class _DataStorageSettingsScreenState extends ConsumerState<DataStorageSettingsScreen> {
  bool _autoPhotosMobile = true;
  bool _autoPhotosWifi = true;
  bool _autoVideosWifi = true;
  bool _autoVideosMobile = false;
  bool _dataSaver = false;
  bool _lessDataCalls = false;
  double _storageUsed = 14.2; // MB

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoPhotosMobile = prefs.getBool('storage_auto_photos_mobile') ?? true;
      _autoPhotosWifi = prefs.getBool('storage_auto_photos_wifi') ?? true;
      _autoVideosMobile = prefs.getBool('storage_auto_videos_mobile') ?? false;
      _autoVideosWifi = prefs.getBool('storage_auto_videos_wifi') ?? true;
      _dataSaver = prefs.getBool('storage_data_saver') ?? false;
      _lessDataCalls = prefs.getBool('storage_less_data_calls') ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, val);
  }

  Future<void> _clearCache() async {
    setState(() => _storageUsed = 0.5);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared!'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
        title: const Text('Data & Storage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildStorageDashboard(accent),
          
          _buildSectionTitle('STORAGE MANAGEMENT'),
          _buildGroup([
            _buildActionRow(
              icon: LucideIcons.trash2,
              iconBg: Colors.blueGrey,
              label: 'Clear Cache',
              sub: 'Free up space by removing temporary files',
              onTap: _clearCache,
            ),
          ]),

          _buildSectionTitle('AUTO-DOWNLOAD MEDIA'),
          _buildGroup([
            _buildAutoDownloadRow(
              icon: LucideIcons.image,
              iconBg: Colors.blue,
              label: 'Photos',
              mobile: _autoPhotosMobile,
              wifi: _autoPhotosWifi,
              onMobileChanged: (v) { setState(() => _autoPhotosMobile = v); _saveSetting('storage_auto_photos_mobile', v); },
              onWifiChanged: (v) { setState(() => _autoPhotosWifi = v); _saveSetting('storage_auto_photos_wifi', v); },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildAutoDownloadRow(
              icon: LucideIcons.video,
              iconBg: Colors.purple,
              label: 'Videos',
              mobile: _autoVideosMobile,
              wifi: _autoVideosWifi,
              onMobileChanged: (v) { setState(() => _autoVideosMobile = v); _saveSetting('storage_auto_videos_mobile', v); },
              onWifiChanged: (v) { setState(() => _autoVideosWifi = v); _saveSetting('storage_auto_videos_wifi', v); },
              activeColor: accent.color,
            ),
          ]),

          _buildSectionTitle('DATA USAGE'),
          _buildGroup([
            _buildToggleRow(
              icon: LucideIcons.download,
              iconBg: Colors.teal,
              label: 'Data Saver Mode',
              sub: 'Lower media quality to save data',
              value: _dataSaver,
              onChanged: (v) { setState(() => _dataSaver = v); _saveSetting('storage_data_saver', v); },
              activeColor: accent.color,
            ),
            _buildDivider(),
            _buildToggleRow(
              icon: LucideIcons.database,
              iconBg: Colors.indigo,
              label: 'Less Data for Calls',
              sub: 'Optimizes call bandwidth',
              value: _lessDataCalls,
              onChanged: (v) { setState(() => _lessDataCalls = v); _saveSetting('storage_less_data_calls', v); },
              activeColor: accent.color,
            ),
          ]),

          _buildSectionTitle('CHAT HISTORY'),
          _buildGroup([
            _buildActionRow(
              icon: LucideIcons.fileDown,
              iconBg: Colors.cyan,
              label: 'Export Chat History',
              sub: 'Create a backup of your messages',
              onTap: () {},
            ),
            _buildDivider(),
            _buildActionRow(
              icon: LucideIcons.trash2,
              iconBg: Colors.red,
              label: 'Delete All Chats',
              sub: 'Permanently erase all messages',
              destructive: true,
              onTap: () {},
            ),
          ]),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStorageDashboard(AccentColor accent) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF150D28),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: accent.color.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STORAGE USED', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text('${_storageUsed.toStringAsFixed(1)} MB', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                ],
              ),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: accent.color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(LucideIcons.hardDrive, color: accent.color, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: 0.15,
                child: Container(height: 8, decoration: BoxDecoration(color: accent.color, borderRadius: BorderRadius.circular(4))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('15% of cache capacity', style: TextStyle(color: Colors.white24, fontSize: 11)),
              Text('Total limit: 100 MB', style: TextStyle(color: Colors.white24, fontSize: 11)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(delay: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16);
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String sub,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconBg, size: 18),
      ),
      title: Text(label, style: TextStyle(color: destructive ? Colors.redAccent : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconBg, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: activeColor),
    );
  }

  Widget _buildAutoDownloadRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required bool mobile,
    required bool wifi,
    required ValueChanged<bool> onMobileChanged,
    required ValueChanged<bool> onWifiChanged,
    required Color activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconBg, size: 18),
              ),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildNetworkToggle('Mobile', mobile, onMobileChanged, activeColor)),
              const SizedBox(width: 12),
              Expanded(child: _buildNetworkToggle('Wi-Fi', wifi, onWifiChanged, activeColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkToggle(String label, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? activeColor.withOpacity(0.1) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? activeColor : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: value ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
            Icon(value ? LucideIcons.checkCircle2 : LucideIcons.circle, color: value ? activeColor : Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}
