import 'dart:async';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // Simple mock translation logic
  Future<String> translate(String text, {String targetLanguage = 'en'}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Simple mock translations for demonstration
    final lower = text.toLowerCase();
    
    if (lower.contains('ሰላም')) return 'Hello / Peace';
    if (lower.contains('እንዴት ነህ')) return 'How are you?';
    if (lower.contains('ደህና')) return 'Fine / Good';
    if (lower.contains('አመሰግናለሁ')) return 'Thank you';
    if (lower.contains('አዎ')) return 'Yes';
    if (lower.contains('አይ')) return 'No';
    if (lower.contains('ምንድን ነው')) return 'What is it?';
    
    // If English, translate to Amharic (mock)
    if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      if (lower.contains('hello')) return 'ሰላም';
      if (lower.contains('how are you')) return 'እንዴት ነህ?';
      if (lower.contains('thank you')) return 'አመሰግናለሁ';
      return '[Amharic Translation of: $text]';
    }

    return '[English Translation of: $text]';
  }
}
