import 'package:flutter/material.dart';

class EchatsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const EchatsCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }
}

class EchatsAvatar extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double radius;

  const EchatsAvatar({super.key, this.imageUrl, required this.fallbackText, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.indigo.shade800,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null 
        ? Text(fallbackText[0].toUpperCase(), style: TextStyle(color: Colors.white, fontSize: radius * 0.8))
        : null,
    );
  }
}

class EchatsBadge extends StatelessWidget {
  final String text;
  final Color color;

  const EchatsBadge({super.key, required this.text, this.color = Colors.indigo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
