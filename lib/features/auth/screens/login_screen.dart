import 'package:flutter/material.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';

// / acha isme api call service ke liye ek alag se api response sanitizer file banao jisse ki har api call respoen proper sanitize hoker mugeh mile taaki app api respoen kabhi crash na ho chahe null check , emply , blank etcc jitne bhi api crashes ho skte hia sabke liye ek sanitizer banao taaki app me kabhi red screen na dikhr koi error na aye proper professional ki trah se
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Logo
                _buildLogo(),

                const SizedBox(height: 28),

                // Image Grid
                _buildImageGrid(size),

                const SizedBox(height: 32),

                // Headline
                AppText(
                  title: AppStrings.publishHeadline,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: AppText(
                    title: AppStrings.publishDescription,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                CustomButton(
                  text: AppStrings.signUp,
                  onPressed: () {
                    final authController = Get.find<AuthController>();
                    authController.setIsLogin(false);
                    Get.toNamed(AppRoutes.otpInput);
                  },
                ),

                const SizedBox(height: 14),

                // Log In Button
                CustomButton(
                  text: AppStrings.logIn,
                  type: CustomButtonType.outlined,
                  onPressed: () {
                    final authController = Get.find<AuthController>();
                    authController.setIsLogin(true);
                    Get.toNamed(AppRoutes.otpInput);
                  },
                ),

                const SizedBox(height: 16),

                // Skip Button
                TextButton(
                  onPressed: () => Get.find<AuthController>().skipAuth(),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: AppText(
                    title: 'Skip and Browse as Guest',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                    decoration: TextDecoration.underline,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      AppAssets.logo,
      height: 80, // Adjust size as necessary
    );
  }

  Widget _buildImageGrid(Size size) {
    final gridSize = size.width - 48; // padding

    return SizedBox(
      width: gridSize,
      height: gridSize * 0.85,
      child: Row(
        children: [
          // Left column
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: _buildGridImage(AppAssets.loginGrid1),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 4,
                  child: _buildGridImage(AppAssets.loginGrid2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right column
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildGridImage(AppAssets.loginGrid3),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 6,
                  child: _buildGridImage(AppAssets.loginGrid4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridImage(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.grey200,
              child: const Icon(
                Icons.image_outlined,
                size: 40,
                color: AppColors.grey400,
              ),
            );
          },
        ),
      ),
    );
  }
}
