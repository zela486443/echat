import 'package:flutter/material.dart';

class StickerGifPicker extends StatelessWidget {
  const StickerGifPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.emoji_emotions)),
                Tab(icon: Icon(Icons.gif)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemCount: 16,
                    itemBuilder: (context, index) => const Center(child: Icon(Icons.star, color: Colors.amber, size: 32)),
                  ),
                  GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: 12,
                    itemBuilder: (context, index) => Container(color: Colors.grey.shade300, child: const Center(child: Text('GIF'))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
