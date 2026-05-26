import 'package:flutter/material.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class AnimatedSignButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;
  final double fontSize;
  final double? width;

  const AnimatedSignButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.borderRadius = 14,
    this.fontSize = 15,
    this.width,
  });

  @override
  State<AnimatedSignButton> createState() => _AnimatedSignButtonState();
}

class _AnimatedSignButtonState extends State<AnimatedSignButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const saffron = Color(0xFFFF9933);
    const green = Color(0xFF138808);

    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final glowOffset = _animation.value * 4 + 2;
          
          return Container(
            height: widget.height,
            width: widget.width ?? double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: saffron.withOpacity(0.3 * (1 - _animation.value)),
                  blurRadius: glowOffset,
                  spreadRadius: _animation.value * 2,
                  offset: const Offset(-2, 2),
                ),
                BoxShadow(
                  color: green.withOpacity(0.3 * _animation.value),
                  blurRadius: glowOffset,
                  spreadRadius: _animation.value * 2,
                  offset: const Offset(2, 2),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  saffron,
                  Color(0xFFFFAE59),
                  Color(0xFF38A129),
                  green,
                ],
                stops: [
                  0.0,
                  _animation.value * 0.4,
                  0.6 + (1 - _animation.value) * 0.4,
                  1.0,
                ],
              ),
            ),
            child: Center(
              child: AppText(
                title: widget.text,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }
}
