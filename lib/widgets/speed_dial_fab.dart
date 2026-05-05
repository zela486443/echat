import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SpeedDialFAB extends StatefulWidget {
  const SpeedDialFAB({super.key});

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          _buildActionButton(
            icon: LucideIcons.shieldAlert,
            label: 'New Secret Chat',
            onTap: () => context.push('/chats/secret'),
            index: 4,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: LucideIcons.sparkles,
            label: 'New AI Chat',
            onTap: () => context.push('/chats/ai'),
            index: 3,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: LucideIcons.messageSquare,
            label: 'New Message',
            onTap: () => context.push('/chats/new'),
            index: 2,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: LucideIcons.users,
            label: 'New Group',
            onTap: () => context.push('/groups/new'),
            index: 1,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            icon: LucideIcons.qrCode,
            label: 'Scan QR',
            onTap: () => context.push('/scan-qr'),
            index: 0,
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isExpanded ? Icons.add : LucideIcons.plus, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int index,
  }) {
    return FadeTransition(
      opacity: _expandAnimation,
      child: ScaleTransition(
        scale: _expandAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            FloatingActionButton.small(
              heroTag: 'fab_$index',
              onPressed: () {
                _toggle();
                onTap();
              },
              backgroundColor: const Color(0xFF2A2A2A),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
