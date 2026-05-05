import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BusinessProfileSettingsScreen extends ConsumerStatefulWidget {
  const BusinessProfileSettingsScreen({super.key});

  @override
  ConsumerState<BusinessProfileSettingsScreen> createState() => _BusinessProfileSettingsScreenState();
}

class _BusinessProfileSettingsScreenState extends ConsumerState<BusinessProfileSettingsScreen> {
  bool _isEnabled = true;
  bool _awayEnabled = false;
  
  final List<Map<String, dynamic>> _workingHours = [
    {'day': 'Monday', 'closed': false, 'open': '08:00', 'close': '18:00'},
    {'day': 'Tuesday', 'closed': false, 'open': '08:00', 'close': '18:00'},
    {'day': 'Wednesday', 'closed': false, 'open': '08:00', 'close': '18:00'},
    {'day': 'Thursday', 'closed': false, 'open': '08:00', 'close': '18:00'},
    {'day': 'Friday', 'closed': false, 'open': '08:00', 'close': '18:00'},
    {'day': 'Saturday', 'closed': true, 'open': '09:00', 'close': '13:00'},
    {'day': 'Sunday', 'closed': true, 'open': '00:00', 'close': '00:00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
        title: const Column(
          children: [
            Text('Business Profile', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            Text('Currently Open', style: TextStyle(color: const Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.check, color: Color(0xFF7C3AED)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('STATUS'),
            _buildToggleCard(LucideIcons.briefcase, 'Business Mode', 'Enable business features', _isEnabled, (val) => setState(() => _isEnabled = val)),
            
            if (_isEnabled) ...[
              _buildSectionTitle('BUSINESS INFO'),
              _buildInfoCard(),

              _buildSectionTitle('AUTO MESSAGES'),
              _buildAutoMessageCard(),

              _buildSectionTitle('AWAY MODE'),
              _buildAwayModeCard(),

              _buildSectionTitle('WORKING HOURS'),
              _buildWorkingHoursCard(),

              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildToggleCard(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF7C3AED), size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12))])),
          Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Column(
        children: [
          _buildInputField('Business Name', 'Echat Inc.'),
          const Divider(color: Colors.white12, height: 24),
          _buildInputField('Address', 'Addis Ababa, Ethiopia', icon: LucideIcons.mapPin),
          const Divider(color: Colors.white12, height: 24),
          _buildInputField('Phone', '+251 912 345 678', icon: LucideIcons.phone),
          const Divider(color: Colors.white12, height: 24),
          _buildInputField('Website', 'https://echat.app', icon: LucideIcons.globe),
        ],
      ),
    );
  }

  Widget _buildAutoMessageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: _buildInputField('Welcome Message', 'Hi! Thanks for reaching out. How can we help you?', maxLines: 3),
    );
  }

  Widget _buildAwayModeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.moon, color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Enable Away Mode', style: TextStyle(color: Colors.white, fontSize: 14))),
              Switch(value: _awayEnabled, onChanged: (v) => setState(() => _awayEnabled = v), activeColor: const Color(0xFF7C3AED)),
            ],
          ),
          if (_awayEnabled) ...[
            const Divider(color: Colors.white12, height: 24),
            _buildInputField('Away Message', "We're currently unavailable. We'll get back to you soon!", maxLines: 2),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String initialValue, {IconData? icon, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [if (icon != null) ...[Icon(icon, color: Colors.white38, size: 12), const SizedBox(width: 6)], Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))]),
        TextField(
          controller: TextEditingController(text: initialValue),
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 8)),
        ),
      ],
    );
  }

  Widget _buildWorkingHoursCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _workingHours.length,
        separatorBuilder: (context, i) => const Divider(color: Colors.white10, height: 1),
        itemBuilder: (context, i) {
          final h = _workingHours[i];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text(h['day'].toString().substring(0, 3), style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold))),
                Switch(value: !h['closed'], onChanged: (v) => setState(() => h['closed'] = !v), activeColor: const Color(0xFF7C3AED)),
                const Spacer(),
                if (!h['closed'])
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _buildTimeBox(h['open']),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('to', style: TextStyle(color: Colors.white38, fontSize: 11))),
                    _buildTimeBox(h['close']),
                  ])
                else
                  const Text('Closed', style: TextStyle(color: Colors.white24, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)), child: Text(time, style: const TextStyle(color: Colors.white70, fontSize: 12)));
  }
}
