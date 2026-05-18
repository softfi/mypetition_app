import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/constants/app_strings.dart';
import 'package:my_petition_app/core/constants/app_text_styles.dart';
import '../../../controllers/location_controller.dart';
import '../models/location_models.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_dropdown.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';

class EnterLocationScreen extends StatelessWidget {
  const EnterLocationScreen({super.key});

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
                const SizedBox(height: 60),

                // Location icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.green,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 20),

                // Enter Location heading
                AppText(
                  title: AppStrings.enterLocation,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green,
                ),

                const SizedBox(height: 10),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AppText(
                    title: AppStrings.locationDescription,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 40),

                // Select State
                Obx(() {
                  final locationController = Get.find<LocationController>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // State Dropdown
                      SingleSelectionDropdown<StateModel>(
                        title: AppStrings.selectYourState,
                        selectedValue: locationController.selectedState,
                        items: locationController.stateModels,
                        isLoading: locationController.isStatesLoading,
                        onSelectionChanged: (value) =>
                            locationController.selectState(value),
                        getId: (s) => s.id.toString(),
                        getName: (s) => s.name,
                      ),

                      const SizedBox(height: 24),

                      // District Dropdown
                      SingleSelectionDropdown<DistrictModel>(
                        title: AppStrings.selectYourCity, // Reusing city string for District
                        selectedValue: locationController.selectedDistrict,
                        items: locationController.districtModels,
                        isActive: locationController.selectedState != null,
                        isLoading: locationController.isDistrictsLoading,
                        onSelectionChanged: (value) =>
                            locationController.selectDistrict(value),
                        getId: (s) => s.id.toString(),
                        getName: (s) => s.name,
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 48),

                // Continue button
                Obx(() {
                  final locationController = Get.find<LocationController>();
                  return CustomButton(
                    text: AppStrings.continueText,
                    isLoading: locationController.isSubmitting,
                    onPressed: () async {
                      final success = await locationController.submitLocation();
                      if (success) {
                        Get.toNamed('/enter-details');
                      } else {
                        AppSnackbar.error('Please select both state and city');
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
    );
  }
}
