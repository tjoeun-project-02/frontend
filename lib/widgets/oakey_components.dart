import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

// Oakey button type
enum OakeyButtonType { primary, secondary, outline }

// Oakey button size
enum OakeyButtonSize { large, medium, small }

// Oakey button
class OakeyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final OakeyButtonType type;
  final OakeyButtonSize size;
  final double? width;
  final bool isLoading;

  const OakeyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = OakeyButtonType.primary,
    this.size = OakeyButtonSize.large,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final _ButtonSizeSpec spec = _getSizeSpec(size);
    final double radius = _getRadius(size);
    final bool disabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? (size == OakeyButtonSize.large ? double.infinity : null),
      height: spec.height,
      child: _buildButton(
        disabled: disabled,
        fontSize: spec.fontSize,
        radius: radius,
      ),
    );
  }

  Widget _buildButton({
    required bool disabled,
    required double fontSize,
    required double radius,
  }) {
    final TextStyle textStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );

    final Widget child = isLoading
        ? SizedBox(
            width: fontSize + 6,
            height: fontSize + 6,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(text, style: textStyle);

    if (type == OakeyButtonType.outline) {
      return OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: OakeyTheme.primaryDeep,
          side: const BorderSide(color: OakeyTheme.borderLine),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      );
    }

    if (type == OakeyButtonType.secondary) {
      return ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OakeyTheme.surfaceMuted,
          foregroundColor: OakeyTheme.primaryDeep,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: OakeyTheme.primaryDeep,
        foregroundColor: OakeyTheme.textWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child: child,
    );
  }

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

  double _getRadius(OakeyButtonSize size) {
    if (size == OakeyButtonSize.small) return OakeyTheme.radiusS;
    if (size == OakeyButtonSize.medium) return OakeyTheme.radiusM;
    return OakeyTheme.radiusL;
  }
}

// Button size spec
class _ButtonSizeSpec {
  final double height;
  final double fontSize;
  const _ButtonSizeSpec({required this.height, required this.fontSize});
}

// Oakey tag
class OakeyTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final EdgeInsets padding;
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
    final double r = radius ?? OakeyTheme.radiusS;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isSelected ? OakeyTheme.primaryDeep : OakeyTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(r),
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
