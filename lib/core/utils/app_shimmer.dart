import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';

class AppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  static Shimmer fromColors({
    required BuildContext context,
    required Widget child,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : AppColors.grey200,
      highlightColor: isDark ? Colors.grey[800]! : AppColors.grey100,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return fromColors(
      context: context,
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          ),
    );
  }
}
