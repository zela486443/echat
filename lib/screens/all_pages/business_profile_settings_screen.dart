import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/business_profile_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

final businessProfileServiceProvider = Provider((ref) => BusinessProfileService());

class BusinessProfileSettingsScreen extends ConsumerStatefulWidget {
  const BusinessProfileSettingsScreen({super.key});

  @override
  ConsumerState<BusinessProfileSettingsScreen> createState() => _BusinessProfileSettingsScreenState();
}

class _BusinessProfileSettingsScreenState extends ConsumerState<BusinessProfileSettingsScreen> {
  BusinessProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final profile = await ref.read(businessProfileServiceProvider).getProfile(user.id);
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _handleSave() async {
    final user = ref.read(authProvider).value;
    if (user == null || _profile == null) return;
    await ref.read(businessProfileServiceProvider).saveProfile(user.id, _profile!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business profile saved!'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _profile == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

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
        title: Column(
          children: [
            const Text('Business Profile', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            Text(
              !_profile!.isEnabled ? 'Disabled' : 'Enabled',
              style: TextStyle(color: _profile!.isEnabled ? const Color(0xFF10B981) : Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.check, color: Color(0xFF7C3AED)),
            onPressed: _handleSave,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          _buildSectionTitle('STATUS'),
          _buildGroup([
            _buildToggleRow(
              icon: LucideIcons.briefcase,
              iconBg: Colors.indigo,
              label: 'Business Mode',
              sub: 'Enable business features',
              value: _profile!.isEnabled,
              onChanged: (v) => setState(() => _profile!.isEnabled = v),
              activeColor: accent.color,
            ),
          ]),

          if (_profile!.isEnabled) ...[
            _buildSectionTitle('BUSINESS INFO'),
            _buildGroup([
              _buildInputRow(
                label: 'Business Name',
                hint: 'Your business name',
                value: _profile!.businessName,
                onChanged: (v) => _profile!.businessName = v,
              ),
              _buildDivider(),
              _buildInputRow(
                label: 'Address',
                hint: '123 Main St, Addis Ababa',
                icon: LucideIcons.mapPin,
                value: _profile!.address,
                onChanged: (v) => _profile!.address = v,
              ),
              _buildDivider(),
              _buildInputRow(
                label: 'Phone',
                hint: '+251 912 345 678',
                icon: LucideIcons.phone,
                value: _profile!.phone,
                keyboardType: TextInputType.phone,
                onChanged: (v) => _profile!.phone = v,
              ),
              _buildDivider(),
              _buildInputRow(
                label: 'Website',
                hint: 'https://example.com',
                icon: LucideIcons.globe,
                value: _profile!.website,
                keyboardType: TextInputType.url,
                onChanged: (v) => _profile!.website = v,
              ),
            ]),

            _buildSectionTitle('AUTO MESSAGES'),
            _buildGroup([
              _buildTextareaRow(
                label: 'Welcome Message',
                hint: 'Sent when someone starts a chat...',
                icon: LucideIcons.messageSquare,
                value: _profile!.welcomeMessage,
                onChanged: (v) => _profile!.welcomeMessage = v,
              ),
            ]),

            _buildSectionTitle('AWAY MODE'),
            _buildGroup([
              _buildToggleRow(
                icon: LucideIcons.moon,
                iconBg: Colors.blueGrey,
                label: 'Away Mode',
                sub: 'Auto-reply when unavailable',
                value: _profile!.awayEnabled,
                onChanged: (v) => setState(() => _profile!.awayEnabled = v),
                activeColor: accent.color,
              ),
              if (_profile!.awayEnabled) ...[
                _buildDivider(),
                _buildTextareaRow(
                  label: 'Away Message',
                  hint: "We're currently away...",
                  value: _profile!.awayMessage,
                  onChanged: (v) => _profile!.awayMessage = v,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _buildTimePickerField('Away from', _profile!.awayStartTime, (v) => setState(() => _profile!.awayStartTime = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTimePickerField('Away until', _profile!.awayEndTime, (v) => setState(() => _profile!.awayEndTime = v))),
                    ],
                  ),
                ),
              ],
            ]),

            _buildSectionTitle('WORKING HOURS'),
            _buildGroup(
              _profile!.hours.map((h) => _buildWorkingHourRow(h)).toList(),
            ),
          ],
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildInputRow({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: Colors.white38, size: 12), const SizedBox(width: 6)],
              Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextareaRow({
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, color: Colors.white38, size: 12), const SizedBox(width: 6)],
              Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(String label, String value, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.parse(value.split(':')[0]), minute: int.parse(value.split(':')[1])));
            if (time != null) onChanged('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const Icon(LucideIcons.clock, color: Colors.white24, size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHourRow(BusinessHours h) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text(h.day.substring(0, 3), style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 13))),
              Switch(value: !h.closed, onChanged: (v) => setState(() => h.closed = !v), activeColor: ref.watch(themeProvider).color),
              if (!h.closed) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      _buildMiniTime(h.open, (v) => setState(() => h.open = v)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(color: Colors.white24, fontSize: 10))),
                      _buildMiniTime(h.close, (v) => setState(() => h.close = v)),
                    ],
                  ),
                ),
              ] else
                const Expanded(child: Text('Closed', style: TextStyle(color: Colors.white24, fontSize: 12))),
            ],
          ),
        ),
        if (h.day != 'Sunday') _buildDivider(),
      ],
    );
  }

  Widget _buildMiniTime(String value, ValueChanged<String> onChanged) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final time = await showTimePicker(context: context, initialTime: TimeOfDay(hour: int.parse(value.split(':')[0]), minute: int.parse(value.split(':')[1])));
          if (time != null) onChanged('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.05))),
          alignment: Alignment.center,
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
