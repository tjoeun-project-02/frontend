import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OakeyTheme {
  // 앱 전역 스크롤 설정 main.dart 연결용
  static final ScrollBehavior globalScrollBehavior =
      const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      );

  // 디자인 수치 정의
  static const double _rXS = 6.0;
  static const double _rS = 14.0;
  static const double _rM = 12.0;
  static const double _rL = 20.0;
  static const double _rXL = 40.0;

  // 모서리 둥글기 객체
  static final BorderRadius radiusXS = BorderRadius.circular(_rXS);
  static final BorderRadius radiusS = BorderRadius.circular(_rS);
  static final BorderRadius radiusM = BorderRadius.circular(_rM);
  static final BorderRadius radiusL = BorderRadius.circular(_rL);
  static final BorderRadius radiusXL = BorderRadius.circular(_rXL);

  // 바텀시트용 상단 둥글기
  static final BorderRadius radiusTopXL = BorderRadius.vertical(
    top: Radius.circular(_rXL),
  );

  // 여백 크기 정의
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // 색상 팔레트
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

  // 텍스트 스타일 프리셋
  static const TextStyle textTitleXL = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: textMain,
  );
  static const TextStyle textTitleL = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textMain,
  );
  static const TextStyle textTitleM = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textMain,
  );

  static const TextStyle textBodyL = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textMain,
  );
  static const TextStyle textBodyM = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textMain,
  );
  static const TextStyle textBodyS = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSub,
  );

  static const TextStyle textBtn = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textWhite,
  );

  // 세로 간격 박스
  static const SizedBox boxV_XS = SizedBox(height: spacingXS);
  static const SizedBox boxV_S = SizedBox(height: spacingS);
  static const SizedBox boxV_M = SizedBox(height: spacingM);
  static const SizedBox boxV_L = SizedBox(height: spacingL);
  static const SizedBox boxV_XL = SizedBox(height: spacingXL);

  // 가로 간격 박스
  static const SizedBox boxH_XS = SizedBox(width: spacingXS);
  static const SizedBox boxH_S = SizedBox(width: spacingS);
  static const SizedBox boxH_M = SizedBox(width: spacingM);

  // 컨테이너 스타일 프리셋
  static final BoxDecoration decoCard = BoxDecoration(
    color: surfacePure,
    borderRadius: radiusL,
    border: Border.all(color: borderLine),
    boxShadow: [
      BoxShadow(
        color: primaryDeep.withOpacity(0.06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static final BoxDecoration decoTag = BoxDecoration(
    color: surfaceMuted,
    borderRadius: radiusXS,
  );

  // 버튼 스타일 프리셋
  static final ButtonStyle btnPrimary = ElevatedButton.styleFrom(
    backgroundColor: primaryDeep,
    foregroundColor: textWhite,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: radiusM),
    elevation: 0,
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  static final ButtonStyle btnSecondary = ElevatedButton.styleFrom(
    backgroundColor: surfaceMuted,
    foregroundColor: textMain,
    minimumSize: const Size(double.infinity, 56),
    shape: RoundedRectangleBorder(borderRadius: radiusM),
    elevation: 0,
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  // 입력창 스타일 생성 함수
  static InputDecoration inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: surfacePure,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textHint, fontSize: 16),
      border: _outlineBorder(borderLine),
      enabledBorder: _outlineBorder(borderLine),
      focusedBorder: _outlineBorder(primaryDeep, width: 1.5),
      errorBorder: _outlineBorder(statusError),
    );
  }

  // 테두리 스타일 생성 헬퍼
  static OutlineInputBorder _outlineBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: radiusM,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // 공통 토스트 메시지 함수
  static void showToast(String title, String message, {bool isError = false}) {
    if (Get.context == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? statusError.withOpacity(0.95)
          : primaryDeep.withOpacity(0.95),
      colorText: textWhite,
      margin: const EdgeInsets.all(20),
      borderRadius: _rM,
      duration: const Duration(seconds: 2),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: textWhite,
      ),
    );
  }

  // 앱 전체 테마 설정
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: backgroundMain,

      colorScheme: const ColorScheme.light(
        primary: primaryDeep,
        secondary: primarySoft,
        surface: surfacePure,
        background: backgroundMain,
        error: statusError,
        onPrimary: textWhite,
        onSurface: textMain,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(style: btnPrimary),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfacePure,
        border: _outlineBorder(borderLine),
      ),

      cardTheme: CardThemeData(
        color: surfacePure,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusL,
          side: const BorderSide(color: borderLine),
        ),
      ),
    );
  }
}
