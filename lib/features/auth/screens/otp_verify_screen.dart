import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:my_petition_app/core/constants/app_assets.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/constants/app_text_styles.dart';
import '../../../controllers/auth_controller.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  String _otpValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Illustration
                SizedBox(
                  height: 220,
                  child: Image.asset(
                    AppAssets.otpIllustration,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
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

                // Enter OTP heading
                AppText(
                  title: AppStrings.enterOtp,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),

                const SizedBox(height: 10),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AppText(
                    title: AppStrings.enterOtpDescription,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 36),

                // OTP Pin Code Fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 4,
                    // No controller passed — avoids double-dispose crash
                    obscureText: false,
                    animationType: AnimationType.fade,
                    keyboardType: TextInputType.number,
                    textStyle: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 55,
                      fieldWidth: 55,
                      activeFillColor: Theme.of(context).cardColor,
                      inactiveFillColor: Theme.of(context).cardColor,
                      selectedFillColor: Theme.of(context).cardColor,
                      activeColor: AppColors.primary,
                      inactiveColor: Theme.of(context).dividerColor,
                      selectedColor: AppColors.primary,
                      borderWidth: 1.5,
                    ),
                    animationDuration: const Duration(milliseconds: 200),
                    enableActiveFill: true,
                    onChanged: (value) {
                      _otpValue = value;
                      Get.find<AuthController>().setOtp(value);
                    },
                    onCompleted: (value) {
                      _otpValue = value;
                    },
                  ),
                ),

                const SizedBox(height: 36),

                // Continue button
                Obx(() {
                  final authController = Get.find<AuthController>();
                  return CustomButton(
                    text: AppStrings.continueText,
                    isLoading: authController.isLoading,
                    onPressed: () async {
                      if (_otpValue.length == 4) {
                        await authController.verifyOtp();
                      }
                    },
                  );
                }),

                const SizedBox(height: 24),

                // Resend OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      title: AppStrings.notReceivedOtp,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.find<AuthController>().resendOtp();
                      },
                      child: AppText(
                        title: AppStrings.resend,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
