import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class NearbyPeopleScreen extends StatelessWidget {
  const NearbyPeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> nearby = [
      {'name': 'Julia', 'distance': '100m away', 'color': Colors.pink},
      {'name': 'Mark', 'distance': '450m away', 'color': Colors.blue},
      {'name': 'Daniel', 'distance': '1.2km away', 'color': Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('People Nearby', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.radar, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                const Text('Discover People Nearby', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Make yourself visible to find new friends around you.',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Make Myself Visible', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: nearby.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final p = nearby[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (p['color'] as Color).withOpacity(0.2),
                    child: Icon(Icons.person, color: p['color']),
                  ),
                  title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p['distance']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
