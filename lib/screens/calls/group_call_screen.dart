import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class GroupCallScreen extends StatelessWidget {
  final String groupId;
  const GroupCallScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated 4-way Video Grid
          Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Container(color: Colors.blueGrey, child: const Center(child: Icon(Icons.person, size: 60, color: Colors.white)))),
                    Expanded(child: Container(color: Colors.grey.shade800, child: const Center(child: Icon(Icons.person, size: 60, color: Colors.white)))),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Container(color: Colors.teal.shade900, child: const Center(child: Icon(Icons.person, size: 60, color: Colors.white)))),
                    Expanded(child: Container(color: Colors.brown.shade800, child: const Center(child: Icon(Icons.person, size: 60, color: Colors.white)))),
                  ],
                ),
              ),
            ],
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32), onPressed: () => context.pop()),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: const BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.all(Radius.circular(16))),
                        child: const Text('04:23', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      IconButton(icon: const Icon(Icons.person_add, color: Colors.white), onPressed: () {}),
                    ],
                  ),
                ),
                
                // Bottom Call Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCallBtn(Icons.cameraswitch, Colors.white24, Colors.white),
                      _buildCallBtn(Icons.videocam, Colors.white24, Colors.white),
                      _buildCallBtn(Icons.mic, Colors.white24, Colors.white),
                      _buildCallBtn(Icons.call_end, Colors.redAccent, Colors.white, onTap: () => context.pop()),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCallBtn(IconData icon, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
