import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AuroraGradientBg extends StatefulWidget {
  final Widget child;

  const AuroraGradientBg({super.key, required this.child});

  @override
  State<AuroraGradientBg> createState() => _AuroraGradientBgState();
}

class _AuroraGradientBgState extends State<AuroraGradientBg> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Hero Gradient
        Container(
          decoration: BoxDecoration(
             gradient: AppTheme.gradientHero,
          ),
        ),
        // Animated Aurora Blobs (Simulated)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
             return Stack(
               children: [
                 Positioned(
                   top: -100 + (_controller.value * 50),
                   left: -50,
                   child: Container(
                     width: 300,
                     height: 300,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: AppTheme.primary.withOpacity(0.15),
                       boxShadow: [
                         BoxShadow(
                           color: AppTheme.primary.withOpacity(0.15),
                           blurRadius: 100,
                           spreadRadius: 50,
                         ),
                       ]
                     ),
                   )
                 ),
                 Positioned(
                   bottom: -150 - (_controller.value * 50),
                   right: -100,
                   child: Container(
                     width: 400,
                     height: 400,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: const Color(0xFFB143F4).withOpacity(0.1),
                       boxShadow: [
                         BoxShadow(
                           color: const Color(0xFFB143F4).withOpacity(0.1),
                           blurRadius: 120,
                           spreadRadius: 60,
                         ),
                       ]
                     ),
                   )
                 ),
               ],
             );
          },
        ),
        // Safe Area content over the background
        SafeArea(child: widget.child),
      ],
    );
  }
}
