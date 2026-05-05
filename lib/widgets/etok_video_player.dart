import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class EtokVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool play;
  final VoidCallback? onLike;

  const EtokVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.play = false,
    this.onLike,
  });

  @override
  State<EtokVideoPlayer> createState() => _EtokVideoPlayerState();
}

class _EtokVideoPlayerState extends State<EtokVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _showControls = false;
  bool _isMuted = false;
  bool _showHeart = false;
  double _heartOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      if (mounted) {
        setState(() => _initialized = true);
        if (widget.play) _controller!.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  void _handleDoubleTap() {
    setState(() {
      _showHeart = true;
      _heartOpacity = 0.8;
    });
    
    widget.onLike?.call();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _heartOpacity = 0.0;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showHeart = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(EtokVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play != oldWidget.play) {
      if (widget.play) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (widget.thumbnailUrl != null)
            Image.network(widget.thumbnailUrl!, fit: BoxFit.cover),
          const Center(child: CircularProgressIndicator(color: Colors.white24)),
        ],
      );
    }

    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (info.visibleFraction < 0.5 && _controller!.value.isPlaying) {
          _controller?.pause();
        } else if (info.visibleFraction > 0.5 && widget.play) {
          _controller?.play();
        }
      },
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        onTap: () {
          setState(() {
            _showControls = !_showControls;
            _isMuted = !_isMuted;
            _controller?.setVolume(_isMuted ? 0 : 1);
          });
          if (_controller!.value.isPlaying) {
            _controller?.pause();
          } else {
            _controller?.play();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
            // Double Tap Heart Overlay
            if (_showHeart)
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _heartOpacity,
                  child: const Icon(Icons.favorite, color: Colors.white, size: 100),
                ),
              ),
            // Mute Indicator
            if (_isMuted)
              const Positioned(
                top: 20,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: Icon(Icons.volume_off, color: Colors.white, size: 20),
                ),
              ),
            if (!_controller!.value.isPlaying)
              const Center(
                child: Icon(Icons.play_arrow, size: 80, color: Colors.white54),
              ),
            // Progress Bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFFFF0050),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
