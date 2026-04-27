import 'package:flutter/material.dart';

/// A reusable text widget that inherits the global Outfit font from the app theme.
/// Pass a [style] to override size, weight, color, etc. — the Outfit font is
/// automatically applied through the global [ThemeData.textTheme].
///
///
///
///


import 'package:flutter/material.dart';

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
    this.height=1.3,
    this.color,
    this.textAlign,
    this.textOverflow,
    this.mandatory,
    this.decoration,
    this.maxLines, this.fontFamily,
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
          style: TextStyle(
            height: height,
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            // fontFamily: fontFamily??'RethinkSans',
            fontFamily: 'Inter',
            overflow: textOverflow,
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
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        decoration: decoration,
        fontWeight: fontWeight,
        overflow: textOverflow,
        fontFamily: 'Inter',
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        // fontFamily: 'RethinkSans',
      ),
    );
  }
}



// class AppText extends StatelessWidget {
//   final String text;
//   final TextStyle? style;
//   final TextAlign? textAlign;
//   final int? maxLines;
//   final TextOverflow? overflow;
//   final TextDirection? textDirection;
//
//   const AppText(
//     this.text, {
//     super.key,
//     this.style,
//     this.textAlign,
//     this.maxLines,
//     this.overflow,
//     this.textDirection,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: style,
//       textAlign: textAlign,
//       maxLines: maxLines,
//       overflow: overflow,
//       textDirection: textDirection,
//     );
//   }
// }



