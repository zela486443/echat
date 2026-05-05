import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/active_call_provider.dart';
import '../screens/calls/incoming_call_screen.dart';
import '../screens/calls/active_call_screen.dart';
import 'chat_avatar.dart';

class CallOverlay extends ConsumerWidget {
  const CallOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(activeCallProvider);
    
    if (call.status == CallStatus.idle) {
      return const SizedBox.shrink();
    }

    // Full Screen Gates
    if (call.status == CallStatus.incomingRinging) {
      return Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: const IncomingCallScreen(),
        ),
      );
    }

    if (call.status == CallStatus.outgoingCalling || call.status == CallStatus.connecting) {
      return Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: const ActiveCallScreen(),
        ),
      );
    }

    // Mini Overlay for In-Call
    if (call.status == CallStatus.inCall) {
      final route = GoRouterState.of(context).uri.path;
      if (route == '/active-call') {
        return Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: const ActiveCallScreen(),
          ),
        );
      }

      return Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: GestureDetector(
          onTap: () => context.push('/active-call'),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1A1A),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  ChatAvatar(name: call.peerName, src: call.peerAvatar, size: 'sm'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          call.peerName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatDuration(call.durationSeconds),
                          style: const TextStyle(color: Colors.green, fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.phoneOff, color: Colors.red, size: 20),
                    onPressed: () => ref.read(activeCallProvider.notifier).endCall(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Ended/Rejected/Failed states - show full screen briefly then it resets to idle
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: const ActiveCallScreen(),
      ),
    );
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
