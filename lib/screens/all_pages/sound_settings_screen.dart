import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SoundSettingsScreen extends ConsumerStatefulWidget {
  const SoundSettingsScreen({super.key});

  @override
  ConsumerState<SoundSettingsScreen> createState() => _SoundSettingsScreenState();
}

class _SoundSettingsScreenState extends ConsumerState<SoundSettingsScreen> {
  String _defaultSound = 'Default';
  final List<String> _presetSounds = ['Default', 'Aurora', 'Bamboo', 'Chord', 'Glass', 'Pop', 'Tritone'];
  
  final List<Map<String, String>> _contacts = [
    {'name': 'Alex Rivera', 'sound': 'Aurora'},
    {'name': 'Sarah Chen', 'sound': 'Chord'},
    {'name': 'Jordan Lee', 'sound': 'Default'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Notification Sounds', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(LucideIcons.volume2, 'DEFAULT SOUND'),
            _buildDefaultSoundGrid(),
            
            _buildSectionHeader(LucideIcons.music, 'PER-CONTACT SOUNDS'),
            _buildContactSoundsList(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 14),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildDefaultSoundGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _presetSounds.map((s) {
        bool active = _defaultSound == s;
        return InkWell(
          onTap: () => setState(() => _defaultSound = s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: active ? const Color(0xFF7C3AED) : Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (active) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(LucideIcons.check, color: Colors.white, size: 12)),
                Text(s, style: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactSoundsList() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _contacts.length,
        separatorBuilder: (context, i) => const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, i) {
          final c = _contacts[i];
          return ListTile(
            leading: CircleAvatar(radius: 18, backgroundColor: Colors.white10, child: Text(c['name']![0], style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold))),
            title: Text(c['name']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(c['sound']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.chevronDown, color: Colors.white24, size: 12),
                ],
              ),
            ),
            onTap: () => _showSoundPicker(c),
          );
        },
      ),
    );
  }

  void _showSoundPicker(Map<String, String> contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.all(20), child: Text('Select Sound for ${contact['name']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ..._presetSounds.map((s) => ListTile(
            title: Text(s, style: const TextStyle(color: Colors.white70)),
            trailing: contact['sound'] == s ? const Icon(LucideIcons.check, color: Color(0xFF7C3AED)) : null,
            onTap: () {
              setState(() => contact['sound'] = s);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
