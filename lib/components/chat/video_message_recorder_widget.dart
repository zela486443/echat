import 'package:flutter/material.dart';

class VideoMessageRecorderWidget extends StatelessWidget {
  const VideoMessageRecorderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.blueGrey.shade900,
            child: const Center(child: Text('CAMERA FEED', style: TextStyle(color: Colors.white54))),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 32), onPressed: () => Navigator.pop(context)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.redAccent, width: 4)),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                ),
                IconButton(icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32), onPressed: () {}),
              ],
            ),
          ),
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text('00:00', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}
