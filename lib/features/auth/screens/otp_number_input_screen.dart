import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/constants/app_text_styles.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import '../../../controllers/auth_controller.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text_field.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class OtpNumberInputScreen extends StatefulWidget {
  const OtpNumberInputScreen({super.key});

  @override
  State<OtpNumberInputScreen> createState() => _OtpNumberInputScreenState();
}

class _OtpNumberInputScreenState extends State<OtpNumberInputScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // isme

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Skip button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.find<AuthController>().skipAuth();
                      },
                      child: AppText(
                        title: AppStrings.skip,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.grey500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Illustration
                  SizedBox(
                    height: 240,
                    child: Image.asset(
                      AppAssets.otpIllustration,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 240,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // OTP Verification heading
                  AppText(
                    title: AppStrings.otpVerification,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),

                  const SizedBox(height: 10),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AppText(
                      title: AppStrings.otpDescription,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Mobile Number Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      title: AppStrings.mobileNumber,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  CustomTextField.phone(
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid mobile number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),


                  // Continue button
                  Obx(() {
                    final authController = Get.find<AuthController>();
                    return CustomButton(
                      text: AppStrings.continueText,
                      isLoading: authController.isLoading,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          authController.setPhoneNumber(_phoneController.text);
                          final success = await authController.sendOtp();
                          if (success) {
                            Get.toNamed(AppRoutes.otpVerify);
                          }
                        }
                      },
                    );
                  }),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
