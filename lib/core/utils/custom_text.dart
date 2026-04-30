import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A reusable text widget that inherits the global Inter font from the app theme.
/// Pass a [style] to override size, weight, color, etc. — the Inter font is
/// automatically applied through the global [ThemeData.textTheme].

class AppText extends StatelessWidget {
  final String title;
  final double fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double height;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? textOverflow;
  final bool? mandatory;
  final int? maxLines;
  final TextDecoration? decoration;
  final double? letterSpacing;
  final FontStyle? fontStyle;


  const AppText({
    super.key,
    required this.title,
    this.fontSize = 12,
    this.fontWeight,
    this.height = 1.3,
    this.color,
    this.textAlign,
    this.textOverflow,
    this.mandatory,
    this.decoration,
    this.maxLines,
    this.fontFamily,
    this.letterSpacing,
    this.fontStyle,
  });

  // Named constructors for specific styles
  const AppText.title({
    super.key,
    required this.title,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
    this.color = AppColors.textPrimary,
    this.height = 1.3,
    this.textAlign,
    this.textOverflow,
    this.mandatory = false,
    this.decoration,
    this.maxLines,
    this.fontFamily,
    this.letterSpacing,
    this.fontStyle,
  });

  const AppText.description({
    super.key,
    required this.title,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.color = AppColors.textSecondary,
    this.height = 1.5,
    this.textAlign,
    this.textOverflow,
    this.mandatory = false,
    this.decoration,
    this.maxLines,
    this.fontFamily,
    this.letterSpacing,
    this.fontStyle,
  });

  const AppText.content({
    super.key,
    required this.title,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.color = AppColors.textPrimary,
    this.height = 1.6,
    this.textAlign,
    this.textOverflow,
    this.mandatory = false,
    this.decoration,
    this.maxLines,
    this.fontFamily,
    this.letterSpacing,
    this.fontStyle,
  });



  @override
  Widget build(BuildContext context) {
    return  mandatory == true
        ? Row(
      children: [
        Text(
          title,
          maxLines: maxLines,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            height: height,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            decoration: decoration,
            letterSpacing: letterSpacing,
            fontStyle: fontStyle,
          ),
        ),
        Visibility(
          visible: mandatory ?? false,
          child: const Text(
            " *",
            style: TextStyle(color: Colors.red),
          ),
        )
      ],
    )
        : Text(
      title,
      maxLines: maxLines,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        color: color,
        fontSize: fontSize,
        decoration: decoration,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      ),
    );
  }
}







