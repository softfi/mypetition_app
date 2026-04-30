import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/utils/custom_text_field.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';

class EnterDetailsScreen extends StatefulWidget {
  const EnterDetailsScreen({super.key});

  @override
  State<EnterDetailsScreen> createState() => _EnterDetailsScreenState();
}

class _EnterDetailsScreenState extends State<EnterDetailsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isTermsAccepted = false;
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Heading
                  Center(
                    child: AppText(
                      title: AppStrings.enterDetails,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Description
                  Center(
                    child: AppText(
                      title: AppStrings.enterDetailsDescription,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Name label
                  AppText(
                    title: AppStrings.enterYourName,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 8),

                  CustomTextField(
                    hint: AppStrings.enterYourNameHint,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Email label (Optional)
                  AppText(
                    title: AppStrings.enterYourEmail,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 8),

                  // Email field
                  CustomTextField(
                    hint: AppStrings.enterYourEmailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 24),

                  // Terms checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isTermsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _isTermsAccepted = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          title: AppStrings.termsText,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Continue button
                  Obx(() => CustomButton(
                    text: AppStrings.continueText,
                    isLoading: _profileController.isSubmitting,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (!_isTermsAccepted) {
                          Get.snackbar("Terms & Conditions", "Please accept terms and conditions");
                          return;
                        }
                        
                        final success = await _profileController.updateProfile(
                          name: _nameController.text.trim(),
                        );
                        
                        if (success) {
                          Get.offAllNamed(AppRoutes.main);
                        }
                      }
                    },
                  )),

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
