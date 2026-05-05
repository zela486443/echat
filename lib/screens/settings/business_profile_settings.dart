import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class BusinessProfileSettingsScreen extends StatelessWidget {
  const BusinessProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Business Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () {}, child: Text('Save', style: TextStyle(color: theme.colorScheme.primary))),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  CircleAvatar(radius: 64, backgroundColor: Colors.grey.shade200, child: const Icon(Icons.business, size: 64, color: Colors.grey)),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
            _buildInputField(context, 'Business Name', 'e.g. Echats Coffee'),
            _buildInputField(context, 'Description', 'What does your business do?', maxLines: 3),
            _buildInputField(context, 'Address', '123 Business St.'),
            _buildInputField(context, 'Category', 'e.g. Retail, Food, Services'),
            _buildInputField(context, 'Business Hours', 'Mon-Fri 9AM-5PM'),
            _buildInputField(context, 'Website', 'https://'),
            
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.blueAccent),
              title: const Text('Auto-Reply Messages'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Colors.purple),
              title: const Text('Business Analytics'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
