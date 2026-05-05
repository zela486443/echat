import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class EtokCameraScreen extends StatefulWidget {
  const EtokCameraScreen({super.key});

  @override
  State<EtokCameraScreen> createState() => _EtokCameraScreenState();
}

class _EtokCameraScreenState extends State<EtokCameraScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  int _selectedDuration = 15; // 15s, 60s
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          _buildTopControls(),
          _buildSidebar(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(LucideIcons.x, color: Colors.white), onPressed: () => context.pop()),
          Row(
            children: [
              const Icon(LucideIcons.music, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Text('Add sound', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: Icon(_flashMode == FlashMode.off ? LucideIcons.zapOff : LucideIcons.zap, color: Colors.white),
            onPressed: () {
              setState(() {
                _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
                _controller!.setFlashMode(_flashMode);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      top: 120,
      right: 12,
      child: Column(
        children: [
          _buildSidebarIcon(LucideIcons.refreshCcw, 'Flip'),
          const SizedBox(height: 20),
          _buildSidebarIcon(LucideIcons.gauge, 'Speed'),
          const SizedBox(height: 20),
          _buildSidebarIcon(LucideIcons.wand2, 'Filters'),
          const SizedBox(height: 20),
          _buildSidebarIcon(LucideIcons.timer, 'Timer'),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDurationOption(15),
              const SizedBox(width: 24),
              _buildDurationOption(60),
              const SizedBox(width: 24),
              const Text('Templates', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLargeIcon(LucideIcons.image, 'Upload'),
              _buildRecordButton(),
              _buildLargeIcon(LucideIcons.smile, 'Effects'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(int seconds) {
    final active = _selectedDuration == seconds;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = seconds),
      child: Text('${seconds}s', style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLargeIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      try {
        final file = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        // In production, we would navigate to a preview/edit screen
        _showSnackBar('Video recorded to: ${file.path}');
      } catch (e) {
        debugPrint('Stop recording error: $e');
      }
    } else {
      try {
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
        Future.delayed(Duration(seconds: _selectedDuration), () {
          if (_isRecording && mounted) _toggleRecording();
        });
      } catch (e) {
        debugPrint('Start recording error: $e');
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          _buildTopControls(),
          _buildSidebar(),
          _buildBottomControls(),
          if (_isRecording)
            Positioned(
              top: 100,
              left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Colors.red, size: 12),
                      const SizedBox(width: 8),
                      const Text('Recording', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(LucideIcons.x, color: Colors.white), onPressed: () => context.pop()),
          Row(
            children: [
              const Icon(LucideIcons.music, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              const Text('Add sound', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: Icon(_flashMode == FlashMode.off ? LucideIcons.zapOff : LucideIcons.zap, color: Colors.white),
            onPressed: () {
              setState(() {
                _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
                _controller!.setFlashMode(_flashMode);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      top: 120,
      right: 12,
      child: Column(
        children: [
          _buildSidebarIcon(LucideIcons.refreshCcw, 'Flip', () async {
            final cameras = await availableCameras();
            if (cameras.length < 2) return;
            final newLens = _controller!.description.lensDirection == CameraLensDirection.front ? CameraLensDirection.back : CameraLensDirection.front;
            final cam = cameras.firstWhere((c) => c.lensDirection == newLens);
            await _controller!.dispose();
            _controller = CameraController(cam, ResolutionPreset.high);
            await _controller!.initialize();
            if (mounted) setState(() {});
          }),
          const SizedBox(height: 20),
          _buildSidebarIcon(LucideIcons.gauge, 'Speed', () {}),
          const SizedBox(height: 20),
          _buildSidebarIcon(LucideIcons.wand2, 'Filters', () {}),
          const SizedBox(height: 20),
          _buildSidebarIcon(LucideIcons.timer, 'Timer', () {}),
        ],
      ),
    );
  }

  Widget _buildSidebarIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDurationOption(15),
              const SizedBox(width: 24),
              _buildDurationOption(60),
              const SizedBox(width: 24),
              const Text('Templates', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLargeIcon(LucideIcons.image, 'Upload', () {}),
              _buildRecordButton(),
              _buildLargeIcon(LucideIcons.smile, 'Effects', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(int seconds) {
    final active = _selectedDuration == seconds;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = seconds),
      child: Text('${seconds}s', style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLargeIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecordButton() {
     return GestureDetector(
       onTap: _toggleRecording,
       child: Container(
         width: 80,
         height: 80,
         padding: const EdgeInsets.all(4),
         decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
         child: AnimatedContainer(
           duration: const Duration(milliseconds: 200),
           decoration: BoxDecoration(color: const Color(0xFFFF0050), borderRadius: BorderRadius.circular(_isRecording ? 8 : 40)),
         ),
       ),
     );
  }
}
