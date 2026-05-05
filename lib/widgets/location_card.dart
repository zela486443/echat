import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

class LocationCard extends StatelessWidget {
  final Map<String, dynamic> locationData;
  final bool isMe;

  const LocationCard({super.key, required this.locationData, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              image: DecorationImage(
                image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=${locationData['lat']},${locationData['lng']}&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7Clabel:S%7C${locationData['lat']},${locationData['lng']}&key=YOUR_API_KEY'),
                fit: BoxFit.cover,
                onError: (_, __) => const Icon(LucideIcons.mapPin, color: Colors.white24, size: 40),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.mapPin, color: Color(0xFF7C3AED), size: 16),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shared Location', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('View on Maps', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
