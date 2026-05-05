import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GameCardWidget extends StatelessWidget {
  final Map<String, dynamic> gameData;

  const GameCardWidget({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(child: Icon(LucideIcons.gamepad2, size: 48, color: Colors.indigo)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gameData['title'] ?? 'Play Tic Tac Toe', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {}, // Deep link or open native game view
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                  child: const Text('Play Now'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DrawingCanvasCardWidget extends StatelessWidget {
  final String imageUrl;

  const DrawingCanvasCardWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          height: 200,
          width: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200, width: 250, color: Colors.grey.shade800,
            child: const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      ),
    );
  }
}
