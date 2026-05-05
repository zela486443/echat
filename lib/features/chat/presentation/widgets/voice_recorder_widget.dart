import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';

// Note: In a fully compiled app, we would use the record/audioplayers packages.
class VoiceRecorderWidget extends ConsumerStatefulWidget {
  final Future<void> Function(File file, int duration) onSend;

  const VoiceRecorderWidget({super.key, required this.onSend});

  @override
  ConsumerState<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends ConsumerState<VoiceRecorderWidget> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  int _recordSeconds = 0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _pulseController.repeat(reverse: true);
    // Simulate recording timer logic here
  }

  void _stopAndSend() async {
    setState(() => _isRecording = false);
    _pulseController.stop();
    // Simulate sending mock file
    await widget.onSend(File('path/to/audio.m4a'), _recordSeconds * 1000);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _startRecording,
      onLongPressEnd: (_) => _stopAndSend(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? Colors.red.withOpacity(0.5 + (_pulseController.value * 0.5)) : Theme.of(context).primaryColor,
              boxShadow: _isRecording 
                  ? [BoxShadow(color: Colors.red.shade200, blurRadius: 15 * _pulseController.value, spreadRadius: 5 * _pulseController.value)] 
                  : [],
            ),
            child: Icon(
              _isRecording ? LucideIcons.mic : LucideIcons.mic,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
