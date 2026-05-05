import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import '../../widgets/glassmorphic_container.dart';
import '../../providers/auth_provider.dart';
import '../../services/etok_service.dart';

class EtokCameraScreen extends ConsumerStatefulWidget {
  const EtokCameraScreen({super.key});

  @override
  ConsumerState<EtokCameraScreen> createState() => _EtokCameraScreenState();
}

class _EtokCameraScreenState extends ConsumerState<EtokCameraScreen> {
  CameraController? _controller;
  VideoPlayerController? _previewController;
  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;
  int _selectedDuration = 15;
  double _selectedSpeed = 1.0;
  String _stage = 'record'; // record, preview, edit, post
  int _countdown = 0;
  Timer? _countdownTimer;

  XFile? _recordedFile;
  bool _flashOn = false;
  int _timerSetting = 0; // 0, 3, 10

  final List<int> _durations = [15, 60, 180, 600];
  final List<double> _speeds = [0.5, 1.0, 2.0];

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

  void _startCountdown() {
    if (_timerSetting == 0) {
      _startRecording();
      return;
    }
    setState(() => _countdown = _timerSetting);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _countdownTimer?.cancel();
          _startRecording();
        }
      });
    });
  }

  void _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.startVideoRecording();
    setState(() {
      _isRecording = true;
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        if (_seconds >= _selectedDuration) {
          _stopRecording();
        }
      });
    });
  }

  void _stopRecording() async {
    if (!_isRecording) return;
    _recordedFile = await _controller!.stopVideoRecording();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _stage = 'preview';
    });
    _initPreview();
  }

  Future<void> _initPreview() async {
    if (_recordedFile == null) return;
    _previewController = VideoPlayerController.file(File(_recordedFile!.path));
    await _previewController!.initialize();
    await _previewController!.setLooping(true);
    await _previewController!.play();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _previewController?.dispose();
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  bool _isPosting = false;

  void _handlePost() async {
    if (_recordedFile == null) return;
    setState(() => _isPosting = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) return;

      final etokService = ref.read(etokServiceProvider);
      
      // Upload video
      final uploadRes = await etokService.uploadVideo(File(_recordedFile!.path));
      
      // Create record
      final success = await etokService.createVideo(
        authorId: user.id,
        description: _captionController.text,
        videoUrl: uploadRes['url'],
        duration: _previewController!.value.duration.inSeconds.toDouble(),
        privacy: _whoCanWatch,
        allowComments: _allowComments,
        allowDuet: _allowDuet,
        allowDownload: _allowDownload,
        hashtags: _extractHashtags(_captionController.text),
      );

      if (success) {
        if (mounted) context.go('/etok');
      } else {
        throw Exception('Failed to create video record');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  List<String> _extractHashtags(String text) {
    final exp = RegExp(r'\#\w+');
    return exp.allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
  }

  final TextEditingController _captionController = TextEditingController();
  String _whoCanWatch = 'everyone';
  bool _allowComments = true;
  bool _allowDuet = true;
  bool _allowDownload = true;

  @override
  Widget build(BuildContext context) {
    if (_stage == 'post') return _buildPostUI();
    if (_stage == 'preview' || _stage == 'edit') return _buildPreviewUI();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize!.height,
                  height: _controller!.value.previewSize!.width,
                  child: CameraPreview(_controller!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
            ),
          ),

          // Countdown Overlay
          if (_countdown > 0)
            Center(
              child: Text(
                '$_countdown',
                style: const TextStyle(color: Colors.white, fontSize: 120, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 20, color: Colors.black45)]),
              ),
            ),

          _buildRecordUI(),
        ],
      ),
    );
  }

  Widget _buildPostUI() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Post Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => setState(() => _stage = 'preview')),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(hintText: 'Describe your video... #hashtag @mention', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
                      ),
                    ),
                    Container(
                      width: 90, height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white10, 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: Colors.white24),
                        image: (_previewController != null && _previewController!.value.isInitialized) 
                          ? DecorationImage(image: FileImage(File(_recordedFile!.path)), fit: BoxFit.cover, opacity: 0.5)
                          : null,
                      ),
                      child: const Center(child: Icon(LucideIcons.video, color: Colors.white24, size: 32)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _tagBtn(LucideIcons.hash, 'Hashtag', () {
                      _captionController.text += ' #';
                      _captionController.selection = TextSelection.fromPosition(TextPosition(offset: _captionController.text.length));
                    }),
                    const SizedBox(width: 12),
                    _tagBtn(LucideIcons.atSign, 'Mention', () {
                      _captionController.text += ' @';
                      _captionController.selection = TextSelection.fromPosition(TextPosition(offset: _captionController.text.length));
                    }),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(color: Colors.white10),
                _buildPostOption(LucideIcons.globe, 'Who can watch', _whoCanWatch, true, onTap: () {
                  // Cycle privacy for demo parity
                  setState(() {
                    if (_whoCanWatch == 'everyone') _whoCanWatch = 'friends';
                    else if (_whoCanWatch == 'friends') _whoCanWatch = 'only_me';
                    else _whoCanWatch = 'everyone';
                  });
                }),
                _buildPostOption(LucideIcons.messageCircle, 'Allow Comments', _allowComments ? 'On' : 'Off', false, val: _allowComments, onToggle: (v) => setState(() => _allowComments = v)),
                _buildPostOption(LucideIcons.users, 'Allow Duet', _allowDuet ? 'On' : 'Off', false, val: _allowDuet, onToggle: (v) => setState(() => _allowDuet = v)),
                _buildPostOption(LucideIcons.download, 'Allow Download', _allowDownload ? 'On' : 'Off', false, val: _allowDownload, onToggle: (v) => setState(() => _allowDownload = v)),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isPosting ? null : _handlePost,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                    child: _isPosting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Post Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('By posting, you agree to our Terms & Privacy Policy', style: TextStyle(color: Colors.white24, fontSize: 11)),
              ],
            ),
          ),
          if (_isPosting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFFF0050)),
                    SizedBox(height: 20),
                    Text('Uploading your video...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tagBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Row(children: [Icon(icon, color: Colors.white70, size: 16), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white, fontSize: 13))]),
      ),
    );
  }

  Widget _buildPostOption(IconData icon, String title, String value, bool isSelection, {VoidCallback? onTap, bool val = true, Function(bool)? onToggle}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: Colors.white70, size: 18)),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
            const Spacer(),
            if (isSelection) ...[
              Text(value.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
            ] else
              Switch(value: val, onChanged: onToggle, activeColor: const Color(0xFFFF0050)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecordUI() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Duration Selector
          if (!_isRecording)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _durations.map((d) => GestureDetector(
                  onTap: () => setState(() => _selectedDuration = d),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedDuration == d ? Colors.white24 : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('${d}s', style: TextStyle(color: _selectedDuration == d ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                )).toList(),
              ),
            ),
          
          // Speed Selector
          if (!_isRecording)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _speeds.map((s) => GestureDetector(
                  onTap: () => setState(() => _selectedSpeed = s),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedSpeed == s ? Colors.white24 : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('${s}x', style: TextStyle(color: _selectedSpeed == s ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                )).toList(),
              ),
            ),

          // Main Record Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(icon: const Icon(LucideIcons.image, color: Colors.white, size: 28), onPressed: () {}),
              GestureDetector(
                onTap: _isRecording ? _stopRecording : _startCountdown,
                child: Container(
                  width: 80, height: 80,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
                      color: const Color(0xFFFF0050),
                      borderRadius: _isRecording ? BorderRadius.circular(8) : null,
                    ),
                  ),
                ),
              ),
              IconButton(icon: const Icon(LucideIcons.check, color: Colors.white, size: 28), onPressed: _recordedFile != null ? () => setState(() => _stage = 'preview') : null),
            ],
          ),
          const SizedBox(height: 10),
          Text(_isRecording ? '${_selectedDuration - _seconds}s remaining' : 'Tap to record', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPreviewUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_previewController != null && _previewController!.value.isInitialized)
            Positioned.fill(child: Center(child: AspectRatio(aspectRatio: _previewController!.value.aspectRatio, child: VideoPlayer(_previewController!))))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          Positioned(
            top: 40, left: 16,
            child: IconButton(icon: const Icon(LucideIcons.x, color: Colors.white, size: 32), onPressed: () => setState(() => _stage = 'record')),
          ),
          
          Positioned(
            bottom: 40, right: 16,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFFFF0050),
              onPressed: () => setState(() => _stage = 'post'),
              child: const Icon(LucideIcons.arrowRight, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

final etokServiceProvider = Provider((ref) => EtokService());
