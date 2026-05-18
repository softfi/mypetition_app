import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class AnimatedSignButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final double borderRadius;

  const AnimatedSignButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.width,
    this.borderRadius = 24,
  });

  @override
  State<AnimatedSignButton> createState() => _AnimatedSignButtonState();
}

class _AnimatedSignButtonState extends State<AnimatedSignButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.03), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.03, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse Rings
              ...List.generate(3, (index) {
                final double delay = index * 0.3;
                final double progress = (_pulseController.value - delay) % 1.0;
                final double opacity = (1.0 - progress).clamp(0.0, 1.0);
                final double scale = 1.0 + (progress * 0.4);

                return Opacity(
                  opacity: opacity * 0.4,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.width ?? double.infinity,
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                );
              }),
              
              // Main Button
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.width ?? double.infinity,
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        AppText(
                          title: widget.text.toUpperCase(),
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
