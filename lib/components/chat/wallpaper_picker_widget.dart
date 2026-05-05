import 'package:flutter/material.dart';

class WallpaperPickerWidget extends StatelessWidget {
  const WallpaperPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.brown, Colors.pink, Colors.grey];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Wallpaper'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors[index % colors.length].withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
                childCount: colors.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}
