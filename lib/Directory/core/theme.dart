import 'package:flutter/material.dart';

class OakeyTheme {
  // 브랜드 메인 컬러
  static const Color primaryDeep = Color(0xFF4E342E);
  static const Color primarySoft = Color(0xFF8D786F);
  static const Color accentOrange = Color(0xFFB35D1E);
  static const Color accentGold = Color(0xFFE6BE5A);

  // 앱 배경 및 기본 표면 색상
  static const Color backgroundMain = Color(0xFFF8F5F2);
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEEE6DE);
  static const Color borderLine = Color(0xFFDED3C9);

  // 상태 표현 색상
  static const Color statusSuccess = Color(0xFF556B2F);
  static const Color statusError = Color(0xFFA3433B);

  // 텍스트 색상
  static const Color textMain = Color(0xFF212121);
  static const Color textSub = Color(0xFF666666);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);

  // 모서리 반경 수치
  static const double radiusXS = 6;
  static const double radiusS = 14;
  static const double radiusM = 20;
  static const double radiusL = 25;
  static const double radiusXL = 40;

  // 태그용 모서리 스타일
  static BorderRadius get brTag => BorderRadius.circular(radiusXS);

  // 버튼용 모서리 스타일
  static BorderRadius get brBtn => BorderRadius.circular(radiusS);

  // 카드용 모서리 스타일
  static BorderRadius get brCard => BorderRadius.circular(radiusL);

  // 패널 및 모달용 모서리 스타일
  static BorderRadius get brPanel => BorderRadius.circular(radiusXL);

  // 폰트 크기 기준 값
  static const double fontSizeXS = 10;
  static const double fontSizeS = 12;
  static const double fontSizeM = 16;
  static const double fontSizeL = 20;
  static const double fontSizeXL = 26;

  // 공통 카드 그림자 스타일
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryDeep.withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // 앱 전체 라이트 테마 설정
  static ThemeData get lightTheme {
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
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundMain,
      fontFamily: 'Pretendard',

      // 전역 텍스트 스타일
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textMain,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textMain,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSub,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSub,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textHint,
        ),
      ),

      // 전역 구분선 스타일
      dividerTheme: const DividerThemeData(
        color: borderLine,
        thickness: 1,
        space: 1,
      ),

      // 상단 앱바 기본 스타일
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundMain,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),

      // 전역 카드 스타일
      cardTheme: CardThemeData(
        color: surfacePure,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: brCard,
          side: const BorderSide(color: borderLine),
        ),
      ),

      // 전역 기본 버튼 스타일
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeep,
          foregroundColor: textWhite,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(borderRadius: brBtn),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),

      // 전역 칩 및 태그 스타일
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        selectedColor: primaryDeep,
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
        shape: RoundedRectangleBorder(borderRadius: brTag),
      ),

      // 전역 입력창 스타일
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePure,
        hintStyle: const TextStyle(
          color: textHint,
          fontSize: fontSizeM,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
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
      ),
    );
  }
}
