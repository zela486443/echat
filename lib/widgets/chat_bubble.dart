import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../models/message.dart';
import '../theme/app_theme.dart';
import '../providers/appearance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_poll_card.dart';
import 'round_video_message.dart';
import 'message_actions_overlay.dart';
import 'location_card.dart';
import 'bill_split_card.dart';
import 'checklist_card.dart';
import 'link_preview_card.dart';
import 'chat/gift_message_bubble.dart';
import '../screens/chat/media_viewer_screen.dart';

class ChatBubble extends ConsumerWidget {
  final Message message;
  final bool isMe;
  final Function(String action, Message message)? onAction;
  final Color? bubbleColor;
  final bool isPinned;
  final String searchQuery;
  final String? translatedText;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onAction,
    this.bubbleColor,
    this.isPinned = false,
    this.searchQuery = '',
    this.translatedText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(bubbleStyleProvider);
    final fontSize = ref.watch(fontSizeProvider);

    if (message.messageType == MessageType.sticker) {
      return _buildStickerContent();
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showReactionPicker(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: style == BubbleStyle.glass
                ? Colors.white.withOpacity(0.1)
                : isMe
                    ? (bubbleColor != null ? bubbleColor! : AppTheme.primary)
                    : AppTheme.card.withOpacity(0.8),
            borderRadius: _getBorderRadius(style),
            border: style == BubbleStyle.glass 
                ? Border.all(color: Colors.white.withOpacity(0.15))
                : (isPinned ? Border.all(color: Colors.amber.withOpacity(0.6), width: 1.5) : null),
            boxShadow: [
              if (isMe && style != BubbleStyle.glass)
                BoxShadow(
                  color: (bubbleColor ?? AppTheme.primary).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _buildMessageContent(context, fontSize),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('h:mm a').format(message.createdAt.toLocal()),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),
              if (message.reactions.isNotEmpty) _buildReactionsRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReactionsRow() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: message.reactions.map((r) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(r.emoji, style: const TextStyle(fontSize: 12)),
        )).toList(),
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) => MessageActionsOverlay(
          message: message,
          isMe: isMe,
          messageOffset: offset,
          messageSize: size,
          onAction: (action, msg) {
            Navigator.pop(context);
            onAction?.call(action, msg);
          },
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, double fontSize) {
    // Check for "View Once" expired
    final bool isViewOnce = message.metadata?['view_once'] == true;
    final bool hasBeenViewed = message.metadata?['viewed'] == true;
    
    if (isViewOnce && hasBeenViewed) {
      return _buildViewOnceExpired();
    }

    switch (message.messageType) {
      case MessageType.image:
        return _buildImageContent(context);
      case MessageType.file:
        return _buildFileContent(context);
      case MessageType.voice:
        return _buildVoiceContent();
      case MessageType.videoMessage:
        return RoundVideoMessage(videoUrl: message.mediaUrl ?? '', isMe: isMe);
      case MessageType.poll:
        return ChatPollCard(pollData: _parseJson(message.content), isMe: isMe);
      case MessageType.location:
        return LocationCard(locationData: _parseJson(message.content), isMe: isMe);
      case MessageType.billSplit:
        return BillSplitCard(billData: _parseJson(message.content), isMe: isMe);
      case MessageType.checklist:
        return ChecklistCard(checklistData: _parseJson(message.content), isMe: isMe);
      case MessageType.gift:
        return _buildGiftBubble();
      case MessageType.text:
      default:
        // Handle Secret/View-Once covers
        if (isViewOnce && !isMe) {
          return _buildViewOnceCover();
        }
        if (searchQuery.isNotEmpty && (message.content ?? '').toLowerCase().contains(searchQuery.toLowerCase())) {
          return Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _buildHighlightedText(message.content ?? '', fontSize),
              if (translatedText != null) ...[
                const SizedBox(height: 4),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 4),
                Text(
                  translatedText!,
                  style: TextStyle(color: Colors.white70, fontSize: fontSize * 0.9, fontStyle: FontStyle.italic),
                ),
              ],
              _buildLinkPreview(message.content ?? ''),
            ],
          );
        }
        return Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content ?? '',
              style: TextStyle(color: Colors.white, fontSize: fontSize),
            ),
            if (translatedText != null) ...[
              const SizedBox(height: 4),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 4),
              Text(
                translatedText!,
                style: TextStyle(color: Colors.white70, fontSize: fontSize * 0.9, fontStyle: FontStyle.italic),
              ),
            ],
            _buildLinkPreview(message.content ?? ''),
          ],
        );
    }
  }

  BorderRadius _getBorderRadius(BubbleStyle style) {
    switch (style) {
      case BubbleStyle.round:
        return BorderRadius.circular(20);
      case BubbleStyle.sharp:
        return BorderRadius.zero;
      case BubbleStyle.glass:
        return BorderRadius.circular(16);
      default: // modern
        return BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        );
    }
  }

  Widget _buildViewOnceCover() {
    return GestureDetector(
      onTap: () => onAction?.call('view_once_open', message),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.visibility_off, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Text('Tap to view message', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildViewOnceExpired() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_off_outlined, color: Colors.white24, size: 16),
        const SizedBox(width: 8),
        Text('Expired view-once message', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13)),
      ],
    );
  }

  Widget _buildStickerContent() {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 140,
        height: 140,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          image: DecorationImage(image: CachedNetworkImageProvider(message.mediaUrl ?? ''), fit: BoxFit.contain)
        ),
      ),
    );
  }

  Widget _buildGiftBubble() {
    return GiftMessageBubble(
      message: message,
      isMe: isMe,
    );
  }

  Map<String, dynamic> _parseJson(String? content) {
    if (content == null) return {};
    try {
      if (content.startsWith('{')) return jsonDecode(content);
      return {'content': content};
    } catch (_) {
      return {'error': content};
    }
  }

  Widget _buildImageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerScreen(url: message.mediaUrl ?? ''))),
          child: Hero(
            tag: message.mediaUrl ?? '',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: message.mediaUrl ?? '',
                placeholder: (context, url) => Container(
                  height: 200,
                  width: 250,
                  color: Colors.white10,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        if (message.content != null && message.content!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4),
            child: Text(
              message.content!,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
      ],
    );
  }

  Widget _buildFileContent(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerScreen(url: message.mediaUrl ?? '', fileName: message.fileName))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.white, size: 30),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Text('View Document', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          child: Icon(Icons.play_arrow, color: isMe ? Colors.white : Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Row(
          children: List.generate(15, (index) {
            final height = (index % 3 + 1) * 6.0;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: height,
              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(2)),
            );
          }),
        ),
        const SizedBox(width: 12),
        const Text('0:12', style: TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const Icon(Icons.access_time, size: 12, color: Colors.white54);
      case MessageStatus.sent:
        return const Icon(Icons.check, size: 12, color: Colors.white54);
      case MessageStatus.delivered:
        return const Icon(Icons.done_all, size: 12, color: Colors.white54);
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 12, color: Colors.blueAccent);
    }
  }

  Widget _buildHighlightedText(String text, double fontSize) {
    final String lowerText = text.toLowerCase();
    final String lowerQuery = searchQuery.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;

    while ((indexOfHighlight = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfHighlight)));
      }
      spans.add(TextSpan(
        text: text.substring(indexOfHighlight, indexOfHighlight + searchQuery.length),
        style: TextStyle(backgroundColor: Colors.yellow.withOpacity(0.4), color: Colors.white, fontWeight: FontWeight.bold),
      ));
      start = indexOfHighlight + searchQuery.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white, fontSize: fontSize),
        children: spans,
      ),
    );
  }

  Widget _buildLinkPreview(String text) {
    final url = _detectUrl(text);
    if (url == null) return const SizedBox.shrink();

    // Mock OG metadata - in a real app, this would be fetched from Supabase Edge Function
    String title = 'Link Preview';
    String description = 'Tap to open this link in your browser.';
    String domain = Uri.parse(url).host;

    if (url.contains('github.com')) {
      title = 'GitHub: Let\'s build from here';
      description = 'GitHub is where over 100 million developers shape the future of software, together.';
    } else if (url.contains('google.com')) {
      title = 'Google';
      description = 'Search the world\'s information, including webpages, images, videos and more.';
    } else if (url.contains('youtube.com')) {
      title = 'YouTube';
      description = 'Enjoy the videos and music you love, upload original content, and share it all with friends.';
    }

    return LinkPreviewCard(
      url: url,
      title: title,
      description: description,
      domain: domain,
      imageUrl: 'https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=400&auto=format&fit=crop', // Generic gradient placeholder
    );
  }

  String? _detectUrl(String text) {
    final RegExp urlRegExp = RegExp(
      r'((?:https?:\/\/|www\.)[^\s/$.?#].[^\s]*)',
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text);
    if (match != null) {
      String url = match.group(0)!;
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      return url;
    }
    return null;
  }
}
