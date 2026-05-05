import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;

class StoryCreatorOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String? content, String? mediaUrl, String type, String? bgColor) onPost;

  const StoryCreatorOverlay({super.key, required this.onClose, required this.onPost});

  @override
  State<StoryCreatorOverlay> createState() => _StoryCreatorOverlayState();
}

class _StoryCreatorOverlayState extends State<StoryCreatorOverlay> {
  int _step = 0; // 0: Create, 1: Share
  String _mode = 'text'; // 'text' or 'media'
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  
  String _selectedBg = 'linear-gradient(135deg, #f97316, #ec4899)';
  Color _solidColor = const Color(0xFF7C3AED);
  bool _isGradient = true;
  bool _isPosting = false;

  File? _mediaFile;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _gradients = [
    {'name': 'Sunset', 'value': 'linear-gradient(135deg, #f97316, #ec4899)', 'colors': [Color(0xFFF97316), Color(0xFFEC4899)]},
    {'name': 'Ocean', 'value': 'linear-gradient(135deg, #06b6d4, #7c3aed)', 'colors': [Color(0xFF06B6D4), Color(0xFF7C3AED)]},
    {'name': 'Aurora', 'value': 'linear-gradient(135deg, #10b981, #06b6d4, #7c3aed)', 'colors': [Color(0xFF10B981), Color(0xFF06B6D4), Color(0xFF7C3AED)]},
    {'name': 'Rose', 'value': 'linear-gradient(135deg, #f43f5e, #fb923c)', 'colors': [Color(0xFFF43F5E), Color(0xFFFB923C)]},
    {'name': 'Midnight', 'value': 'linear-gradient(135deg, #1e1b4b, #4c1d95)', 'colors': [Color(0xFF1E1B4B), Color(0xFF4C1D95)]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _step == 0 ? _buildCreatorStep() : _buildShareStep(),
          if (_isPosting)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildCreatorStep() {
    return Stack(
      children: [
        // Background
        if (_mode == 'text')
          _buildBackground()
        else if (_mediaFile != null)
          Positioned.fill(
            child: _videoController != null && _videoController!.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  )
                : Image.file(_mediaFile!, fit: BoxFit.contain),
          ),

        // Header
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: widget.onClose),
                  const Text('New Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(LucideIcons.download, color: Colors.white70, size: 20), onPressed: () {}),
                ],
              ),
            ),
          ),
        ),

        // Text input or Placeholder
        if (_mode == 'text')
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _textController,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Type something...', hintStyle: TextStyle(color: Colors.white38)),
                maxLines: null,
              ),
            ),
          )
        else if (_mediaFile == null)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickMedia,
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.image, color: Colors.white54, size: 32),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Tap to add photo or video', style: TextStyle(color: Colors.white38, fontSize: 14)),
              ],
            ),
          ),

        // Bottom Controls
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_mode == 'media' && _mediaFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Row(
                    children: [
                      _toolBtn(LucideIcons.palette, () => _showBgPicker()),
                      const SizedBox(width: 12),
                      _toolBtn(LucideIcons.smile, () {}),
                      const SizedBox(width: 12),
                      _toolBtn(LucideIcons.type, () => setState(() => _mode = 'text')),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_mode == 'text' && _textController.text.isEmpty) return;
                          if (_mode == 'media' && _mediaFile == null) return;
                          setState(() => _step = 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF29B6F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Row(
                          children: [
                            Text('NEXT', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(LucideIcons.chevronRight, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareStep() {
    return Stack(
      children: [
        // Background
        Positioned.fill(child: Container(color: const Color(0xFF0E0E0E))),
        
        // Header
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => setState(() => _step = 0)),
                  const Expanded(child: Center(child: Text('New Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),

        // Panel
        Positioned.fill(
          top: 100,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Share story', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text('Choose who can view your story', style: TextStyle(color: Colors.white38, fontSize: 14)),
                    ),
                    const SizedBox(height: 16),
                    _privacyOption('Everyone', 'Everyone can view', LucideIcons.globe, const Color(0xFF29B6F6), true),
                    _privacyOption('Contacts', 'Only your contacts', LucideIcons.users2, const Color(0xFF7C4DFF), false),
                    _privacyOption('Close Friends', 'Selected group', LucideIcons.star, const Color(0xFF4CAF50), false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    _toggleRow('Allow Screenshots', true),
                    const Divider(color: Colors.white10),
                    _toggleRow('Post to My Profile', true),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                child: Text('Keep this story on your profile even after it expires in 24 hours.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white30, fontSize: 12)),
              ),
            ],
          ),
        ),

        // Post Button
        Positioned(
          bottom: 40, left: 20, right: 20,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                setState(() => _isPosting = true);
                try {
                  await widget.onPost(
                    _mode == 'text' ? _textController.text : _captionController.text,
                    _mode == 'media' ? _mediaFile?.path : null,
                    _mode,
                    _isGradient ? _selectedBg : '#${_solidColor.value.toRadixString(16).substring(2)}',
                  );
                } finally {
                  if (mounted) setState(() => _isPosting = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              child: const Text('Post Story'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    if (_isGradient) {
      final gradientData = _gradients.firstWhere((g) => g['value'] == _selectedBg, orElse: () => _gradients[0]);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientData['colors'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }
    return Container(color: _solidColor);
  }

  Widget _toolBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70),
      onPressed: onTap,
      style: IconButton.styleFrom(backgroundColor: Colors.white10),
    );
  }

  Widget _privacyOption(String title, String sub, IconData icon, Color color, bool selected) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 20)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: Container(
        width: 22, height: 22,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? const Color(0xFF29B6F6) : Colors.white24, width: 2)),
        child: selected ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF29B6F6), shape: BoxShape.circle))) : null,
      ),
    );
  }

  Widget _toggleRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
          Switch(value: value, onChanged: (_) {}, activeColor: const Color(0xFF29B6F6)),
        ],
      ),
    );
  }

  void _pickMedia() async {
    final XFile? file = await _picker.pickMedia();
    if (file != null) {
      final extension = p.extension(file.path).toLowerCase();
      final isVideo = ['.mp4', '.mov', '.webm', '.3gp'].contains(extension);
      
      _videoController?.dispose();
      _videoController = null;

      if (isVideo) {
        _videoController = VideoPlayerController.file(File(file.path))
          ..initialize().then((_) {
            setState(() {});
            _videoController?.play();
            _videoController?.setLooping(true);
          });
      }

      setState(() {
        _mediaFile = File(file.path);
        _mode = 'media';
      });
    }
  }

  void _showBgPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Background', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._gradients.map((g) => GestureDetector(
                    onTap: () {
                      setState(() { 
                        _selectedBg = g['value']; 
                        _isGradient = true; 
                        _mode = 'text';
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 54, height: 54,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: g['colors']),
                        borderRadius: BorderRadius.circular(16),
                        border: _selectedBg == g['value'] ? Border.all(color: Colors.white, width: 2) : null,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
