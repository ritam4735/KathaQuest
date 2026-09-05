import 'package:flutter/material.dart';

class AppTheme {
  // Royal Indian & Mythological Palette
  static const Color royalPurple = Color(0xFF4A154B);
  static const Color royalPurpleDark = Color(0xFF2C0B2D);
  static const Color royalPurpleLight = Color(0xFF6B2D6D);

  static const Color templeGold = Color(0xFFFFD166);
  static const Color templeGoldDark = Color(0xFFD4A310);
  static const Color saffron = Color(0xFFFF9F1C);
  static const Color saffronDark = Color(0xFFE07A5F);

  static const Color emerald = Color(0xFF00C853);
  static const Color emeraldLight = Color(0xFF69F0AE);
  static const Color emeraldDark = Color(0xFF1B5E20);

  static const Color peacockTeal = Color(0xFF00897B);
  static const Color peacockBlue = Color(0xFF0288D1);

  // Parchment & Stone Canvas
  static const Color parchment = Color(0xFFFFF8E7);
  static const Color parchmentLight = Color(0xFFFFFDF5);
  static const Color parchmentBorder = Color(0xFFE5D5B5);
  static const Color parchmentDark = Color(0xFFEADBC0);

  static const Color textDark = Color(0xFF3E2723);
  static const Color textMedium = Color(0xFF5D4037);
  static const Color textLight = Color(0xFF8D6E63);

  // Backward-compatible aliases for all screens & minigames
  static const Color primary = saffron;
  static const Color primaryDark = royalPurple;
  static const Color secondary = peacockTeal;
  static const Color surface = parchmentLight;
  static const Color surfaceMuted = parchmentDark;
  static const Color sunshine = templeGold;
  static const Color gold = templeGold;
  static const Color accent = saffronDark;

  // Gradients
  static const LinearGradient purpleCrestGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5D1A5E), Color(0xFF380E39)],
  );

  static const LinearGradient goldPillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE082), Color(0xFFFFC107), Color(0xFFFFA000)],
  );

  static const LinearGradient emeraldPillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF69F0AE), Color(0xFF00E676), Color(0xFF00C853)],
  );

  static const LinearGradient saffronPillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFB74D), Color(0xFFFF9800), Color(0xFFF57C00)],
  );

  static const LinearGradient parchmentPillGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFBF0), Color(0xFFF5E8CB)],
  );

  static const LinearGradient sunnyGradient = goldPillGradient;
  static const LinearGradient peacockGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [peacockTeal, peacockBlue],
  );

  static const List<String> fontFallbacks = [
    'NotoSansDevanagari',
    'NotoSerifDevanagari',
  ];

  static ThemeData get royalTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: parchment,
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalPurple,
        primary: royalPurple,
        secondary: saffron,
        surface: parchmentLight,
      ),
      fontFamily: 'serif',
      fontFamilyFallback: fontFallbacks,
      textTheme: const TextTheme().apply(
        fontFamilyFallback: fontFallbacks,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'serif',
          fontFamilyFallback: fontFallbacks,
        ),
      ),
    );
  }

  static ThemeData get lightTheme => royalTheme;

  // Ornate Parchment Card Decoration with Filigree Border
  static BoxDecoration ornateParchmentDecoration({
    Color backgroundColor = parchmentLight,
    Color borderColor = parchmentBorder,
    double radius = 22,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF3E2723).withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration kidCardDecoration({
    Color color = parchmentLight,
    Color borderColor = parchmentBorder,
    double radius = 22,
    Color shadowColor = const Color(0x14000000),
  }) {
    return ornateParchmentDecoration(
      backgroundColor: color,
      borderColor: borderColor,
      radius: radius,
    );
  }

  // 3D Tactile Pill Button Decoration
  static BoxDecoration tactilePillDecoration({
    required Gradient gradient,
    required Color borderColor,
    Color shadowColor = const Color(0x33000000),
    double radius = 26,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: gradient,
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: Colors.white60,
          blurRadius: 0,
          offset: Offset(0, -1),
        ),
      ],
    );
  }

  static BoxDecoration tactileButtonDecoration({
    required Color topColor,
    required Color bottomColor,
    double radius = 22,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [topColor, bottomColor],
      ),
      boxShadow: [
        BoxShadow(
          color: bottomColor.withOpacity(0.6),
          offset: const Offset(0, 5),
          blurRadius: 0,
        ),
      ],
    );
  }
}
