import 'dart:async';
import 'package:collection/collection.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/stars_provider.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/chat_avatar.dart';
import '../../widgets/quick_reply_bar.dart';
import '../../services/supabase_service.dart';
import '../../core/security_utils.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../widgets/video_message_recorder.dart';
import 'drawing_canvas_screen.dart';
import '../../widgets/sticker_gif_picker.dart';
import '../../services/sticker_service.dart';
import '../../widgets/gift_picker_overlay.dart';
import '../../widgets/bill_split_creator_overlay.dart';
import '../../widgets/typing_dots.dart';
import '../../providers/call_provider.dart';
import '../../services/draft_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/smart_reply_bar.dart';
import '../../widgets/chat/game_card.dart';

// ─── Chat Feature State ───────────────────────────────────────────────
class _ChatFeatures {
  bool isMuted = false;
  bool isSecret = false;
  bool isSilent = false;
  bool ghostMode = false;
  bool selectMode = false;
  bool showSearch = false;
  bool showPollCreator = false;
  bool showBillSplit = false;
  bool showGiftPicker = false;
  bool showChecklistCreator = false;
  bool showStickerPicker = false;
  bool showScheduleDialog = false;
  bool showScheduledList = false;
  bool showWallpaperPicker = false;
  bool showThemePicker = false;
  bool showSummarySheet = false;
  bool isUploading = false;
  int uploadProgress = 0;
  String disappearingTimer = 'off';
  String chatWallpaper = '';
  String chatBubbleColor = '';
  bool isLocked = false;
  bool showLockScreen = false;
  String lockPin = '';
  String? correctPinHash;
  Map<String, String> translations = {};
  bool viewOnceMode = false;
  bool isNetworkOnline = true;
  bool isVoiceChatActive = false; // Add this
  bool pendingUndo = false;
  String? pendingUndoId;
  int scheduledCount = 0;
  Set<String> pinnedMessages = {};
  Set<String> selectedMessages = {};
}

