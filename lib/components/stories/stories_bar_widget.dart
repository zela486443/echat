import 'package:flutter/material.dart';

class StoriesBarWidget extends StatelessWidget {
  const StoriesBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isMine = index == 0;
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isMine ? null : const LinearGradient(colors: [Colors.purple, Colors.orange]),
                        border: isMine ? Border.all(color: Colors.grey.shade300, width: 2) : null,
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.person, color: Colors.grey.shade400, size: 32),
                      ),
                    ),
                    if (isMine)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 4),
                Text(isMine ? 'My Story' : 'User $index', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}
