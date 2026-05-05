import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';

class VideoMessageRecorder extends StatefulWidget {
  final Function(File videoFile) onSend;
  final VoidCallback onCancel;

  const VideoMessageRecorder({
    super.key,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<VideoMessageRecorder> createState() => _VideoMessageRecorderState();
}

class _VideoMessageRecorderState extends State<VideoMessageRecorder> with TickerProviderStateMixin {
  CameraController? _controller;
  bool _isRecording = false;
  int _duration = 0;
  Timer? _timer;
  bool _isInitialized = false;
  XFile? _recordedFile;
  late AnimationController _progressController;

  static const int maxDuration = 60; // seconds

  @override
  void initState() {
    super.initState();
    _initCamera();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: maxDuration),
    );
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use front camera if available
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _duration = 0;
      });
      _progressController.forward(from: 0);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _duration++;
          if (_duration >= maxDuration) {
            _stopRecording();
          }
        });
      });
    } catch (e) {
      debugPrint('Start recording error: $e');
    }
  }

  void _stopRecording() async {
    if (!_isRecording) return;

    _timer?.cancel();
    _progressController.stop();
    try {
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordedFile = file;
      });
    } catch (e) {
      debugPrint('Stop recording error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black87,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: SafeArea(
        child: Stack(
          children: [
            // Close Button
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(LucideIcons.x, color: Colors.white, size: 28),
                onPressed: widget.onCancel,
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular Camera Preview
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _ProgressPainter(
                                progress: _progressController.value,
                                color: _isRecording ? Colors.redAccent : Colors.white24,
                              ),
                            );
                          },
                        ),
                      ),
                      // Camera Clip
                      Container(
                        width: 250,
                        height: 250,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: ClipOval(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Timer
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_recordedFile == null) ...[
                        // Record Button
                        GestureDetector(
                          onTap: _isRecording ? _stopRecording : _startRecording,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(_isRecording ? 8 : 40),
                              ),
                              child: Icon(
                                _isRecording ? LucideIcons.square : LucideIcons.video,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Preview / Send Buttons
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, color: Colors.white54, size: 32),
                          onPressed: () => setState(() {
                            _recordedFile = null;
                            _duration = 0;
                            _progressController.reset();
                          }),
                        ),
                        const SizedBox(width: 40),
                        GestureDetector(
                          onTap: () => widget.onSend(File(_recordedFile!.path)),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.send, color: Colors.white, size: 32),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  if (!_isRecording && _recordedFile == null)
                    const Text(
                      'Tap to record',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(1, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressPainter old) => old.progress != progress || old.color != color;
}
