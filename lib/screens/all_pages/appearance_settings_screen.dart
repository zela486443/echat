import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../providers/theme_provider.dart';
import '../../theme/app_locales.dart';

import '../../providers/appearance_provider.dart';

class AppearanceSettingsScreen extends ConsumerStatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  ConsumerState<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends ConsumerState<AppearanceSettingsScreen> {
  bool _isDarkMode = true;
  String _selectedWallpaper = 'Default';

  final List<String> _wallpapers = ['Default', 'Classic', 'Galaxy', 'Bubbles', 'Art', 'Minimal'];

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(themeProvider);
    final bubbleStyle = ref.watch(bubbleStyleProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
        title: Text(ref.tr('appearance'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildLivePreview(accent, bubbleStyle, fontSize),
          
          _buildSectionHeader(ref.tr('theme_accent').toUpperCase()),
          _buildGroup([
            _buildToggleRow(
              icon: _isDarkMode ? LucideIcons.moon : LucideIcons.sun,
              iconBg: Colors.indigo,
              label: ref.tr('dark_mode'),
              sub: 'Switch between light and dark',
              value: _isDarkMode,
              onChanged: (v) => setState(() => _isDarkMode = v),
              activeColor: accent.color,
            ),
          ]),

          const SizedBox(height: 16),
          _buildAccentColorPicker(accent),
          
          _buildSectionHeader(ref.tr('chat_settings').toUpperCase()),
          _buildGroup([
            _buildActionRow(
              icon: LucideIcons.image,
              iconBg: Colors.teal,
              label: 'Chat Wallpaper',
              sub: _selectedWallpaper,
              onTap: _showWallpaperPicker,
            ),
            _buildDivider(),
            _buildBubbleStylePicker(bubbleStyle, accent.color),
            _buildDivider(),
            _buildFontSizeSlider(accent.color, fontSize),
          ]),
          
          _buildSectionHeader(ref.tr('language').toUpperCase()),
          _buildGroup([
            _buildLanguageOption('English', 'en', ref.watch(localeProvider) == 'en'),
            _buildDivider(),
            _buildLanguageOption('Amharic (አማርኛ)', 'am', ref.watch(localeProvider) == 'am'),
          ]),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLivePreview(AccentColor accent, BubbleStyle style, double fontSize) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF150D28).withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=500&q=80'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Column(
        children: [
          _buildBubble('Hey! How is the new update? 🚀', false, style, accent.color, fontSize),
          const SizedBox(height: 12),
          _buildBubble('It looks amazing! The design is so smooth.', true, style, accent.color, fontSize),
        ],
      ),
    ).animate().fadeIn().scale(delay: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildBubble(String text, bool isMe, BubbleStyle style, Color accent, double fontSize) {
    BorderRadius radius;
    switch (style) {
      case BubbleStyle.round:
        radius = BorderRadius.circular(20);
        break;
      case BubbleStyle.sharp:
        radius = BorderRadius.zero;
        break;
      case BubbleStyle.glass:
        radius = BorderRadius.circular(16);
        break;
      default: // modern
        radius = BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        decoration: BoxDecoration(
          color: isMe ? accent : Colors.white.withOpacity(0.1),
          borderRadius: radius,
          border: style == BubbleStyle.glass ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
          boxShadow: isMe ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF150D28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(children: children),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16);
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String sub,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color activeColor,
  }) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconBg, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: activeColor),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required Color iconBg,
    required String label,
    required String sub,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: iconBg.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconBg, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
    );
  }

  Widget _buildAccentColorPicker(AccentColor current) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF150D28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Accent Color', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: availableAccents.map((accent) {
                final isSelected = current.id == accent.id;
                return GestureDetector(
                  onTap: () => ref.read(themeProvider.notifier).setAccent(accent),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: accent.color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      boxShadow: isSelected ? [BoxShadow(color: accent.color.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)] : null,
                    ),
                    child: isSelected ? const Icon(LucideIcons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleStylePicker(BubbleStyle current, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bubble Style', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: BubbleStyle.values.map((style) {
              final isSelected = style == current;
              return GestureDetector(
                onTap: () => ref.read(bubbleStyleProvider.notifier).setStyle(style),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? accent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? accent : Colors.transparent),
                  ),
                  child: Text(
                    style.name.toUpperCase(),
                    style: TextStyle(color: isSelected ? accent : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSizeSlider(Color accent, double current) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Text Size', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('${current.toInt()}px', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Slider(
            value: current,
            min: 12, max: 22, divisions: 5,
            activeColor: accent,
            inactiveColor: Colors.white.withOpacity(0.05),
            onChanged: (v) => ref.read(fontSizeProvider.notifier).setFontSize(v),
          ),
        ],
      ),
    );
  }

  void _showWallpaperPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF150D28),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Chat Wallpaper', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.7),
              itemCount: _wallpapers.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () { setState(() => _selectedWallpaper = _wallpapers[i]); Navigator.pop(context); },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selectedWallpaper == _wallpapers[i] ? ref.watch(themeProvider).color : Colors.white.withOpacity(0.1), width: 2),
                    image: DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1534796636912-3b95b3ab5986?w=200&q=60'), fit: BoxFit.cover, opacity: 0.3),
                  ),
                  child: Center(child: Text(_wallpapers[i], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String name, String code, bool isSelected) {
    return ListTile(
      title: Text(name, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? Icon(LucideIcons.check, color: ref.watch(themeProvider).color, size: 18) : null,
      onTap: () => ref.read(localeProvider.notifier).state = code,
    );
  }
}
