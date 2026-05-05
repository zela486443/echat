import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'dart:async';

class IndexScreen extends ConsumerStatefulWidget {
  const IndexScreen({super.key});

  @override
  ConsumerState<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends ConsumerState<IndexScreen> with TickerProviderStateMixin {
  late AnimationController _ringController;
  late AnimationController _progressController;
  late AnimationController _blobController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))..repeat();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _blobController = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);

    _progressController.forward().then((_) {
      if (mounted) context.go('/auth');
    });
  }

  @override
  void dispose() {
    _ringController.dispose();
    _progressController.dispose();
    _blobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0812),
      body: Stack(
        alignment: Alignment.center,
        children: [
          _buildBlobs(),
          _buildRings(),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildBlobs() {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 100 + (_blobController.value * 20),
              left: 50 + (_blobController.value * 15),
              child: _buildBlob(const Color(0xFF7C3AED).withOpacity(0.12), 260),
            ),
            Positioned(
              bottom: 120 - (_blobController.value * 15),
              right: 40 + (_blobController.value * 20),
              child: _buildBlob(Colors.purple.withOpacity(0.1), 220),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildRings() {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [240.0, 200.0, 160.0].map((size) {
            final idx = [240.0, 200.0, 160.0].indexOf(size);
            final progress = (_ringController.value + (idx * 0.2)) % 1.0;
            return Container(
              width: size * (1 + (progress * 0.4)),
              height: size * (1 + (progress * 0.4)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.6 * (1 - progress)), width: 1),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogo(),
        const SizedBox(height: 40),
        const Text('Echats', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
        const SizedBox(height: 8),
        const Text('Fast · Secure · Beautiful', style: TextStyle(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 60),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110, height: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6D28D9).withOpacity(0.5), blurRadius: 40, offset: const Offset(0, 15)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(LucideIcons.messageSquare, color: Colors.white, size: 54),
          Positioned(
            top: -10, right: -10,
            child: Icon(LucideIcons.sparkles, color: Colors.white.withOpacity(0.3), size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: 180, height: 4,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(2)),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 180 * _progressController.value,
              height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: const Color(0xFF6D28D9).withOpacity(0.5), blurRadius: 4)],
              ),
            ),
          );
        },
      ),
    );
  }
}
