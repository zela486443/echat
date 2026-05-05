import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    ));

    _animations = _controllers.map((c) => Tween<double>(begin: 0, end: -5.0).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    )).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _animations[i],
        builder: (context, child) => Container(
          width: 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          transform: Matrix4.translationValues(0, _animations[i].value, 0),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.3 + (0.7 * (1.0 + _animations[i].value / 5.0))),
            shape: BoxShape.circle,
          ),
        ),
      )),
    );
  }
}
