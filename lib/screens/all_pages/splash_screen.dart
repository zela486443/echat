import 'package:flutter/material.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Splash'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AuroraGradientBg(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphicContainer(
              isStrong: true,
              child: const Center(
                child: Text('Splash content will be placed here', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
