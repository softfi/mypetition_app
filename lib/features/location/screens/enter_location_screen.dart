import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/location_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_dropdown.dart';
import 'package:my_petition_app/shared/widgets/custom_text.dart';

class EnterLocationScreen extends StatelessWidget {
  const EnterLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                Consumer<LocationProvider>(
                  builder: (context, locationProvider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // State Dropdown
                        SingleSelectionDropdown<String>(
                          title: AppStrings.selectYourState,
                          selectedValue: locationProvider.selectedState,
                          items: locationProvider.states,
                          onSelectionChanged: (value) =>
                              locationProvider.selectState(value),
                          getId: (s) => s,
                          getName: (s) => s,
                        ),

                        const SizedBox(height: 24),

                        // City Dropdown
                        SingleSelectionDropdown<String>(
                          title: AppStrings.selectYourCity,
                          selectedValue: locationProvider.selectedCity,
                          items: locationProvider.cities,
                          isActive: locationProvider.selectedState != null,
                          onSelectionChanged: (value) =>
                              locationProvider.selectCity(value),
                          getId: (s) => s,
                          getName: (s) => s,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Continue button
                Consumer<LocationProvider>(
                  builder: (context, locationProvider, child) {
                    return CustomButton(
                      text: AppStrings.continueText,
                      isLoading: locationProvider.isLoading,
                      onPressed: () async {
                        final success =
                            await locationProvider.submitLocation();
                        if (success && context.mounted) {
                          Navigator.pushNamed(
                              context, '/enter-details');
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: AppText(
                                title: 'Please select both state and city',
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    );
                  },
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
