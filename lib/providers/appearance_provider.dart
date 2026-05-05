import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BubbleStyle { round, modern, sharp, glass }

final bubbleStyleProvider = StateNotifierProvider<BubbleStyleNotifier, BubbleStyle>((ref) {
  return BubbleStyleNotifier();
});

class BubbleStyleNotifier extends StateNotifier<BubbleStyle> {
  BubbleStyleNotifier() : super(BubbleStyle.modern) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('chat_bubble_style') ?? 1;
    state = BubbleStyle.values[index];
  }

  Future<void> setStyle(BubbleStyle style) async {
    state = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chat_bubble_style', style.index);
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(14.0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble('chat_font_size') ?? 14.0;
  }

  Future<void> setFontSize(double size) async {
    state = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('chat_font_size', size);
  }
}
