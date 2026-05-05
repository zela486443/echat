import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class GroupAdminPanel extends StatefulWidget {
  final String groupId;
  final int currentSlowMode;
  final List<dynamic> members;
  final Function(int seconds) onSlowModeChanged;

  const GroupAdminPanel({
    super.key,
    required this.groupId,
    required this.currentSlowMode,
    required this.members,
    required this.onSlowModeChanged,
  });

  @override
  State<GroupAdminPanel> createState() => _GroupAdminPanelState();
}

class _GroupAdminPanelState extends State<GroupAdminPanel> {
  late int _selectedSlowMode;
  final List<int> _slowModeOptions = [0, 10, 30, 60, 300, 3600];

  @override
  void initState() {
    super.initState();
    _selectedSlowMode = widget.currentSlowMode;
  }

  String _slowLabel(int s) {
    if (s == 0) return 'Off';
    if (s < 60) return '${s}s';
    if (s < 3600) return '${s ~/ 60}m';
    return '${s ~/ 3600}h';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.shieldCheck, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Slow Mode Section
          const Text(
            'SLOW MODE',
            style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _slowModeOptions.map((s) {
              final isSelected = _selectedSlowMode == s;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSlowMode = s);
                  widget.onSlowModeChanged(s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? AppTheme.primary : Colors.white12),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
                    ],
                  ),
                  child: Text(
                    _slowLabel(s),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Permissions Section
          const Text(
            'GLOBAL PERMISSIONS',
            style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          GlassmorphicContainer(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                _buildPermissionSwitch('Send Messages', true),
                _buildPermissionSwitch('Send Media', true),
                _buildPermissionSwitch('Add Users', false),
                _buildPermissionSwitch('Pin Messages', false),
                _buildPermissionSwitch('Change Group Info', false),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Actions
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPermissionSwitch(String label, bool initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
          Switch(
            value: initialValue,
            onChanged: (v) {},
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
