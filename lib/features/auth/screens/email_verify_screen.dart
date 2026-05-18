import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/utils/custom_text_field.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const AppText(title: 'Verify Email', fontSize: 18, fontWeight: FontWeight.w600),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(() {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  title: 'Almost there!',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),
                const SizedBox(height: 8),
                AppText(
                  title: authController.isEmailOtpSent
                      ? 'Please enter the 6-digit code sent to your email.'
                      : 'We need to verify your email address before you can vote.',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 40),

                if (!authController.isEmailOtpSent) ...[
                  const AppText(title: 'Email Address', fontSize: 13, fontWeight: FontWeight.w500),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixWidget: const Icon(Icons.email_outlined, size: 20),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      if (!GetUtils.isEmail(value)) return 'Enter a valid email';
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Send Verification Code',
                    isLoading: authController.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await authController.sendEmailOtp(_emailController.text);
                      }
                    },
                  ),
                ] else ...[
                  Center(
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      animationType: AnimationType.fade,
                      keyboardType: TextInputType.number,
                      textStyle: GoogleFonts.inter(
                        fontSize: 20, 
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 45,
                        fieldWidth: 45,
                        activeFillColor: Theme.of(context).cardColor,
                        inactiveFillColor: Theme.of(context).cardColor,
                        selectedFillColor: Theme.of(context).cardColor,
                        activeColor: AppColors.primary,
                        inactiveColor: Theme.of(context).dividerColor,
                        selectedColor: AppColors.primary,
                        borderWidth: 1.5,
                      ),
                      onChanged: (v) => _otpController.text = v,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: 'Verify & Continue',
                    isLoading: authController.isLoading,
                    onPressed: () async {
                      if (_otpController.text.length == 6) {
                        final success = await authController.verifyEmailOtp(_otpController.text);
                        if (success) {
                          Get.back(); // Return to petition detail
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => authController.sendEmailOtp(_emailController.text),
                      child: const AppText(
                        title: 'Resend Code',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
