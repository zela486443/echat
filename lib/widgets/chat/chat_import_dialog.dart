import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../glassmorphic_container.dart';

class ChatImportDialog extends StatefulWidget {
  const ChatImportDialog({super.key});

  @override
  State<ChatImportDialog> createState() => _ChatImportDialogState();
}

class _ChatImportDialogState extends State<ChatImportDialog> {
  bool _isImporting = false;
  String? _fileName;
  int _messageCount = 0;

  Future<void> _pickFile() async {
    // Mock file picker
    setState(() {
      _fileName = 'telegram_export_2024.json';
      _messageCount = 1245;
    });
  }

  Future<void> _startImport() async {
    setState(() => _isImporting = true);
    // Simulate import process
    await Future.delayed(const Duration(seconds: 3));
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
            const Icon(LucideIcons.fileInput, color: Colors.blueAccent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Import Chat History',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a JSON file from Telegram or WhatsApp to import your messages.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            if (_fileName == null)
              _buildUploadPlaceholder()
            else
              _buildFilePreview(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isImporting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_fileName == null || _isImporting) ? null : _startImport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isImporting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Import Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppTheme.primary, size: 32),
            const SizedBox(height: 8),
            const Text('Tap to select file', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const Text('.json files only', style: TextStyle(color: Colors.white24, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.fileJson, color: Colors.amber, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName!,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$_messageCount messages found',
                  style: TextStyle(color: AppTheme.primary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _fileName = null),
            icon: const Icon(Icons.refresh, color: Colors.white38, size: 18),
          ),
        ],
      ),
    );
  }
}
