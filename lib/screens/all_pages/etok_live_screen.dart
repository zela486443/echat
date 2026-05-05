import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EtokLiveScreen extends StatefulWidget {
  final String streamerName;
  const EtokLiveScreen({super.key, required this.streamerName});

  @override
  State<EtokLiveScreen> createState() => _EtokLiveScreenState();
}

class _EtokLiveScreenState extends State<EtokLiveScreen> {
  final List<String> _comments = [
    'Wow, amazing!',
    'Hello from Addis!',
    'Love the quality!',
    'Can you show the setup?',
    '🔥🔥🔥',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Video/Camera (Mock)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage('https://picsum.photos/400/800?random=live'), fit: BoxFit.cover),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent, Colors.black.withOpacity(0.4)]),
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: Colors.white24, child: Text(widget.streamerName[0])),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.streamerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          const Text('LIVE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.visibility, color: Colors.white70, size: 10),
                          const SizedBox(width: 4),
                          const Text('1.2K', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
          ),

          // Comments
          Positioned(
            bottom: 100,
            left: 16,
            right: 80,
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                reverse: true,
                itemCount: _comments.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 12, backgroundColor: Colors.white10, child: Icon(Icons.person, size: 12, color: Colors.white24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _comments[index],
                          style: const TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
                    child: const TextField(
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(hintText: 'Say something...', hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildActionIcon(Icons.card_giftcard, Colors.orange),
                const SizedBox(width: 12),
                _buildActionIcon(Icons.favorite, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.5))),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
