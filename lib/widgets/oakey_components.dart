import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

enum OakeyButtonType { primary, secondary, outline }

enum OakeyButtonSize { large, medium, small }

// 공통 버튼 위젯
class OakeyButton extends StatelessWidget {
  // 버튼 기본 텍스트
  final String? text;

  // 버튼 클릭 이벤트
  final VoidCallback? onPressed;

  // 버튼 스타일 타입
  final OakeyButtonType type;

  // 버튼 사이즈 타입
  final OakeyButtonSize size;

  // 버튼 너비 지정
  final double? width;

  // 로딩 상태 여부
  final bool isLoading;

  // 버튼 내부 커스텀 위젯
  final Widget? child;

  const OakeyButton({
    super.key,
    this.text,
    required this.onPressed,
    this.type = OakeyButtonType.primary,
    this.size = OakeyButtonSize.large,
    this.width,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final _ButtonSizeSpec spec = _getSizeSpec(size);
    final bool disabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? (size == OakeyButtonSize.large ? double.infinity : null),
      height: spec.height,
      child: _buildButton(disabled: disabled, fontSize: spec.fontSize),
    );
  }

  // 버튼 타입에 따른 스타일 분기
  Widget _buildButton({required bool disabled, required double fontSize}) {
    final TextStyle textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );

    // 로딩 또는 child/text 렌더링 처리
    final Widget buttonContent = isLoading
        ? SizedBox(
            width: fontSize + 6,
            height: fontSize + 6,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : (child ?? Text(text ?? '', style: textStyle));

    if (type == OakeyButtonType.outline) {
      return OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: OakeyTheme.primaryDeep,
          side: const BorderSide(color: OakeyTheme.borderLine),
          shape: RoundedRectangleBorder(borderRadius: OakeyTheme.brBtn),
        ),
        child: buttonContent,
      );
    }

    if (type == OakeyButtonType.secondary) {
      return ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OakeyTheme.surfaceMuted,
          foregroundColor: OakeyTheme.primaryDeep,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: OakeyTheme.brBtn),
        ),
        child: buttonContent,
      );
    }

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: OakeyTheme.primaryDeep,
        foregroundColor: OakeyTheme.textWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: OakeyTheme.brBtn),
      ),
      child: buttonContent,
    );
  }

  // 버튼 사이즈에 따른 높이와 폰트 크기 반환
  _ButtonSizeSpec _getSizeSpec(OakeyButtonSize size) {
    switch (size) {
      case OakeyButtonSize.large:
        return const _ButtonSizeSpec(height: 58, fontSize: 16);
      case OakeyButtonSize.medium:
        return const _ButtonSizeSpec(height: 46, fontSize: 14);
      case OakeyButtonSize.small:
        return const _ButtonSizeSpec(height: 34, fontSize: 12);
    }
  }
}

// 버튼 사이즈 스펙 정의
class _ButtonSizeSpec {
  final double height;
  final double fontSize;
  const _ButtonSizeSpec({required this.height, required this.fontSize});
}

// 공통 태그 위젯
class OakeyTag extends StatelessWidget {
  // 태그 라벨 텍스트
  final String label;

  // 선택 상태 여부
  final bool isSelected;

  // 태그 내부 여백
  final EdgeInsets padding;

  // 태그 모서리 반경
  final double? radius;

  const OakeyTag({
    super.key,
    required this.label,
    this.isSelected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isSelected ? OakeyTheme.primaryDeep : OakeyTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(radius ?? OakeyTheme.radiusS),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? OakeyTheme.textWhite : OakeyTheme.primaryDeep,
        ),
      ),
    );
  }
}
