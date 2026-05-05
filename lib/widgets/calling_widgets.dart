import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedSoundWave extends StatefulWidget {
  final bool active;
  const AnimatedSoundWave({super.key, this.active = true});

  @override
  State<AnimatedSoundWave> createState() => _AnimatedSoundWaveState();
}

class _AnimatedSoundWaveState extends State<AnimatedSoundWave> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final List<double> _amps = [0.6, 1.0, 0.8, 1.2, 0.7, 1.0, 0.5];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(7, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (i * 70)),
      )..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(7, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (context, child) {
              double h = 4 + (_controllers[i].value * 16 * _amps[i]);
              double opacity = widget.active ? (0.4 + (_controllers[i].value * 0.5)) : 0.25;
              return Container(
                width: 3,
                height: widget.active ? h : 4,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class AnimatedSignalBars extends StatelessWidget {
  final String status;
  const AnimatedSignalBars({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool good = status == 'inCall' || status == 'connected';
    final bool mid = status == 'connecting' || status == 'outgoing';
    
    return SizedBox(
      height: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (i) {
          Color barColor;
          if (good) {
            barColor = i < 4 ? const Color(0xFF10B981).withOpacity(0.9) : Colors.white.withOpacity(0.2);
          } else if (mid) {
            barColor = i < 2 ? const Color(0xFFFBBF24).withOpacity(0.9) : Colors.white.withOpacity(0.2);
          } else {
            barColor = const Color(0xFFF87171).withOpacity(0.9);
          }

          return Container(
            width: 3,
            height: 3.0 + (i * 2.5),
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}

class PulsatingRing extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double delay;

  const PulsatingRing({
    super.key,
    required this.size,
    required this.color,
    this.duration = const Duration(seconds: 3),
    this.delay = 0,
  });

  @override
  State<PulsatingRing> createState() => _PulsatingRingState();
}

class _PulsatingRingState extends State<PulsatingRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.7, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.color.withOpacity(0.2)),
                color: widget.color.withOpacity(0.05),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedStatusDot extends StatefulWidget {
  final Color color;
  const AnimatedStatusDot({super.key, required this.color});

  @override
  State<AnimatedStatusDot> createState() => _AnimatedStatusDotState();
}

class _AnimatedStatusDotState extends State<AnimatedStatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + (_controller.value * 0.6),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}

class AuroraBackground extends StatelessWidget {
  final Widget? child;
  final List<AuroraBlob> blobs;

  const AuroraBackground({super.key, this.child, required this.blobs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF050510),
            Color(0xFF080D1E),
            Color(0xFF050510),
          ],
        ),
      ),
      child: Stack(
        children: [
          ...blobs.map((b) => _MovingBlob(blob: b)),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class AuroraBlob {
  final Alignment begin;
  final Alignment end;
  final double size;
  final Color color;
  final Duration duration;

  AuroraBlob({
    required this.begin,
    required this.end,
    required this.size,
    required this.color,
    required this.duration,
  });
}

class _MovingBlob extends StatefulWidget {
  final AuroraBlob blob;
  const _MovingBlob({required this.blob});

  @override
  State<_MovingBlob> createState() => _MovingBlobState();
}

class _MovingBlobState extends State<_MovingBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.blob.duration)..repeat(reverse: true);
    _alignment = AlignmentTween(begin: widget.blob.begin, end: widget.blob.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _alignment,
      builder: (context, child) {
        return Align(
          alignment: _alignment.value,
          child: Container(
            width: widget.blob.size,
            height: widget.blob.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [widget.blob.color, Colors.transparent]),
            ),
          ),
        );
      },
    );
  }
}
