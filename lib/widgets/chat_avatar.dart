import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatAvatar extends StatelessWidget {
  final String? src;
  final String? name;
  final dynamic size; // Supports double or String ('sm', 'md', 'lg')
  final bool isOnline;
  final bool isVerified;

  const ChatAvatar({
    super.key,
    this.src,
    this.name,
    this.size = 40.0,
    this.isOnline = false,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    double radius;
    double fontSize;

    if (size is String) {
      switch (size) {
        case 'xs': radius = 12; fontSize = 10; break;
        case 'sm': radius = 18; fontSize = 14; break;
        case 'lg': radius = 32; fontSize = 24; break;
        case 'xl': radius = 64; fontSize = 40; break;
        case 'md':
        default: radius = 24; fontSize = 18; break;
      }
    } else {
      radius = (size as double) / 2;
      fontSize = radius * 0.8;
    }

    final initials = (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : '?';

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.indigo.withOpacity(0.2),
          backgroundImage: src != null && src!.isNotEmpty 
              ? CachedNetworkImageProvider(src!) 
              : null,
          child: src == null || src!.isEmpty
              ? Text(initials, style: TextStyle(color: Colors.white70, fontSize: fontSize, fontWeight: FontWeight.bold))
              : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
          ),
        if (isVerified)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 10),
            ),
          ),
      ],
    );
  }
}
