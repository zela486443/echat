import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class DataStorageSettingsScreen extends StatefulWidget {
  const DataStorageSettingsScreen({super.key});

  @override
  State<DataStorageSettingsScreen> createState() => _DataStorageSettingsScreenState();
}

class _DataStorageSettingsScreenState extends State<DataStorageSettingsScreen> {
  bool autoDownloadPhotos = true;
  bool autoDownloadVideos = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Data & Storage', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Storage Used', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('4.2 GB', style: TextStyle(color: theme.colorScheme.primary, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface),
                  child: Text('Clear Cache', style: TextStyle(color: theme.colorScheme.onSurface)),
                )
              ],
            ),
          ),
          LinearProgressIndicator(value: 0.6, backgroundColor: theme.colorScheme.surface, valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary)),
          
          _buildSectionHeader('Automatic Media Download'),
          SwitchListTile(
            value: autoDownloadPhotos,
            onChanged: (val) => setState(() => autoDownloadPhotos = val),
            title: const Text('Photos'),
            subtitle: const Text('Wi-Fi and Cellular'),
            activeColor: theme.colorScheme.primary,
          ),
          SwitchListTile(
            value: autoDownloadVideos,
            onChanged: (val) => setState(() => autoDownloadVideos = val),
            title: const Text('Videos'),
            subtitle: const Text('Wi-Fi only'),
            activeColor: theme.colorScheme.primary,
          ),
          
          _buildSectionHeader('Call Settings'),
          ListTile(
            title: const Text('Use Less Data for Calls'),
            trailing: Switch(value: false, onChanged: (val) {}, activeColor: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(title.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
