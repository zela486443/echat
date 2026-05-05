import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../application/etok_controller.dart';

class EtokCameraScreen extends ConsumerStatefulWidget {
  const EtokCameraScreen({super.key});

  @override
  ConsumerState<EtokCameraScreen> createState() => _EtokCameraScreenState();
}

class _EtokCameraScreenState extends ConsumerState<EtokCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high, enableAudio: true);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (_isRecording) {
      final file = await _cameraController!.stopVideoRecording();
      setState(() => _isRecording = false);
      
      // Native navigation passing file to preview/publish screen
      if (mounted) {
        // Trigger publish logic automatically for prototype
        ref.read(etokControllerProvider.notifier).publishVideo(file.path, 'My new Etok #flutter');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video saved and publishing!')));
        context.pop();
      }
    } else {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          
          // Top Controls (Flash, Flip, Audio)
          Positioned(
            top: 50, right: 20,
            child: Column(
              children: [
                _IconButton(LucideIcons.camera, () async {
                   // Flip camera logic
                   if (_cameras != null && _cameras!.length > 1) {
                     final currentLens = _cameraController!.description.lensDirection;
                     final newLens = currentLens == CameraLensDirection.front 
                         ? _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back)
                         : _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
                     _cameraController = CameraController(newLens, ResolutionPreset.high);
                     await _cameraController!.initialize();
                     if (mounted) setState(() {});
                   }
                }),
                const SizedBox(height: 20),
                _IconButton(Icons.flash_off, () {}),
                const SizedBox(height: 20),
                _IconButton(LucideIcons.music, () {}),
              ],
            ),
          ),
          
          // Close btn
          Positioned(
            top: 50, left: 20,
            child: _IconButton(Icons.close, () => context.pop()),
          ),
          
          // Record Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isRecording ? 40 : 64,
                      height: _isRecording ? 40 : 64,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(_isRecording ? 8 : 32),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _IconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
