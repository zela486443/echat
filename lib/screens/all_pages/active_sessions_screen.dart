import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/aurora_gradient_bg.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../theme/app_theme.dart';
import '../../providers/device_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/device_service.dart';

class ActiveSessionsScreen extends ConsumerWidget {
  const ActiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(deviceSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => context.pop()),
        title: const Text('Active Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: AuroraGradientBg(
        child: sessionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white24)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white24))),
          data: (sessions) {
            final current = sessions.firstWhere((s) => s.isCurrent, orElse: () => sessions.first);
            final others = sessions.where((s) => !s.isCurrent).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentSession(current),
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader('Other Active Sessions'),
                    const SizedBox(height: 12),
                    ...others.map((s) => _buildSessionItem(ref, s)),
                  ],
                  const SizedBox(height: 32),
                  _buildTerminateAllButton(ref),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentSession(DeviceSession s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('This Device'),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          padding: const EdgeInsets.all(20),
          isStrong: true,
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: Icon(s.deviceType == 'mobile' ? LucideIcons.smartphone : LucideIcons.monitor, color: Colors.green, size: 24)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${s.deviceName} • Online', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${s.os} • ${s.location}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title.toUpperCase(), style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2));
  }

  Widget _buildSessionItem(WidgetRef ref, DeviceSession s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(s.deviceType == 'mobile' ? LucideIcons.smartphone : LucideIcons.monitor, color: Colors.white38, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('${s.browser} on ${s.os}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text('Last active: ${DateFormat('MMM d, h:mm a').format(s.lastActive)}', style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ])),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
              onPressed: () => ref.read(deviceActionProvider.notifier).terminateSession(s.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminateAllButton(WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => ref.read(deviceActionProvider.notifier).terminateAllOthers(),
        child: const Text('Terminate All Other Sessions', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
