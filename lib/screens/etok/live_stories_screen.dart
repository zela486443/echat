import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class LiveStoriesScreen extends StatelessWidget {
  const LiveStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated Story Image/Video background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF000000)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Text('Story Content Area', style: TextStyle(color: Colors.white54)),
            ),
          ),
          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Progress and User info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Progress Bars
                      Row(
                        children: [
                          Expanded(child: Container(height: 3, color: Colors.white, margin: const EdgeInsets.only(right: 4))),
                          Expanded(child: Container(height: 3, color: Colors.white.withOpacity(0.3), margin: const EdgeInsets.only(right: 4))),
                          Expanded(child: Container(height: 3, color: Colors.white.withOpacity(0.3))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // User Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.gradientAurora.colors.last,
                            child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Alex Smith', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('2h ago', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bottom Reply Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Text('Send message...', style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite_outline, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      const Icon(Icons.send, color: Colors.white, size: 28),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
