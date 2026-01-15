import 'package:flutter/material.dart';

class OakeyTheme {
  // 1. 브랜드 컬러 (Brand Colors)
  static const Color primaryDeep = Color(0xFF4E342E);    // Primary (딥 브라운)
  static const Color primarySoft = Color(0xFF8D786F);    // Secondary (웜 브라운)
  static const Color accentOrange = Color(0xFFB35D1E);   // Point 1 (강조 오렌지)
  static const Color accentGold = Color(0xFFE6BE5A);     // Point 2 (포인트 골드)

  static const Color backgroundMain = Color(0xFFF8F5F2); // Background (베이지 배경)
  static const Color surfacePure = Color(0xFFFFFFFF);    // Surface 1 (순백색 카드)
  static const Color surfaceMuted = Color(0xFFEEE6DE);   // Surface 2 (연베이지 섹션)
  static const Color borderLine = Color(0xFFDED3C9);     // Divider (구분선/테두리)

  static const Color statusSuccess = Color(0xFF556B2F);  // Success (올리브 그린)
  static const Color statusError = Color(0xFFA3433B);    // Error (딥 레드)

  static const Color textMain = Color(0xFF212121);       // Text-Primary (진한 차콜)
  static const Color textSub = Color(0xFF666666);        // Text-Secondary (중간 그레이)
  static const Color textHint = Color(0xFF9E9E9E);       // Text-Tertiary (힌트용 그레이)
  static const Color textWhite = Color(0xFFFFFFFF);      // Text-On-Primary (밝은 텍스트)

  // 2. 전역 그림자 스타일 (Shadow)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryDeep.withOpacity(0.06), // 은은한 브라운 섀도우
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // 3. 전체 테마 데이터 (ThemeData)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundMain,
      fontFamily: 'Pretendard',

      // 텍스트 위계 설정 (Typography)
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

      // 공통 버튼 스타일 (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeep,
          foregroundColor: textWhite,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // 입력창 테마 (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePure,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryDeep),
        ),
        hintStyle: const TextStyle(color: textHint, fontWeight: FontWeight.w400),
      ),
    );
  }
}