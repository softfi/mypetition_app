import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class FontSizeControls extends GetView<DiscoverController> {
  const FontSizeControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.remove,
            onTap: () => controller.changeFontSize(-0.1),
          ),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AppText(
              title: '${(controller.fontSizeFactor.value * 100).toInt()}%',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          )),
          _buildActionButton(
            icon: Icons.add,
            onTap: () => controller.changeFontSize(0.1),
          ),
          const SizedBox(width: 4),
          _buildActionButton(
            icon: Icons.refresh,
            size: 16,
            color: AppColors.textHint,
            onTap: () => controller.resetFontSize(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 20,
    Color color = AppColors.accent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