// ─── Timer Options ────────────────────────────────────────────────────
const _timerOptions = [
  {'value': 'off', 'label': 'Off'},
  {'value': '1m', 'label': '1 min'},
  {'value': '1h', 'label': '1 hour'},
  {'value': '1d', 'label': '1 day'},
  {'value': '1w', 'label': '1 week'},
];

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final _feat = _ChatFeatures();

  List<String> _typingUsers = [];
  dynamic _presenceChannel;
  Message? _replyToMessage;
  Message? _editingMessage;
  Timer? _typingTimer;
  List<Map<String, dynamic>> _scheduledMessages = [];
  List<String> _smartReplies = [];
  List<Map<String, dynamic>> _polls = [];
  String _searchQuery = '';
  
  // Voice Recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecordingVoice = false;
  String? _recordingPath;
  Timer? _voiceTimer;
  int _voiceDuration = 0;
  
  // Feature Overlays
  bool _showVideoRecorder = false;

  // Wallpaper options
  final _wallpapers = [
    '', // default
    'gradient_purple',
    'gradient_blue',
    'gradient_pink',
    'gradient_dark',
    'dots',
    'stars',
  ];

  // Bubble color options
  final _bubbleColors = [
    '', // default
    '#7C3AED',
    '#2563EB',
    '#DC2626',
    '#059669',
    '#D97706',
    '#DB2777',
  ];

  @override
  void initState() {
    super.initState();
    _setupPresence();
    _mockScreenshotDetection();
    _messageController.addListener(_onTextChanged);
    _loadChatPreferences();
    _loadDraft();
    _startScheduledMessageCheck();
  }

  Future<void> _loadDraft() async {
    final draft = await DraftService().getDraft(widget.chatId);
    if (draft != null && mounted) {
      _messageController.text = draft;
    }
  }

  @override
  void dispose() {
    if (_presenceChannel != null) {
      try {
        ref.read(supabaseServiceProvider).setTypingStatus(_presenceChannel, false);
      } catch (_) {}
    }
    DraftService().saveDraft(widget.chatId, _messageController.text);
    _messageController.removeListener(_onTextChanged);
    _typingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadChatPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _feat.isMuted = prefs.getBool('mute_${widget.chatId}') ?? false;
      _feat.isSecret = prefs.getBool('secret_${widget.chatId}') ?? false;
      _feat.isSilent = prefs.getBool('silent_${widget.chatId}') ?? false;
      _feat.ghostMode = prefs.getBool('ghost_mode') ?? false;
      _feat.disappearingTimer = prefs.getString('disappear_${widget.chatId}') ?? 'off';
      _feat.chatWallpaper = prefs.getString('wallpaper_${widget.chatId}') ?? '';
      _feat.chatBubbleColor = prefs.getString('bubble_${widget.chatId}') ?? '';
      _feat.isLocked = prefs.getBool('locked_${widget.chatId}') ?? false;
      if (_feat.isLocked) {
        _feat.showLockScreen = true;
        _feat.correctPinHash = prefs.getString('chat_pin_${widget.chatId}');
      }

      // Load pinned messages
      final pinned = prefs.getStringList('pinned_${widget.chatId}') ?? [];
      _feat.pinnedMessages = pinned.toSet();
    });
  }

  void _setupPresence() {
    _presenceChannel = ref.read(supabaseServiceProvider).subscribeToPresence(
      widget.chatId,
      (users) => setState(() => _typingUsers = users),
    );
  }

  void _onTextChanged() {
    if (_presenceChannel != null) {
      final isTyping = _messageController.text.isNotEmpty;
      ref.read(supabaseServiceProvider).setTypingStatus(_presenceChannel, isTyping);
    }
    // Update smart replies based on text
    setState(() {}); // to update send button visibility
  }

  void _startScheduledMessageCheck() {
    Timer.periodic(const Duration(seconds: 30), (_) async {
      final now = DateTime.now();
      final toSend = _scheduledMessages.where((m) {
        final scheduled = DateTime.parse(m['scheduledAt'] as String);
        return scheduled.isBefore(now);
      }).toList();
      for (final msg in toSend) {
        await _sendMessage(content: msg['text'] as String);
        setState(() => _scheduledMessages.remove(msg));
      }
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) prefs.setBool(key, value);
    if (value is String) prefs.setString(key, value);
    if (value is List<String>) prefs.setStringList(key, value);
  }

  Future<void> _sendMessage({
    String? content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? fileName,
    Map<String, dynamic>? metadata,
  }) async {
    final text = content ?? _messageController.text.trim();
    if (text.isEmpty && type == MessageType.text) return;

    final currentUserId = ref.read(authProvider).value?.id;
    if (currentUserId == null) return;

    // Offline queue
    if (!_feat.isNetworkOnline && type == MessageType.text) {
      final prefs = await SharedPreferences.getInstance();
      final queued = prefs.getStringList('queue_${widget.chatId}') ?? [];
      queued.add(text);
      await prefs.setStringList('queue_${widget.chatId}', queued);
      _showSnackBar('⏳ Queued — will send when online');
      if (type == MessageType.text) _messageController.clear();
      return;
    }

    try {
      final chats = await ref.read(supabaseServiceProvider).getChats(currentUserId);
      final chat = chats.firstWhere((c) => c.id == widget.chatId, orElse: () => throw Exception('Chat not found'));
      final receiverId = (chat.participant1 == currentUserId) ? chat.participant2 : chat.participant1;
      final mergedMetadata = {
        ...?_feat.viewOnceMode ? {'view_once': true} : null,
        ...?metadata,
      };

      final res = await ref.read(chatActionProvider.notifier).sendMessage(
        chatId: widget.chatId,
        receiverId: receiverId,
        content: type == MessageType.text ? text : (content ?? type.name),
        messageType: type,
        mediaUrl: mediaUrl,
        fileName: fileName,
        metadata: mergedMetadata,
      );

      if (type == MessageType.text && res != null) {
        _messageController.clear();
        DraftService().clearDraft(widget.chatId);
        setState(() {
          _replyToMessage = null;
          _editingMessage = null;
          _feat.viewOnceMode = false; 
          _feat.pendingUndo = true;
          _feat.pendingUndoId = res; // Actual message ID
        });
        // Auto-clear undo after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() { _feat.pendingUndo = false; _feat.pendingUndoId = null; });
        });
      }
      _scrollToBottom();
    } catch (e) {
      _showSnackBar('Failed to send message: $e');
    }
  }

  Future<void> _editMessage(String messageId, String newText) async {
    await Supabase.instance.client
        .from('messages')
        .update({'content': newText})
        .eq('id', messageId);
    setState(() { _editingMessage = null; _messageController.clear(); });
    _showSnackBar('Message edited');
  }

  Future<void> _deleteMessage(String messageId) async {
    final confirmed = await _showConfirmDialog('Delete Message', 'Delete this message?');
    if (!confirmed) return;
    try {
      await Supabase.instance.client.from('messages').delete().eq('id', messageId);
      _showSnackBar('Message deleted');
    } catch (e) {
      _showSnackBar('Failed to delete: $e');
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await _showConfirmDialog('Clear History', 'Clear all messages?');
    if (!confirmed) return;
    final userId = ref.read(authProvider).value?.id;
    if (userId == null) return;
    await Supabase.instance.client
        .from('messages')
        .delete()
        .eq('chat_id', widget.chatId);
    _showSnackBar('Chat history cleared');
  }

  Future<void> _deleteChat() async {
    final confirmed = await _showConfirmDialog('Delete Chat', 'Permanently delete this chat?');
    if (!confirmed) return;
    await Supabase.instance.client.from('chats').delete().eq('id', widget.chatId);
    if (mounted) context.go('/chats');
  }

  void _pinMessage(Message msg) async {
    setState(() {
      if (_feat.pinnedMessages.contains(msg.id)) {
        _feat.pinnedMessages.remove(msg.id);
        _showSnackBar('Message unpinned');
      } else {
        _feat.pinnedMessages.add(msg.id);
        _showSnackBar('Message pinned');
      }
    });
    await _savePref('pinned_${widget.chatId}', _feat.pinnedMessages.toList());
  }

  void _forwardMessage(Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1130),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _buildForwardPicker(msg),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1C1130)));
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1C1130),
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: Text(message, style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Confirm', style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ) ?? false;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    setState(() => _feat.isUploading = true);
    try {
      final userId = ref.read(authProvider).value?.id ?? 'anon';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${File(image.path).uri.pathSegments.last}';
      final bytes = await File(image.path).readAsBytes();
      await Supabase.instance.client.storage.from('chat-media').uploadBinary(fileName, bytes);
      final url = Supabase.instance.client.storage.from('chat-media').getPublicUrl(fileName);
      await _sendMessage(content: 'Photo', type: MessageType.image, mediaUrl: url);
    } catch (e) {
      _showSnackBar('Failed to upload image: $e');
    } finally {
      setState(() => _feat.isUploading = false);
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final path = file.path;
    if (path == null) return;

    setState(() => _feat.isUploading = true);
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final bytes = await File(path).readAsBytes();
      await Supabase.instance.client.storage.from('chat-media').uploadBinary(fileName, bytes);
      final url = Supabase.instance.client.storage.from('chat-media').getPublicUrl(fileName);
      await _sendMessage(content: file.name, type: MessageType.file, mediaUrl: url, fileName: file.name);
    } catch (e) {
      _showSnackBar('Failed to upload file: $e');
    } finally {
      setState(() => _feat.isUploading = false);
    }
  }

  void _showAttachmentSheet() {
    final items = [
      {'icon': Icons.photo_library, 'label': 'Gallery', 'color': const Color(0xFF7C3AED), 'fn': () { Navigator.pop(context); _pickImage(); }},
      {'icon': Icons.camera_alt, 'label': 'Camera', 'color': const Color(0xFFEC4899), 'fn': () async { Navigator.pop(context); final img = await _picker.pickImage(source: ImageSource.camera); if (img != null) _showSnackBar('Camera captured'); }},
      {'icon': Icons.insert_drive_file, 'label': 'File', 'color': const Color(0xFF3B82F6), 'fn': () { Navigator.pop(context); _pickFile(); }},
      {'icon': Icons.mic, 'label': 'Audio', 'color': const Color(0xFF10B981), 'fn': () { Navigator.pop(context); _showVoiceRecorder(); }},
      {'icon': Icons.location_on, 'label': 'Location', 'color': const Color(0xFFF59E0B), 'fn': () { Navigator.pop(context); _sendStaticLocation(); }},
      {'icon': Icons.poll, 'label': 'Poll', 'color': const Color(0xFF8B5CF6), 'fn': () { Navigator.pop(context); setState(() => _feat.showPollCreator = true); }},
      {'icon': Icons.checklist, 'label': 'Checklist', 'color': const Color(0xFF06B6D4), 'fn': () { Navigator.pop(context); setState(() => _feat.showChecklistCreator = true); }},
      {'icon': Icons.card_giftcard, 'label': 'Gift', 'color': const Color(0xFFF97316), 'fn': () { Navigator.pop(context); setState(() => _feat.showGiftPicker = true); }},
      {'icon': Icons.receipt, 'label': 'Bill Split', 'color': const Color(0xFF14B8A6), 'fn': () { Navigator.pop(context); setState(() => _feat.showBillSplit = true); }},
      {'icon': Icons.emoji_emotions, 'label': 'Sticker', 'color': const Color(0xFFFBBF24), 'fn': () { Navigator.pop(context); setState(() => _feat.showStickerPicker = true); }},
      {'icon': Icons.brush, 'label': 'Draw', 'color': const Color(0xFFEF4444), 'fn': () { Navigator.pop(context); _showDrawingCanvas(); }},
      {'icon': Icons.video_call, 'label': 'Video Note', 'color': const Color(0xFF8B5CF6), 'fn': () { 
        Navigator.pop(context); 
        setState(() => _showVideoRecorder = true);
      }},
      {'icon': Icons.contact_page, 'label': 'Contact', 'color': const Color(0xFF6366F1), 'fn': () { Navigator.pop(context); _showSnackBar('Contact sharing'); }},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF150D28),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              
              // View Once Mode Toggle
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white30, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('View Once Mode', style: TextStyle(color: Colors.white70, fontSize: 14))),
                    Switch(
                      value: _feat.viewOnceMode,
                      activeColor: AppTheme.primary,
                      onChanged: (v) {
                        setModalState(() => _feat.viewOnceMode = v);
                        setState(() => _feat.viewOnceMode = v);
                      },
                    ),
                  ],
                ),
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.85, mainAxisSpacing: 16, crossAxisSpacing: 8),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final item = items[i];
                  return GestureDetector(
                    onTap: item['fn'] as VoidCallback,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: (item['color'] as Color).withOpacity(0.3)),
                          ),
                          child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(item['label'] as String, style: const TextStyle(color: Colors.white60, fontSize: 11), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoiceRecorder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150D28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isRecordingVoice)
                const Text('Recording...', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
              else
                const Text('Hold to record', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Text(
                _formatVoiceDuration(_voiceDuration),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onLongPressStart: (_) async {
                  if (await _audioRecorder.hasPermission()) {
                    final dir = await getTemporaryDirectory();
                    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
                    await _audioRecorder.start(const RecordConfig(), path: path);
                    setModalState(() {
                      _isRecordingVoice = true;
                      _voiceDuration = 0;
                    });
                    setState(() {
                      _isRecordingVoice = true;
                      _recordingPath = path;
                    });
                    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                      setModalState(() => _voiceDuration++);
                      setState(() => _voiceDuration++);
                    });
                  }
                },
                onLongPressEnd: (_) async {
                  _voiceTimer?.cancel();
                  final path = await _audioRecorder.stop();
                  setModalState(() => _isRecordingVoice = false);
                  setState(() => _isRecordingVoice = false);
                  Navigator.pop(context);
                  if (path != null) {
                    _sendMediaFile(File(path), MessageType.voice, 'Voice Message');
                  }
                },
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: _isRecordingVoice ? Colors.redAccent : AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: (_isRecordingVoice ? Colors.redAccent : AppTheme.primary).withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Icon(_isRecordingVoice ? Icons.stop : Icons.mic, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
            ],
          ),
        ),
      ),
    );
  }

  String _formatVoiceDuration(int s) {
    final m = s ~/ 60;
    final ss = s % 60;
    return '${m.toString().padLeft(1, '0')}:${ss.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMediaFile(File file, MessageType type, String placeholder) async {
    setState(() => _feat.isUploading = true);
    _feat.uploadProgress = 0;
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final bytes = await file.readAsBytes();
      await Supabase.instance.client.storage.from('chat-media').uploadBinary(fileName, bytes);
      final url = Supabase.instance.client.storage.from('chat-media').getPublicUrl(fileName);
      await _sendMessage(content: placeholder, type: type, mediaUrl: url, fileName: file.uri.pathSegments.last);
    } catch (e) {
      _showSnackBar('Upload failed: $e');
    } finally {
      setState(() => _feat.isUploading = false);
    }
  }

  Future<void> _sendStaticLocation() async {
    // Send a static location message
    await _sendMessage(content: '[location:9.0054,38.7636]');
    _showSnackBar('📍 Location shared');
  }

  void _showDrawingCanvas() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DrawingCanvasScreen(
      onSend: (file) {
        _sendMediaFile(file, MessageType.image, 'Sketch');
      },
    )));
  }

  void _showWallpaperPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150D28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chat Wallpaper', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _wallpapers.length,
                  itemBuilder: (_, i) {
                    final wp = _wallpapers[i];
                    final isSelected = wp == _feat.chatWallpaper;
                    return GestureDetector(
                      onTap: () async {
                        setState(() => _feat.chatWallpaper = wp);
                        await _savePref('wallpaper_${widget.chatId}', wp);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 80, height: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? AppTheme.primary : Colors.white12, width: isSelected ? 2 : 1),
                          gradient: wp.isEmpty ? null : const LinearGradient(colors: [Color(0xFF1C1130), Color(0xFF0D0A1A)]),
                          color: wp.isEmpty ? const Color(0xFF0D0A1A) : null,
                        ),
                        child: wp.isEmpty
                            ? const Center(child: Text('None', style: TextStyle(color: Colors.white38, fontSize: 11)))
                            : Center(child: Text(wp.replaceAll('gradient_', '').replaceAll('_', '\n'), style: const TextStyle(color: Colors.white54, fontSize: 10), textAlign: TextAlign.center)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150D28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bubble Color', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _bubbleColors.map((c) {
                final isSelected = c == _feat.chatBubbleColor;
                return GestureDetector(
                  onTap: () async {
                    setState(() => _feat.chatBubbleColor = c);
                    await _savePref('bubble_${widget.chatId}', c);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: c.isEmpty ? const Color(0xFF7C3AED) : Color(int.parse(c.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2.5),
                    ),
                    child: c.isEmpty ? const Center(child: Text('D', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPollCreator() {
    final questionCtrl = TextEditingController();
    final List<TextEditingController> optionCtrls = [
      TextEditingController(text: 'Option 1'),
      TextEditingController(text: 'Option 2'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF150D28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Create Poll', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: questionCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Poll question')),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: optionCtrls.length,
                    itemBuilder: (c, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: TextField(controller: optionCtrls[i], style: const TextStyle(color: Colors.white), decoration: _inputDec('Option ${i + 1}'))),
                          if (optionCtrls.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              onPressed: () => setModalState(() => optionCtrls.removeAt(i)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setModalState(() => optionCtrls.add(TextEditingController())),
                  icon: Icon(Icons.add, color: AppTheme.primary),
                  label: Text('Add Option', style: TextStyle(color: AppTheme.primary)),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      final q = questionCtrl.text.trim();
                      if (q.isEmpty) return;
                      final options = optionCtrls.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
                      if (options.length < 2) return;

                      final poll = {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'question': q,
                        'options': options,
                        'votes': <String, List<String>>{},
                        'created_at': DateTime.now().toIso8601String(),
                      };
                      setState(() => _polls.add(poll));
                      Navigator.pop(context);
                      setState(() => _feat.showPollCreator = false);
                      _sendMessage(content: '📊 Poll: $q');
                    },
                    child: const Text('Create Poll', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showSendMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1130),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined, color: Colors.white70),
              title: const Text('Send Silently', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: const Text('Send without a notification', style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _sendMessage(metadata: {'silent': true});
                _showSnackBar('🔕 Sent silently');
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.white70),
              title: const Text('Schedule Message', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: const Text('Send at a specific time', style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                _showScheduleDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(minutes: 10));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1130),
        title: const Text('Schedule Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Text(_messageController.text.trim(), style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            const SizedBox(height: 16),
            const Text('Scheduling for +10 minutes from now', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final text = _messageController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _scheduledMessages.add({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'text': text, 'scheduledAt': selectedDate.toIso8601String()});
                  _feat.scheduledCount = _scheduledMessages.length;
                });
                _messageController.clear();
                Navigator.pop(context);
                _showSnackBar('Message scheduled for ${selectedDate.toLocal()}');
              }
            },
            child: const Text('Schedule', style: TextStyle(color: Color(0xFF7C3AED))),
          ),
        ],
      ),
    );
  }

  void _showChecklistCreator() {
    final titleCtrl = TextEditingController();
    final itemsCtrl = TextEditingController(text: 'Item 1\nItem 2\nItem 3');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF150D28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create Checklist', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: _inputDec('Checklist title')),
              const SizedBox(height: 12),
              TextField(controller: itemsCtrl, maxLines: 5, style: const TextStyle(color: Colors.white), decoration: _inputDec('Items (one per line)')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  onPressed: () {
                    Navigator.pop(context);
                    _sendMessage(content: '✅ Checklist: ${titleCtrl.text}');
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockScreen() {
    setState(() {
      _feat.showLockScreen = true;
      _feat.lockPin = '';
    });
  }

  void _showScheduledList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150D28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scheduled Messages', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_scheduledMessages.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('No scheduled messages', style: TextStyle(color: Colors.white38)))
            else
              ..._scheduledMessages.map((m) => ListTile(
                leading: const Icon(Icons.schedule, color: Color(0xFF7C3AED)),
                title: Text(m['text'] as String, style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(DateTime.parse(m['scheduledAt'] as String).toLocal().toString().substring(0, 16), style: const TextStyle(color: Colors.white38, fontSize: 11)),
                trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () {
                  setState(() { _scheduledMessages.removeWhere((x) => x['id'] == m['id']); _feat.scheduledCount = _scheduledMessages.length; });
                  Navigator.pop(context);
                }),
              )),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: Colors.white.withOpacity(0.05),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white12)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primary)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  Widget _buildForwardPicker(Message msg) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Forward Message', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Text((msg.content ?? '').length > 80 ? '${(msg.content ?? '').substring(0, 80)}...' : (msg.content ?? ''),
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          const SizedBox(height: 16),
          const Text('(Select chat to forward — feature in progress)', style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
              const SizedBox(width: 16),
              Expanded(child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: () { Navigator.pop(context); _showSnackBar('Forwarded!'); },
                child: const Text('Forward'),
              )),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Lock Screen UI ────────────────────────────────────────────────
  Widget _buildLockScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: AppTheme.primary.withOpacity(0.5))),
              child: const Icon(Icons.lock, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 24),
            const Text('Chat Locked', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Enter PIN to access', style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                width: 16, height: 16, margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _feat.lockPin.length > i ? AppTheme.primary : Colors.transparent,
                  border: Border.all(color: AppTheme.primary),
                ),
              )),
            ),
            const SizedBox(height: 32),
            // Numpad
            ...List.generate(4, (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (col) {
                  final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
                  final key = keys[row * 3 + col];
                  if (key.isEmpty) return const SizedBox(width: 80, height: 60);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (key == '⌫') {
                          if (_feat.lockPin.isNotEmpty) _feat.lockPin = _feat.lockPin.substring(0, _feat.lockPin.length - 1);
                        } else if (_feat.lockPin.length < 4) {
                          _feat.lockPin += key;
                          if (_feat.lockPin.length == 4) {
                            if (_feat.correctPinHash != null && SecurityUtils.verifyPin(_feat.lockPin, _feat.correctPinHash!)) {
                              _feat.showLockScreen = false;
                              _feat.lockPin = '';
                            } else {
                              _showSnackBar('Wrong PIN');
                              _feat.lockPin = '';
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      width: 80, height: 60, margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                      alignment: Alignment.center,
                      child: Text(key, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                  );
                }),
              ),
            )),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1C1130),
                    title: const Text('Forgot Chat PIN?', style: TextStyle(color: Colors.white)),
                    content: const Text('To remove the lock, you must reset it. This will unlock the chat.', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove Lock', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('locked_${widget.chatId}', false);
                  await prefs.remove('chat_pin_${widget.chatId}');
                  setState(() {
                    _feat.isLocked = false;
                    _feat.showLockScreen = false;
                    _feat.lockPin = '';
                  });
                }
              },
              child: Text('Forgot PIN?', style: TextStyle(color: AppTheme.primary.withOpacity(0.7), decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/chats'),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.arrow_back, color: Colors.white38, size: 16),
                SizedBox(width: 6),
                Text('Back to Chats', style: TextStyle(color: Colors.white38)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Main Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_feat.showLockScreen) return _buildLockScreen();

    final userProfile = ref.watch(authProvider).value;
    final messagesStream = ref.watch(chatMessagesStreamProvider(widget.chatId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _buildWallpaperBg(),
      appBar: _buildAppBar(userProfile),
      body: Stack(
        children: [
          Container(
            decoration: _getWallpaperDecoration(),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                // Status bars
                _buildStatusBars(),
                // Voice Chat Banner
                if (_feat.isVoiceChatActive) _buildVoiceChatBanner(),
                // Search bar
                if (_feat.showSearch) _buildSearchBar(),
                // Upload progress
                if (_feat.isUploading) _buildUploadProgress(),
                // Pinned message banner
                if (_feat.pinnedMessages.isNotEmpty) _buildPinnedBanner(messagesStream),
                // Select mode bar
                if (_feat.selectMode) _buildSelectModeBar(),
                // Undo send banner
                if (_feat.pendingUndo) _buildUndoBanner(),
                // Polls
                if (_polls.isNotEmpty) _buildPollsArea(),
                // Messages
                Expanded(child: _buildMessages(messagesStream, userProfile)),
                // Reply preview
                if (_replyToMessage != null) _buildReplyPreview(),
                // Smart replies
                if (_smartReplies.isNotEmpty) 
                  SmartReplyBar(
                    suggestions: _smartReplies,
                    onSelect: (text) {
                      setState(() => _smartReplies = []);
                      _sendMessage(content: text);
                    },
                  ),
                // Quick reply bar
                QuickReplyBar(
                  query: _messageController.text,
                  onSelect: (text) {
                    _messageController.clear();
                    _sendMessage(content: text);
                  },
                  onClose: () {
                    _messageController.clear();
                    setState(() {});
                  },
                ),
                // Input
                _buildInputArea(),
              ],
            ),
          ),
          
          if (_showVideoRecorder)
            VideoMessageRecorder(
              onCancel: () => setState(() => _showVideoRecorder = false),
              onSend: (file) {
                setState(() => _showVideoRecorder = false);
                _sendMediaFile(file, MessageType.videoMessage, 'Video Message');
              },
            ),

          if (_feat.showStickerPicker)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: StickerGifPicker(
                onClose: () => setState(() => _feat.showStickerPicker = false),
                onSelect: (sticker) {
                  setState(() => _feat.showStickerPicker = false);
                  _sendMessage(content: sticker.emoji, type: MessageType.text);
                },
              ),
            ),

          if (_feat.showGiftPicker)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: GiftPickerOverlay(
                balance: ref.watch(starsProvider),
                onClose: () => setState(() => _feat.showGiftPicker = false),
                onSend: (gift, message) {
                  setState(() => _feat.showGiftPicker = false);
                  _sendMessage(
                    content: '🎁 Gift: ${gift.name}${message != null ? '\n"$message"' : ''}',
                    type: MessageType.text, // Could be MessageType.gift if you have one
                  );
                },
              ),
            ),

          if (_feat.showBillSplit)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: BillSplitCreatorOverlay(
                participants: const [{'userId': '1', 'name': 'You'}, {'userId': '2', 'name': 'User'}], // Should be dynamic
                onClose: () => setState(() => _feat.showBillSplit = false),
                onCreated: (title, amount, members) {
                  setState(() => _feat.showBillSplit = false);
                  _sendMessage(
                    content: '💸 Bill Split: $title — ${amount.toStringAsFixed(2)} ETB\nSplit between ${members.length} people',
                    type: MessageType.text, // Could be MessageType.billSplit
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _buildWallpaperBg() {
    return const Color(0xFF0D0A1A);
  }

  BoxDecoration _getWallpaperDecoration() {
    final wp = _feat.chatWallpaper;
    if (wp.isEmpty) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0A1A), Color(0xFF1A0A2A)],
        ),
      );
    }

    if (wp.startsWith('gradient_')) {
      final color = wp == 'gradient_purple' 
          ? const Color(0xFF7C3AED) 
          : wp == 'gradient_blue' 
              ? const Color(0xFF2563EB) 
              : const Color(0xFFDB2777);
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.2), const Color(0xFF0D0A1A)],
        ),
      );
    }

    if (wp == 'stars') {
      return const BoxDecoration(
        color: Color(0xFF0D0A1A),
        image: DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/stardust.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.3,
        ),
      );
    }

    if (wp == 'dots') {
      return const BoxDecoration(
        color: Color(0xFF0D0A1A),
        image: DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/polka-dots.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.1,
        ),
      );
    }

    return const BoxDecoration(color: Color(0xFF0D0A1A));
  }

  PreferredSizeWidget _buildAppBar(dynamic userProfile) {
    final chatsAsync = ref.watch(userChatsStreamProvider);
    final chats = chatsAsync.valueOrNull ?? [];
    final chat = chats.firstWhereOrNull((c) => c.id == widget.chatId);
    final otherId = chat != null
        ? (chat.participant1 == userProfile?.id ? chat.participant2 : chat.participant1)
        : null;
    
    final profileAsync = otherId != null ? ref.watch(profileProvider(otherId)) : null;
    final profile = profileAsync?.valueOrNull;

    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.7),
      elevation: 0,
      flexibleSpace: ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => context.go('/chats'),
      ),
      title: GestureDetector(
        onTap: () => context.push('/profile/${profile?.id}'),
        child: Row(
          children: [
            Stack(
              children: [
                ChatAvatar(src: profile?.avatarUrl, size: 40.0, isOnline: profile?.isOnline ?? false),
                if (_feat.isSecret)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.lock, color: Colors.white, size: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(profile?.name ?? 'User', style: TextStyle(color: _feat.isSecret ? Colors.greenAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      if (profile?.username.toLowerCase().contains('bot') ?? false) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text('BOT', style: TextStyle(color: Colors.blueAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _feat.isSecret ? 'Encrypted Session' : (_typingUsers.isNotEmpty ? 'typing...' : (profile?.isOnline == true ? 'Online' : 'Last seen ${_formatTime(profile?.lastSeen ?? DateTime.now())}')),
                    style: TextStyle(
                      color: _feat.isSecret ? Colors.greenAccent.withOpacity(0.7) : (_typingUsers.isNotEmpty ? AppTheme.primary : (profile?.isOnline == true ? Colors.greenAccent : Colors.white38)),
                      fontSize: 11,
                      fontStyle: _typingUsers.isNotEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (profile?.username.toLowerCase().contains('bot') ?? false)
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
            onPressed: _showSummarizeDialog,
          ),
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: Colors.white),
          onPressed: () {
            if (otherId == null) return;
            ref.read(activeCallProvider.notifier).startCall(
              peerId: otherId,
              name: profile?.name ?? 'User',
              avatar: profile?.avatarUrl,
              type: CallType.video,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: Colors.white),
          onPressed: () {
            if (otherId == null) return;
            ref.read(activeCallProvider.notifier).startCall(
              peerId: otherId,
              name: profile?.name ?? 'User',
              avatar: profile?.avatarUrl,
              type: CallType.voice,
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF1C1130),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onSelected: _onMenuSelected,
          itemBuilder: (_) => _buildMenuItems(),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems() {
    return [
      _menuItem('search', Icons.search, 'Search'),
      _menuItem('wallpaper', Icons.wallpaper, 'Change Wallpaper'),
      _menuItem('theme', Icons.palette, 'Chat Theme'),
      _menuItem('mute', _feat.isMuted ? Icons.volume_up : Icons.volume_off, _feat.isMuted ? 'Unmute' : 'Mute'),
      _menuItem('secret', Icons.lock, _feat.isSecret ? 'Disable Secret Chat' : 'Enable Secret Chat'),
      _menuItem('ghost', Icons.remove_red_eye, _feat.ghostMode ? 'Disable Ghost Mode' : 'Enable Ghost Mode'),
      _menuItem('silent', Icons.notifications_off, _feat.isSilent ? 'Enable Notifications' : 'Silent Mode'),
      _menuItem('lock', _feat.isLocked ? Icons.lock_open : Icons.lock, _feat.isLocked ? 'Unlock Chat' : 'Lock Chat'),
      _menuItem('select', Icons.check_box_outline_blank, _feat.selectMode ? 'Cancel Selection' : 'Select Messages'),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'disappear',
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.timer, color: Colors.white60, size: 18), SizedBox(width: 8), Text('Disappearing', style: TextStyle(color: Colors.white70))]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _timerOptions.map((opt) {
                final isActive = opt['value'] == _feat.disappearingTimer;
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    setState(() => _feat.disappearingTimer = opt['value']!);
                    await _savePref('disappear_${widget.chatId}', opt['value']!);
                    _showSnackBar('Disappearing messages: ${opt['label']}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(opt['label']!, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      _menuItem('scheduled', Icons.schedule, 'Scheduled (${_feat.scheduledCount})'),
      _menuItem('gallery', Icons.photo_library, 'Media Gallery'),
      _menuItem('stats', Icons.bar_chart, 'Chat Stats'),
      _menuItem('export', Icons.download, 'Export Chat'),
      _menuItem('summarize', Icons.summarize, 'Summarize Chat'),
      _menuItem('game', Icons.videogame_asset, 'Send Game'),
      _menuItem('group_call', Icons.video_camera_front, 'Group Call'),
      _menuItem('toggle_voice_banner', Icons.record_voice_over, _feat.isVoiceChatActive ? 'Close Voice Room' : 'Open Voice Room'),
      const PopupMenuDivider(),
      _menuItem('clear', Icons.delete_sweep, 'Clear History', isDestructive: true),
      _menuItem('delete', Icons.delete_forever, 'Delete Chat', isDestructive: true),
    ];
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {bool isDestructive = false}) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: isDestructive ? Colors.redAccent : Colors.white60),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white70, fontSize: 14)),
      ]),
    );
  }

  void _toggleChatLock() async {
    if (_feat.isLocked) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1C1130),
          title: const Text('Unlock Chat', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to remove the lock from this chat?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Unlock', style: TextStyle(color: AppTheme.primary))),
          ],
        ),
      );
      if (confirmed == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('locked_${widget.chatId}', false);
        await prefs.remove('chat_pin_${widget.chatId}');
        setState(() {
          _feat.isLocked = false;
          _feat.correctPinHash = null;
        });
        _showSnackBar('Chat unlocked');
      }
    } else {
      // Setup PIN
      final pinController = TextEditingController();
      final pin = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1C1130),
          title: const Text('Set Chat PIN', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Enter 4-digit PIN', hintStyle: TextStyle(color: Colors.white30)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, pinController.text), child: const Text('Set Lock', style: TextStyle(color: Color(0xFF7C3AED)))),
          ],
        ),
      );

      if (pin != null && pin.length == 4) {
        final hash = SecurityUtils.hashPin(pin);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('locked_${widget.chatId}', true);
        await prefs.setString('chat_pin_${widget.chatId}', hash);
        setState(() {
          _feat.isLocked = true;
          _feat.correctPinHash = hash;
        });
        _showSnackBar('🔒 Chat locked');
      } else if (pin != null) {
        _showSnackBar('PIN must be 4 digits');
      }
    }
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'search': setState(() => _feat.showSearch = !_feat.showSearch); break;
      case 'lock': _toggleChatLock(); break;
      case 'wallpaper': _showWallpaperPicker(); break;
      case 'theme': _showThemePicker(); break;
      case 'mute':
        setState(() => _feat.isMuted = !_feat.isMuted);
        await _savePref('mute_${widget.chatId}', _feat.isMuted);
        _showSnackBar(_feat.isMuted ? 'Chat muted' : 'Chat unmuted');
        break;
      case 'secret':
        setState(() => _feat.isSecret = !_feat.isSecret);
        await _savePref('secret_${widget.chatId}', _feat.isSecret);
        _showSnackBar(_feat.isSecret ? '🔒 Secret chat enabled' : 'Secret chat disabled');
        break;
      case 'ghost':
        setState(() => _feat.ghostMode = !_feat.ghostMode);
        await _savePref('ghost_mode', _feat.ghostMode);
        _showSnackBar(_feat.ghostMode ? '👻 Ghost mode on' : 'Ghost mode off');
        break;
      case 'silent':
        setState(() => _feat.isSilent = !_feat.isSilent);
        await _savePref('silent_${widget.chatId}', _feat.isSilent);
        _showSnackBar(_feat.isSilent ? '🔇 Silent mode on' : 'Silent mode off');
        break;
      case 'select': setState(() { _feat.selectMode = !_feat.selectMode; _feat.selectedMessages.clear(); }); break;
      case 'scheduled': _showScheduledList(); break;
      case 'gallery': _showSnackBar('Media gallery'); break;
      case 'stats': context.push('/chat-stats/${widget.chatId}'); break;
      case 'export': _showExportDialog(); break;
      case 'summarize': _showSummarizeDialog(); break;
      case 'game': _sendGameCard(); break;
      case 'group_call': context.push('/group-call/${widget.chatId}'); break;
      case 'toggle_voice_banner': setState(() => _feat.isVoiceChatActive = !_feat.isVoiceChatActive); break;
      case 'clear': await _clearHistory(); break;
      case 'delete': await _deleteChat(); break;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _sendGameCard() {
    _sendMessage(
      content: '🎮 Space Invaders - High Score: 1,200',
      type: MessageType.text,
      metadata: {'is_game': true, 'game_id': 'space_invaders'}
    );
  }

  void _mockScreenshotDetection() {
    if (_feat.isSecret) {
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && _feat.isSecret) {
          _showSnackBar('⚠️ Screenshot detected in secret chat!');
        }
      });
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1130),
        title: const Text('Export Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Export this chat as a JSON file?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () { Navigator.pop(context); _showSnackBar('Chat exported!'); },
              child: const Text('Export', style: TextStyle(color: Color(0xFF7C3AED)))),
        ],
      ),
    );
  }

  void _showSummarizeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1130),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amberAccent),
            const SizedBox(width: 12),
            const Text('AI Chat Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Here is what you discussed so far:', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            _summaryPoint('Discussed project timelines and milestones.'),
            _summaryPoint('Agreed on the new design language.'),
            _summaryPoint('Set a meeting for next Tuesday at 10 AM.'),
            _summaryPoint('Shared contact info for the marketing team.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Great, Thanks!', style: TextStyle(color: Colors.blueAccent))
          )
        ],
      ),
    );
  }

  Widget _summaryPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.amberAccent, fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildVoiceChatBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: const Border(bottom: BorderSide(color: Colors.green, width: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.activity, color: Colors.green, size: 16),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Voice Chat Active', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                Text('3 participants listening', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.push('/voice-chat/${widget.chatId}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Join', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBars() {
    final hasStatus = _feat.isSecret || _feat.ghostMode || _feat.disappearingTimer != 'off' || _feat.isSilent;
    final hasOffline = !_feat.isNetworkOnline;

    if (!hasStatus && !hasOffline) return const SizedBox.shrink();

    return Column(
      children: [
        if (hasOffline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: Colors.amber.withOpacity(0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.amber, size: 14),
                const SizedBox(width: 6),
                const Text("You're offline — messages will be queued", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        if (hasStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            color: Colors.white.withOpacity(0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_feat.isSecret) ...[const Icon(Icons.lock, color: Colors.white38, size: 12), const SizedBox(width: 4), const Text('Encrypted', style: TextStyle(color: Colors.white38, fontSize: 11)), const SizedBox(width: 12)],
                if (_feat.ghostMode) ...[const Icon(Icons.remove_red_eye, color: Color(0xFF7C3AED), size: 12), const SizedBox(width: 4), const Text('Ghost Mode', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(width: 12)],
                if (_feat.disappearingTimer != 'off') ...[const Icon(Icons.timer, color: Colors.white38, size: 12), const SizedBox(width: 4), Text(_timerOptions.firstWhere((o) => o['value'] == _feat.disappearingTimer, orElse: () => {'label': 'On'})['label']!, style: const TextStyle(color: Colors.white38, fontSize: 11)), const SizedBox(width: 12)],
                if (_feat.isSilent) ...[const Icon(Icons.volume_off, color: Colors.white38, size: 12), const SizedBox(width: 4), const Text('Silent', style: TextStyle(color: Colors.white38, fontSize: 11))],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF150D28),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: _inputDec('Search messages...').copyWith(
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.close, color: Colors.white38), onPressed: () => setState(() { _feat.showSearch = false; _searchController.clear(); _searchQuery = ''; })),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.05),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED))),
              const SizedBox(width: 12),
              Text('Uploading... ${_feat.uploadProgress}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: _feat.uploadProgress / 100, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED))),
        ],
      ),
    );
  }

  Widget _buildPinnedBanner(AsyncValue messagesAsync) {
    final pinnedId = _feat.pinnedMessages.first;
    return GestureDetector(
      onTap: () => _showSnackBar('Jumped to pinned message'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.08),
          border: Border(bottom: BorderSide(color: AppTheme.primary.withOpacity(0.2))),
        ),
        child: Row(
          children: [
            Icon(Icons.push_pin, color: AppTheme.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pinned Message', style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Text('Tap to jump to message', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _feat.pinnedMessages.remove(pinnedId)),
              child: const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectModeBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), border: Border(bottom: BorderSide(color: AppTheme.primary.withOpacity(0.2)))),
      child: Row(
        children: [
          Text('${_feat.selectedMessages.length} selected', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          if (_feat.selectedMessages.isNotEmpty) ...[
            TextButton.icon(
              icon: const Icon(Icons.forward, color: Colors.white70, size: 18),
              label: const Text('Forward', style: TextStyle(color: Colors.white70, fontSize: 13)),
              onPressed: () => _showSnackBar('Forwarding selected messages...'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
              label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              onPressed: () async {
                for (final id in _feat.selectedMessages) { await _deleteMessage(id); }
                setState(() { _feat.selectedMessages.clear(); _feat.selectMode = false; });
              },
            ),
          ],
          IconButton(icon: const Icon(Icons.close, color: Colors.white38, size: 20), onPressed: () => setState(() { _feat.selectMode = false; _feat.selectedMessages.clear(); })),
        ],
      ),
    );
  }

  Widget _buildUndoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), border: Border(bottom: BorderSide(color: AppTheme.primary.withOpacity(0.2)))),
      child: Row(
        children: [
          const Icon(Icons.undo, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          const Text('Message sent', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              if (_feat.pendingUndoId != null) {
                await _deleteMessage(_feat.pendingUndoId!);
                setState(() { _feat.pendingUndo = false; _feat.pendingUndoId = null; });
                _showSnackBar('Message unsent');
              }
            },
            child: Text('UNDO', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPollsArea() {
    return Column(
      children: _polls.where((p) => p['closed'] != true).map((poll) => Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.poll, color: Color(0xFF7C3AED), size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(poll['question'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
              GestureDetector(onTap: () => setState(() => poll['closed'] = true), child: const Icon(Icons.close, color: Colors.white38, size: 16)),
            ]),
            const SizedBox(height: 10),
            ...(poll['options'] as List<String>).map((opt) => GestureDetector(
              onTap: () => _showSnackBar('Voted: $opt'),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.primary.withOpacity(0.2))),
                child: Text(opt, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            )),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildMessages(AsyncValue<List<Message>> messagesAsync, dynamic userProfile) {
    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED))),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      data: (messages) {
        final filtered = _searchQuery.isNotEmpty
            ? messages.where((m) => (m.content ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList()
            : messages;

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white30, size: 40),
                ),
                const SizedBox(height: 16),
                const Text('No messages yet', style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Say hello! 👋', style: TextStyle(color: Colors.white24, fontSize: 13)),
              ],
            ),
          );
        }
        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          itemCount: filtered.length + (_typingUsers.isNotEmpty ? 1 : 0),
          itemBuilder: (_, i) {
            if (_typingUsers.isNotEmpty && i == 0) {
              return _buildTypingIndicator();
            }
            final msg = filtered[i - (_typingUsers.isNotEmpty ? 1 : 0)];
            final isMe = msg.senderId == userProfile?.id;
            
            // Generate smart replies for the last message if it's not from me
            if (i == 0 && !isMe && _smartReplies.isEmpty) {
              _generateSmartReplies(msg);
            }
            
            final isSelected = _feat.selectedMessages.contains(msg.id);

            // Date separator
            Widget? dateSeparator;
            if (i == filtered.length - 1 || _isDifferentDay(filtered[i], filtered[i + 1])) {
              dateSeparator = _buildDateSeparator(msg.createdAt);
            }

            return Column(
              children: [
                if (dateSeparator != null) dateSeparator,
                GestureDetector(
                  onLongPress: () {
                    if (!_feat.selectMode) _showMessageContextMenu(msg, isMe);
                  },
                  onTap: _feat.selectMode ? () => setState(() {
                    if (isSelected) _feat.selectedMessages.remove(msg.id);
                    else _feat.selectedMessages.add(msg.id);
                  }) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_feat.selectMode)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? AppTheme.primary : Colors.white24, size: 22),
                          ),
                        Expanded(child: _buildMessageItem(msg, isMe, userProfile)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          const TypingDots(),
          const SizedBox(width: 8),
          Text(
            _typingUsers.length > 1 ? '${_typingUsers.length} people are typing...' : '${_typingUsers[0]} is typing...',
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  bool _isDifferentDay(Message a, Message b) {
    return a.createdAt.day != b.createdAt.day || a.createdAt.month != b.createdAt.month;
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      label = 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      label = 'Yesterday';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 0.5, color: Colors.white12)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(20)),
            child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Container(height: 0.5, color: Colors.white12)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message msg, bool isMe, dynamic userProfile) {
    // Handle special message types
    if (msg.metadata?['type'] == 'game') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GameCard(
          title: msg.metadata!['title']!,
          subtitle: msg.metadata!['subtitle']!,
          imageUrl: msg.metadata!['image']!,
          onPlay: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Launching game...'))),
        ),
      );
    }
    if ((msg.content ?? '').startsWith('[location:')) {
      return _buildLocationMessage(msg, isMe);
    }
    if ((msg.content ?? '').startsWith('[sticker:')) {
      return _buildStickerMessage(msg, isMe);
    }
    return ChatBubble(
      message: msg,
      isMe: isMe,
      onAction: (action, m) => _handleMessageAction(action, m),
      searchQuery: _searchQuery,
      translatedText: _feat.translations[msg.id],
      bubbleColor: _feat.chatBubbleColor.isNotEmpty
          ? Color(int.parse(_feat.chatBubbleColor.replaceFirst('#', '0xFF')))
          : null,
      isPinned: _feat.pinnedMessages.contains(msg.id),
    );
  }

  Widget _buildLocationMessage(Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primary.withOpacity(0.85) : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.location_on, color: Colors.redAccent, size: 16), SizedBox(width: 6), Text('Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))]),
            const SizedBox(height: 8),
            Container(
              width: 200, height: 100,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white12),
              child: const Center(child: Text('📍 Map preview', style: TextStyle(color: Colors.white38, fontSize: 12))),
            ),
            const SizedBox(height: 6),
            const Text('Tap to open in Maps', style: TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerMessage(Message msg, bool isMe) {
    final emoji = (msg.content ?? '').replaceAll('[sticker:', '').replaceAll(']', '');
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Text(emoji, style: const TextStyle(fontSize: 48)),
      ),
    );
  }

  void _showMessageContextMenu(Message msg, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150D28),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            // Preview
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Text((msg.content ?? '').length > 100 ? '${(msg.content ?? '').substring(0, 100)}...' : (msg.content ?? ''), style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                _ctxBtn(Icons.reply, 'Reply', () { Navigator.pop(context); setState(() => _replyToMessage = msg); }),
                _ctxBtn(Icons.copy, 'Copy', () { Navigator.pop(context); Clipboard.setData(ClipboardData(text: msg.content ?? '')); _showSnackBar('Copied'); }),
                _ctxBtn(Icons.forward, 'Forward', () { Navigator.pop(context); _forwardMessage(msg); }),
                _ctxBtn(Icons.push_pin, _feat.pinnedMessages.contains(msg.id) ? 'Unpin' : 'Pin', () { Navigator.pop(context); _pinMessage(msg); }),
                if (isMe) _ctxBtn(Icons.edit, 'Edit', () { Navigator.pop(context); setState(() { _editingMessage = msg; _messageController.text = msg.content ?? ''; }); }),
                _ctxBtn(Icons.check_box_outline_blank, 'Select', () { Navigator.pop(context); setState(() { _feat.selectMode = true; _feat.selectedMessages.add(msg.id); }); }),
                _ctxBtn(Icons.timer, 'Set Timer', () { Navigator.pop(context); _showSnackBar('Per-message timer set'); }),
                _ctxBtn(Icons.notifications, 'Remind Me', () { Navigator.pop(context); _showSnackBar('Reminder set for this message'); }),
                if (isMe) _ctxBtn(Icons.delete, 'Delete', () { Navigator.pop(context); _deleteMessage(msg.id); }, isDestructive: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctxBtn(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: isDestructive ? Colors.redAccent.withOpacity(0.1) : Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
              border: Border.all(color: isDestructive ? Colors.redAccent.withOpacity(0.3) : Colors.white12),
            ),
            child: Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white60, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  void _handleMessageAction(String action, Message msg) {
    switch (action) {
      case 'reply': setState(() => _replyToMessage = msg); break;
      case 'copy': Clipboard.setData(ClipboardData(text: msg.content ?? '')); _showSnackBar('Copied'); break;
      case 'translate': _translateMessage(msg); break;
      case 'forward': _forwardMessage(msg); break;
      case 'pin': _pinMessage(msg); break;
      case 'delete': _deleteMessage(msg.id); break;
      case 'edit': setState(() { _editingMessage = msg; _messageController.text = msg.content ?? ''; }); break;
      case 'view_once_open': _openViewOnce(msg); break;
    }
  }

  Future<void> _openViewOnce(Message msg) async {
    // Show a dialog or simply reveal it for 10 seconds
    _showSnackBar('👁️ Message revealed for 10 seconds');
    // Update local state to show it
    setState(() {
      msg.metadata!['viewed'] = false; // Just to ensure it's not expired yet
      msg.metadata!['revealed'] = true;
    });
    
    Future.delayed(const Duration(seconds: 10), () async {
      await Supabase.instance.client
          .from('messages')
          .update({
            'metadata': {...?msg.metadata, 'viewed': true, 'revealed': false}
          })
          .eq('id', msg.id);
      if (mounted) setState(() {});
    });
  }

  Future<void> _translateMessage(Message msg) async {
    if (msg.content == null) return;
    try {
      final result = await TranslationService().translate(msg.content!);
      setState(() {
        _feat.translations[msg.id] = result;
      });
    } catch (e) {
      _showSnackBar('Translation failed: $e');
    }
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(left: BorderSide(color: AppTheme.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reply to message', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 2),
                Text(_replyToMessage?.content ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.white38, size: 16), onPressed: () => setState(() => _replyToMessage = null)),
        ],
      ),
    );
  }

  void _showStickerPicker() => setState(() => _feat.showStickerPicker = true);

  void _generateSmartReplies(Message msg) {
    if (msg.messageType != MessageType.text || msg.content == null) return;
    final content = msg.content!.toLowerCase();
    
    List<String> suggestions = [];
    if (content.contains('hello') || content.contains('ሰላም')) {
      suggestions = ['Hi!', 'Hey there', 'ሰላም ነው?'];
    } else if (content.contains('how are you') || content.contains('እንዴት ነህ')) {
      suggestions = ['I am good, thanks!', 'Doing great!', 'ደህና ነኝ'];
    } else if (content.contains('where')) {
      suggestions = ['I am at home', 'On my way', 'በቅርብ ነኝ'];
    } else if (content.contains('ok') || content.contains('እሺ')) {
      suggestions = ['Great', 'Cool', 'መልካም'];
    } else {
      suggestions = ['Ok', 'Yes', 'No', 'Talk later'];
    }

    // Delay slightly to feel natural
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _smartReplies = suggestions);
    });
  }

  Widget _buildInputArea() {
    final isEditing = _editingMessage != null;
    return Container(
      padding: EdgeInsets.fromLTRB(6, 8, 6, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0A1A).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                border: Border(left: BorderSide(color: Colors.amber, width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.amber, size: 14),
                  const SizedBox(width: 8),
                  const Text('Editing message', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(onTap: () => setState(() { _editingMessage = null; _messageController.clear(); }), child: const Icon(Icons.close, color: Colors.white38, size: 16)),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.white.withOpacity(0.6), size: 26),
                onPressed: _showAttachmentSheet,
              ),
              // Sticker / emoji button
              IconButton(
                icon: Icon(Icons.emoji_emotions_outlined, color: Colors.white.withOpacity(0.5), size: 24),
                onPressed: _showStickerPicker,
              ),
              // Input field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: isEditing ? 'Edit message...' : 'Message...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: isEditing
                        ? (t) => _editMessage(_editingMessage!.id, t)
                        : (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send / Mic
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _messageController.text.trim().isNotEmpty
                    ? GestureDetector(
                        key: const ValueKey('send'),
                        onLongPress: () => _showSendMenu(context),
                        child: GestureDetector(
                          onTap: () {
                            if (isEditing) {
                              _editMessage(_editingMessage!.id, _messageController.text.trim());
                            } else {
                              _sendMessage();
                            }
                          },
                          child: Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 12)],
                            ),
                            child: Icon(isEditing ? Icons.check : Icons.send, color: Colors.white, size: 20),
                          ),
                        ),
                      )
                    : GestureDetector(
                        key: const ValueKey('mic'),
                        onLongPress: _showVoiceRecorder,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic_none, color: Colors.white60, size: 22),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
