import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/utils/custom_text_field.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/models/category_model.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';

class EnterDetailsScreen extends StatefulWidget {
  const EnterDetailsScreen({super.key});

  @override
  State<EnterDetailsScreen> createState() => _EnterDetailsScreenState();
}

class _EnterDetailsScreenState extends State<EnterDetailsScreen> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isTermsAccepted = false;
  final ProfileController _profileController = Get.find<ProfileController>();
  final DiscoverController _discoverController = Get.find<DiscoverController>();

  @override
  void initState() {
    super.initState();
    // Fetch categories if not already loaded
    if (_discoverController.categoriesList.isEmpty) {
      _discoverController.fetchCategories();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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

                  // First Name
                  AppText(
                    title: "First Name",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hint: "Enter your first name",
                    controller: _firstNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Middle Name
                  AppText(
                    title: "Middle Name (Optional)",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hint: "Enter your middle name",
                    controller: _middleNameController,
                  ),
                  const SizedBox(height: 24),

                  // Last Name
                  AppText(
                    title: "Last Name (Optional)",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    hint: "Enter your last name",
                    controller: _lastNameController,
                  ),

                  const SizedBox(height: 24),

                  // Email label (Optional)
                  AppText(
                    title: AppStrings.enterYourEmail,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),

                  // Email field
                  CustomTextField(
                    hint: AppStrings.enterYourEmailHint,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 24),

                  // Interests Section
                  AppText(
                    title: "Your Interests",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 8),
                  const AppText(
                    title: "Select categories that interest you",
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (_discoverController.isCategoriesLoading.value &&
                        _discoverController.categoriesList.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _discoverController.categoriesList.map((category) {
                        final isSelected = _profileController.selectedCategoryIds.contains(category.id);
                        return GestureDetector(
                          onTap: () => _profileController.toggleCategory(category.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.15) : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText(
                                  title: category.name,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.check, size: 12, color: AppColors.primary),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),

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

                  const SizedBox(height: 30),

                  // Continue button
                  Obx(() => CustomButton(
                    text: AppStrings.continueText,
                    isLoading: _profileController.isSubmitting,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (!_isTermsAccepted) {
                          CommonToast.showToastError("Please accept terms and conditions");
                          return;
                        }
                        
                        final success = await _profileController.updateProfile(
                          firstName: _firstNameController.text.trim(),
                          middleName: _middleNameController.text.trim(),
                          lastName: _lastNameController.text.trim(),
                          email: _emailController.text.trim(),
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
