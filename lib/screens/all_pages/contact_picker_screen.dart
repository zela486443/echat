import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';

class ContactPickerScreen extends StatefulWidget {
  const ContactPickerScreen({super.key});

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  final List<Map<String, String>> _contacts = [
    {'name': 'Abebe B.', 'phone': '+251 911 223 344'},
    {'name': 'Melat V.', 'phone': '+251 922 556 677'},
    {'name': 'Zola X.', 'phone': '+251 933 889 900'},
    {'name': 'Tigist W.', 'phone': '+251 944 112 233'},
    {'name': 'Abel T.', 'phone': '+251 955 445 566'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Share Contact', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphicContainer(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.white24),
                  SizedBox(width: 12),
                  Text('Search contacts...', style: TextStyle(color: Colors.white24, fontSize: 14)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final c = _contacts[index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.primary.withOpacity(0.2), child: Text(c['name']![0], style: const TextStyle(color: Colors.white))),
                  title: Text(c['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(c['phone']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  onTap: () => Navigator.pop(context, c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
