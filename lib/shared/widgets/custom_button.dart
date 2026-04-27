import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'package:my_petition_app/shared/widgets/custom_text.dart';

enum CustomButtonType { filled, outlined, text }

class CustomButton extends StatelessWidget {
  /// Button text label
  final String text;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button type: filled (default), outlined, or text
  final CustomButtonType type;

  /// Full width button (default: true)
  final bool isFullWidth;

  /// Show loading spinner instead of text
  final bool isLoading;

  /// Button height (default: 48)
  final double height;

  /// Border radius (default: 14)
  final double borderRadius;

  /// Custom background color (overrides default)
  final Color? backgroundColor;

  /// Custom text color (overrides default)
  final Color? textColor;

  /// Custom border color (for outlined type)
  final Color? borderColor;

  /// Border width (default: 1)
  final double borderWidth;

  /// Text font size (default: 15)
  final double fontSize;

  /// Text font weight (default: w600)
  final FontWeight fontWeight;

  /// Leading icon (before text)
  final IconData? prefixIcon;

  /// Trailing icon (after text)
  final IconData? suffixIcon;

  /// Icon size (default: 16)
  final double iconSize;

  /// Spacing between icon and text (default: 6)
  final double iconSpacing;

  /// Custom width (when isFullWidth is false)
  final double? width;

  /// Custom padding
  final EdgeInsetsGeometry? padding;

  /// Elevation (default: 0)
  final double elevation;

  /// Loading indicator color
  final Color? loadingColor;

  /// Loading indicator size (default: 18)
  final double loadingSize;

  /// Loading indicator stroke width (default: 2)
  final double loadingStrokeWidth;

  /// Disabled state (auto-disabled when isLoading)
  final bool isDisabled;

  /// Custom child widget (overrides text, icon, loading)
  final Widget? child;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.filled,
    this.isFullWidth = true,
    this.isLoading = false,
    this.height = 48,
    this.borderRadius = 14,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 1,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w600,
    this.prefixIcon,
    this.suffixIcon,
    this.iconSize = 16,
    this.iconSpacing = 6,
    this.width,
    this.padding,
    this.elevation = 0,
    this.loadingColor,
    this.loadingSize = 18,
    this.loadingStrokeWidth = 2,
    this.isDisabled = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled = isDisabled || isLoading;
    final VoidCallback? effectiveOnPressed =
        effectiveDisabled ? null : onPressed;

    Widget buttonChild = child ?? _buildContent();

    Widget button;

    switch (type) {
      case CustomButtonType.filled:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? AppColors.white,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: elevation,
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: buttonChild,
        );
        break;

      case CustomButtonType.outlined:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: BorderSide(
              color: borderColor ?? AppColors.primary,
              width: borderWidth,
            ),
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: buttonChild,
        );
        break;

      case CustomButtonType.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            minimumSize: Size(0, height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: buttonChild,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: button,
      );
    }

    if (width != null) {
      return SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return SizedBox(
      height: height,
      child: button,
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: loadingSize,
        width: loadingSize,
        child: CircularProgressIndicator(
          color: loadingColor ??
              (type == CustomButtonType.filled
                  ? AppColors.white
                  : AppColors.primary),
          strokeWidth: loadingStrokeWidth,
        ),
      );
    }

    final textWidget = AppText(
      title: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: textColor ??
          (type == CustomButtonType.filled ? AppColors.white : AppColors.primary),
    );


    if (prefixIcon == null && suffixIcon == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: iconSize),
          SizedBox(width: iconSpacing),
        ],
        textWidget,
        if (suffixIcon != null) ...[
          SizedBox(width: iconSpacing),
          Icon(suffixIcon, size: iconSize),
        ],
      ],
    );
  }
}
