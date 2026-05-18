import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class AnimatedBorderButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final double borderWidth;
  final double fontSize;

  const AnimatedBorderButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.borderRadius = 14,
    this.borderWidth = 2,
    this.fontSize = 15,
  });

  @override
  State<AnimatedBorderButton> createState() => _AnimatedBorderButtonState();
}

class _AnimatedBorderButtonState extends State<AnimatedBorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Stack(
          children: [
            // Rotating Gradient Background (The Border)
            ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: SweepGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.1),
                          AppColors.primary,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        transform: GradientRotation(_controller.value * 2 * 3.14159),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Inner Content Container (To hide the middle of the gradient)
            Padding(
              padding: EdgeInsets.all(widget.borderWidth),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius - widget.borderWidth),
                ),
                child: Center(
                  child: AppText(
                    title: widget.text,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
