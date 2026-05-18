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
      margin: const EdgeInsets.only(bottom: 10, right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.remove,
            size: 16,
            onTap: () => controller.changeFontSize(-0.1),
          ),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AppText(
              title: '${(controller.fontSizeFactor.value * 100).toInt()}%',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          )),
          _buildActionButton(
            icon: Icons.add,
            size: 16,
            onTap: () => controller.changeFontSize(0.1),
          ),
          Container(height: 12, width: 1, color: Theme.of(context).dividerColor, margin: const EdgeInsets.symmetric(horizontal: 2)),
          _buildActionButton(
            icon: Icons.refresh,
            size: 14,
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
    double size = 18,
    Color color = AppColors.accent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
