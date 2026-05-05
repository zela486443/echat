import 'package:flutter/material.dart';

class StoriesBarWidget extends StatelessWidget {
  const StoriesBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Maps StoriesBar.tsx
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 10,
        itemBuilder: (context, index) {
          final isMine = index == 0;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade800,
                      child: Icon(isMine ? Icons.add : Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(isMine ? 'My Story' : 'User $index', style: const TextStyle(fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}
