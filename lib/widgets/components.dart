import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

enum OakeyButtonType { primary, secondary, outline }

enum OakeyButtonSize { large, medium, small }

// 공통 버튼 위젯
class OakeyButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final OakeyButtonType type;
  final OakeyButtonSize size;
  final double? width;
  final bool isLoading;
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
    // onPressed가 null이거나 로딩 중이면 비활성화
    final bool disabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? (size == OakeyButtonSize.large ? double.infinity : null),
      height: spec.height,
      child: _buildButtonContent(disabled: disabled, spec: spec),
    );
  }

  Widget _buildButtonContent({
    required bool disabled,
    required _ButtonSizeSpec spec,
  }) {
    final Widget content = isLoading
        ? SizedBox(
            width: spec.fontSize + 4,
            height: spec.fontSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              // 배경색에 따라 스피너 색상 자동 조정
              color: type == OakeyButtonType.primary
                  ? OakeyTheme.textWhite
                  : OakeyTheme.primaryDeep,
            ),
          )
        : (child ??
              Text(
                text ?? '',
                style: TextStyle(
                  fontSize: spec.fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ));

    switch (type) {
      case OakeyButtonType.outline:
        return OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: OakeyTheme.primaryDeep,
            side: const BorderSide(color: OakeyTheme.borderLine),
            shape: RoundedRectangleBorder(borderRadius: OakeyTheme.radiusS),
            padding: spec.padding,
          ),
          child: content,
        );

      case OakeyButtonType.secondary:
        return ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: OakeyTheme.surfaceMuted,
            foregroundColor: OakeyTheme.primaryDeep,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: OakeyTheme.radiusS),
            padding: spec.padding,
          ),
          child: content,
        );

      case OakeyButtonType.primary:
      default:
        return ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: OakeyTheme.primaryDeep,
            foregroundColor: OakeyTheme.textWhite,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: OakeyTheme.radiusS),
            padding: spec.padding,
          ),
          child: content,
        );
    }
  }

  _ButtonSizeSpec _getSizeSpec(OakeyButtonSize size) {
    switch (size) {
      case OakeyButtonSize.large:
        return const _ButtonSizeSpec(
          height: 56,
          fontSize: 16,
          padding: EdgeInsets.symmetric(horizontal: 24),
        );
      case OakeyButtonSize.medium:
        return const _ButtonSizeSpec(
          height: 48,
          fontSize: 14,
          padding: EdgeInsets.symmetric(horizontal: 16),
        );
      case OakeyButtonSize.small:
        return const _ButtonSizeSpec(
          height: 36,
          fontSize: 12,
          padding: EdgeInsets.symmetric(horizontal: 12),
        );
    }
  }
}

class _ButtonSizeSpec {
  final double height;
  final double fontSize;
  final EdgeInsets padding;
  const _ButtonSizeSpec({
    required this.height,
    required this.fontSize,
    required this.padding,
  });
}

// 공통 태그 위젯
class OakeyTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const OakeyTag({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? OakeyTheme.primaryDeep : OakeyTheme.surfaceMuted,
          borderRadius: OakeyTheme.radiusXS,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? OakeyTheme.textWhite : OakeyTheme.primaryDeep,
          ),
        ),
      ),
    );
  }
}

// 공통 텍스트 입력창 위젯
class OakeyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final int maxLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;
  final bool readOnly; // ★ 추가됨: 읽기 전용 여부

  const OakeyTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.suffixIcon,
    this.readOnly = false, // 기본값 false
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      readOnly: readOnly, // ★ 여기에 연결
      style: OakeyTheme.textBodyL.copyWith(
        // 읽기 전용이면 글자색을 흐리게
        color: readOnly ? OakeyTheme.textSub : OakeyTheme.textMain,
      ),
      decoration: OakeyTheme.inputDeco(hintText).copyWith(
        suffixIcon: suffixIcon,
        // ★ 읽기 전용이면 배경색을 어둡게(surfaceMuted) 변경
        fillColor: readOnly ? OakeyTheme.surfaceMuted : OakeyTheme.surfacePure,
      ),
    );
  }
}
