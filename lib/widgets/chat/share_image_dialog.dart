import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class ShareImageDialog extends StatefulWidget {
  const ShareImageDialog({super.key});

  @override
  State<ShareImageDialog> createState() => _ShareImageDialogState();
}

class _ShareImageDialogState extends State<ShareImageDialog> {
  bool _isProcessing = false;

  Future<void> _exportAsImage() async {
    setState(() => _isProcessing = true);
    // Simulate screenshot/image generation process
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.image, color: Colors.purpleAccent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Share as Image',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture this chat conversation and share it as a high-quality image.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildImagePreview(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _exportAsImage,
                    icon: _isProcessing
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.share2, size: 18),
                    label: Text(_isProcessing ? 'Processing...' : 'Share Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Mock preview of a chat screenshot
            Column(
              children: [
                _buildMockBubble(true, 'Hey, did you see the new design?'),
                _buildMockBubble(false, 'Yes, it looks amazing!'),
                _buildMockBubble(true, 'Let\'s share this snippet.'),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
            ),
            const Center(
              child: Icon(Icons.zoom_in, color: Colors.white24, size: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockBubble(bool isMe, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primary.withOpacity(0.3) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ),
      ),
    );
  }
}
