import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/connectivity/connectivity_controller.dart';

class NoInternetWrapper extends StatelessWidget {
  final Widget child;

  const NoInternetWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = ConnectivityController.to;
      return Stack(
        children: [
          child,
          // Overlay when no internet
          if (!controller.isConnected.value)
            const _NoInternetOverlay(),
        ],
      );
    });
  }
}

class _NoInternetOverlay extends StatefulWidget {
  const _NoInternetOverlay();

  @override
  State<_NoInternetOverlay> createState() => _NoInternetOverlayState();
}

class _NoInternetOverlayState extends State<_NoInternetOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      // ✅ Material wrap — fixes yellow underline on Text widgets
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated wifi icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF0F6FF),
                    border: Border.all(
                      color: const Color(0xFFBDD7F5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Color(0xFF2D6A9F),
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'No Internet Connection',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Please check your network settings\nand try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                    height: 1.6,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Animated dots — "checking..."
              _CheckingDots(),

              const SizedBox(height: 16),

              Text(
                'Waiting for connection...',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Three animated bouncing dots
class _CheckingDots extends StatefulWidget {
  @override
  State<_CheckingDots> createState() => _CheckingDotsState();
}

class _CheckingDotsState extends State<_CheckingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8 + (_controllers[i].value * 8),
            decoration: BoxDecoration(
              color: Color.lerp(
                const Color(0xFF2D6A9F),
                const Color(0xFF4A9EDE),
                _controllers[i].value,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
