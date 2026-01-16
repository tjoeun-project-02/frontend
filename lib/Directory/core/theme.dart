import 'package:flutter/material.dart';

class OakeyTheme {
  // Brand colors
  static const Color primaryDeep = Color(0xFF4E342E);
  static const Color primarySoft = Color(0xFF8D786F);
  static const Color accentOrange = Color(0xFFB35D1E);
  static const Color accentGold = Color(0xFFE6BE5A);

  static const Color backgroundMain = Color(0xFFF8F5F2);
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEE6DE);
  static const Color borderLine = Color(0xFFDED3C9);

  static const Color statusSuccess = Color(0xFF556B2F);
  static const Color statusError = Color(0xFFA3433B);

  static const Color textMain = Color(0xFF212121);
  static const Color textSub = Color(0xFF666666);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Radius tokens
  static const double radiusS = 10;
  static const double radiusM = 16;
  static const double radiusL = 18;

  // Card shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryDeep.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Light theme
  static ThemeData get lightTheme {
    // Color scheme
    final ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryDeep,
      onPrimary: textWhite,
      secondary: primarySoft,
      onSecondary: textWhite,
      error: statusError,
      onError: textWhite,
      surface: surfacePure,
      onSurface: textMain,
      background: backgroundMain,
      onBackground: textMain,
    );

    return ThemeData(
      // Material 3 base
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundMain,
      fontFamily: 'Pretendard',

      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: textMain,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textMain,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textSub,
          letterSpacing: 0.5,
        ),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundMain,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfacePure,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(color: borderLine),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: borderLine,
        thickness: 1,
        space: 1,
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeep,
          foregroundColor: textWhite,
          minimumSize: const Size(double.infinity, 58),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDeep,
          side: const BorderSide(color: borderLine),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: primaryDeep,
        disabledColor: surfaceMuted,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusS),
          side: BorderSide.none,
        ),
      ),

      // TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePure,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: borderLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: borderLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: const BorderSide(color: primaryDeep),
        ),
        hintStyle: const TextStyle(
          color: textHint,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
