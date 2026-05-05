import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';

class LocationPickerScreen extends StatelessWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Share Location', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Map Placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(image: DecorationImage(image: NetworkImage('https://picsum.photos/400/800?random=map'), fit: BoxFit.cover)),
            child: Center(
              child: Icon(Icons.location_on, color: AppTheme.primary, size: 48),
            ),
          ),

          // Bottom Card
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: GlassmorphicContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.my_location, color: Colors.white, size: 20)),
                    title: Text('Current Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('Addis Ababa, Ethiopia', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  const Divider(color: Colors.white10),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.share, color: Colors.white, size: 20)),
                    title: Text('Share Live Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('For 1 hour, 8 hours...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Send This Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
