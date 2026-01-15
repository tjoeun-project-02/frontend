import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

/// 1. 버튼 스타일 종류 (딥브라운, 연베이지, 테두리)
enum OakeyButtonType { primary, secondary, outline }

/// 2. 버튼 사이즈 종류 (전체화면용, 중간용, 작은등록용)
enum OakeyButtonSize { large, medium, small }

class OakeyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final OakeyButtonType type;
  final OakeyButtonSize size;
  final double? width;

  const OakeyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = OakeyButtonType.primary,
    this.size = OakeyButtonSize.large,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // 사이즈별 높이와 폰트 설정
    double height;
    double fontSize;
    double borderRadius = 16; // 전체적인 미니멀 곡률

    switch (size) {
      case OakeyButtonSize.large:
        height = 58;
        fontSize = 16;
        break;
      case OakeyButtonSize.medium:
        height = 46;
        fontSize = 14;
        break;
      case OakeyButtonSize.small:
        height = 34;
        fontSize = 12;
        borderRadius = 10; // 작은 버튼은 곡률도 살짝 작게
        break;
    }

    return SizedBox(
      width: width ?? (size == OakeyButtonSize.large ? double.infinity : null),
      height: height,
      child: _buildButton(fontSize, borderRadius),
    );
  }

  Widget _buildButton(double fontSize, double borderRadius) {
    final textStyle = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700);

    // Outline 스타일 (중복확인 등)
    if (type == OakeyButtonType.outline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: OakeyTheme.primaryDeep,
          side: const BorderSide(color: OakeyTheme.borderLine),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: Text(text, style: textStyle),
      );
    }

    // Primary & Secondary 스타일
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: type == OakeyButtonType.primary
            ? OakeyTheme.primaryDeep
            : OakeyTheme.surfaceMuted,
        foregroundColor: type == OakeyButtonType.primary
            ? OakeyTheme.textWhite
            : OakeyTheme.primaryDeep,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
      child: Text(text, style: textStyle),
    );
  }
}

/// 3. 태그(Tag/Chip) 위젯
/// 상세페이지의 'Honey', 'Vanilla' 또는 지역명에 사용
class OakeyTag extends StatelessWidget {
  final String label;
  final bool isSelected; // 선택된 상태인지 여부 (필터 등에서 사용)

  const OakeyTag({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? OakeyTheme.primaryDeep : OakeyTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? OakeyTheme.textWhite : OakeyTheme.accentOrange, // 주황색 포인트 반영
        ),
      ),
    );
  }
}