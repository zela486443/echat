import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Dark Theme Colors (Based on WebApp index.css) ---
  static final Color background = HSLColor.fromAHSL(1.0, 222.0, 0.22, 0.07).toColor();
  static final Color foreground = HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.96).toColor();
  
  static final Color card = HSLColor.fromAHSL(1.0, 222.0, 0.20, 0.10).toColor();
  static final Color cardForeground = HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.96).toColor();
  
  static final Color popover = HSLColor.fromAHSL(1.0, 222.0, 0.20, 0.11).toColor();
  static final Color popoverForeground = HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.96).toColor();
  
  static Color primary = const Color(0xFFF44A8C); // hsl(338 90% 67%)
  static Color primaryForeground = const Color(0xFFFFFFFF);
  static Color primaryGlow = const Color(0xFFF994BC); // hsl(338 90% 74%)
  
  static final Color secondary = HSLColor.fromAHSL(1.0, 222.0, 0.18, 0.14).toColor();
  static final Color secondaryForeground = HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.90).toColor();
  
  static final Color muted = HSLColor.fromAHSL(1.0, 222.0, 0.18, 0.13).toColor();
  static final Color mutedForeground = HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.55).toColor();
  
  static Color accent = const Color(0xFFFF0050);
  static Color accentForeground = const Color(0xFFFFFFFF);
  
  static final Color destructive = HSLColor.fromAHSL(1.0, 0.0, 0.68, 0.58).toColor();
  static final Color destructiveForeground = HSLColor.fromAHSL(1.0, 0.0, 0.0, 1.00).toColor();
  
  static final Color border = HSLColor.fromAHSL(1.0, 222.0, 0.18, 0.17).toColor();
  static final Color input = HSLColor.fromAHSL(1.0, 222.0, 0.18, 0.14).toColor();
  static Color ring = const Color(0xFFFF0050);
  
  // Chat specific
  static final Color chatBubbleIncoming = HSLColor.fromAHSL(1.0, 222.0, 0.18, 0.16).toColor();
  static Color chatBubbleOutgoing = const Color(0xFFFF0050);
  static final Color chatBubbleTextIncoming = HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.92).toColor();
  static final Color chatBubbleTextOutgoing = HSLColor.fromAHSL(1.0, 0.0, 0.0, 1.00).toColor();

  // Status and Misc
  static final Color statusOnline = HSLColor.fromAHSL(1.0, 145.0, 0.65, 0.50).toColor();
  static final Color statusAway = HSLColor.fromAHSL(1.0, 45.0, 1.00, 0.55).toColor();
  static final Color statusOffline = HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.45).toColor();
  static final Color readReceipt = HSLColor.fromAHSL(1.0, 210.0, 1.00, 0.62).toColor();

  // --- Gradients ---
  static LinearGradient gradientPrimary(Color p) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [p, p.withOpacity(0.8)],
  );

  static final LinearGradient gradientAurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFFF44A8C), // Primary Pink
      const Color(0xFF7C3AED), // Secondary Purple
      const Color(0xFF2563EB), // Blue
      const Color(0xFF10B981), // Green
    ],
  );

  static final LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xFF0D0A1A),
      const Color(0xFF151122),
    ],
  );

  static final List<BoxShadow> shadowPrimary = [
    BoxShadow(color: const Color(0xFFF44A8C).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
  ];

  static final List<BoxShadow> shadowGlowSm = [
    BoxShadow(color: const Color(0xFFF44A8C).withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
  ];

  static ThemeData getTheme(Color accentColor) {
    primary = accentColor;
    accent = accentColor;
    ring = accentColor;
    chatBubbleOutgoing = accentColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        background: background,
        onBackground: foreground,
        primary: primary,
        onPrimary: primaryForeground,
        secondary: secondary,
        onSecondary: secondaryForeground,
        surface: card,
        onSurface: cardForeground,
        error: destructive,
        onError: destructiveForeground,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      cardColor: card,
      dividerColor: border,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: mutedForeground,
      ),
    );
  }
}
