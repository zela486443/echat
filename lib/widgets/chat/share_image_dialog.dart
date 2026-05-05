import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../theme/app_theme.dart';

class ShareImageDialog extends StatefulWidget {
  final GlobalKey repaintKey;
  final String chatName;
  const ShareImageDialog({super.key, required this.repaintKey, required this.chatName});

  @override
  State<ShareImageDialog> createState() => _ShareImageDialogState();
}

class _ShareImageDialogState extends State<ShareImageDialog> {
  Uint8List? _imageBytes;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _captureImage();
  }

  Future<void> _captureImage() async {
    setState(() => _isCapturing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final boundary = widget.repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) { setState(() => _isCapturing = false); return; }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      setState(() { _imageBytes = byteData?.buffer.asUint8List(); _isCapturing = false; });
    } catch (e) {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _saveToGallery() async {
    if (_imageBytes == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/chat_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_imageBytes!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to gallery'), behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e'), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _shareImage() async {
    if (_imageBytes == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/chat_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_imageBytes!);
      await Share.shareXFiles([XFile(file.path)], text: 'Chat with ${widget.chatName}');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1130),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Export as Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isCapturing)
            const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          else if (_imageBytes != null)
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              clipBehavior: Clip.antiAlias,
              child: Image.memory(_imageBytes!, fit: BoxFit.contain),
            )
          else
            const SizedBox(height: 100, child: Center(child: Text('Failed to capture', style: TextStyle(color: Colors.white38)))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
        if (_imageBytes != null) ...[
          IconButton(icon: const Icon(Icons.download, color: Colors.white54), onPressed: _saveToGallery, tooltip: 'Save'),
          ElevatedButton.icon(
            onPressed: _shareImage,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ],
    );
  }
}
