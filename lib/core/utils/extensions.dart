import 'package:flutter/material.dart';

extension ColorExtension on String? {
  /// Converts a hex color string (e.g., "#RRGGBB", "#AARRGGBB", or "RRGGBB") to a [Color].
  /// Returns [fallback] if the string is null, empty, or invalid.
  Color toColor({Color fallback = const Color(0xFF3B82F6)}) {
    if (this == null || this!.isEmpty) return fallback;

    String hexColor = this!.replaceAll("#", "");
    
    // Handle short hex (3 digits)
    if (hexColor.length == 3) {
      hexColor = hexColor.split('').map((c) => "$c$c").join('');
    }

    try {
      if (hexColor.length == 6) {
        hexColor = "FF$hexColor";
      }
      
      if (hexColor.length == 8) {
        return Color(int.parse("0x$hexColor"));
      }
    } catch (e) {
      debugPrint("❌ Invalid Hex Color: $this");
    }

    return fallback;
  }
}
