import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404', style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Oops! Page not found', style: TextStyle(color: Colors.white38, fontSize: 18)),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => context.go('/'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)), child: const Text('Return to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}
