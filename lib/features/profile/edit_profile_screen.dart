import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/controllers/location_controller.dart';
import 'dart:io';
import 'package:my_petition_app/core/constants/app_colors.dart';
import 'package:my_petition_app/core/utils/custom_button.dart';
import 'package:my_petition_app/core/utils/custom_text.dart';
import 'package:my_petition_app/core/utils/custom_text_field.dart';
import 'package:my_petition_app/core/utils/custom_dropdown.dart';
import 'package:my_petition_app/features/location/models/location_models.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/models/category_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late ProfileController _profileController;
  late LocationController _locationController;
  late DiscoverController _discoverController;
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.find<ProfileController>();
    _locationController = Get.find<LocationController>();
    _discoverController = Get.find<DiscoverController>();
    
    final user = _profileController.currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.mobile ?? '');
    
    // Pre-select location if available
    _initializeLocation();

    // Fetch categories if not already loaded
    if (_discoverController.categoriesList.isEmpty) {
      _discoverController.fetchCategories();
    }
  }

  Future<void> _initializeLocation() async {
    final user = _profileController.currentUser;
    if (user == null) return;

    // Ensure states are loaded
    if (_locationController.stateModels.isEmpty) {
      await _locationController.fetchStates();
    }

    if (user.stateId != null) {
      final state = _locationController.stateModels.firstWhereOrNull((s) => s.id == user.stateId);
      if (state != null) {
        // selectState now fetches districts internally and can be awaited
        await _locationController.selectState(state);
        
        // After selectState finishes, districts are loaded
        if (user.cityId != null) {
          final district = _locationController.districtModels.firstWhereOrNull((d) => d.id == user.cityId);
          if (district != null) {
            _locationController.selectDistrict(district);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          title: 'Edit Profile',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Profile image with edit icon
            Obx(() {
              return Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => _profileController.pickProfileImage(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B0000),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.grey200, width: 3),
                        image: _profileController.profileImage != null
                            ? DecorationImage(
                                image: FileImage(_profileController.profileImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileController.profileImage == null
                          ? Center(
                              child: AppText(
                                title: _getInitials(),
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _profileController.pickProfileImage(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              );
            }),
            
            const SizedBox(height: 40),

            // Form Fields
            CustomTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Email Address',
              hint: 'Enter your email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Phone Number',
              hint: 'Enter your phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              isReadOnly: true, // Mobile is verified, so keep it read-only
            ),
            const SizedBox(height: 20),
            
            Obx(() => Row(
              children: [
                Expanded(
                  child: SingleSelectionDropdown<StateModel>(
                    title: 'State',
                    selectedValue: _locationController.selectedState,
                    items: _locationController.stateModels,
                    isLoading: _locationController.isStatesLoading,
                    onSelectionChanged: (value) => _locationController.selectState(value),
                    getId: (s) => s.id.toString(),
                    getName: (s) => s.name,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleSelectionDropdown<DistrictModel>(
                    title: 'City',
                    selectedValue: _locationController.selectedDistrict,
                    items: _locationController.districtModels,
                    isLoading: _locationController.isDistrictsLoading,
                    isActive: _locationController.selectedState != null,
                    onSelectionChanged: (value) => _locationController.selectDistrict(value),
                    getId: (s) => s.id.toString(),
                    getName: (s) => s.name,
                  ),
                ),
              ],
            )),
            
            const SizedBox(height: 30),

            // Interests Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: AppColors.accent),
                    SizedBox(width: 8),
                    AppText(
                      title: 'Your Interests',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const AppText(
                  title: 'Select categories that interest you to personalize your experience.',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 20),
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
              ],
            ),

            const SizedBox(height: 50),

            // Save Button
            Obx(() => CustomButton(
              text: 'Save Changes',
              height: 48,
              borderRadius: 12,
              backgroundColor: AppColors.accent,
              isLoading: _profileController.isSubmitting,
              onPressed: () async {
                final success = await _profileController.updateProfile(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  stateId: _locationController.selectedState?.id,
                  districtId: _locationController.selectedDistrict?.id,
                );
                
                if (success) {
                  Navigator.pop(context);
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final user = _profileController.currentUser;
    if (user == null || user.name == null || user.name!.isEmpty) return 'U';
    
    List<String> names = user.name!.split(" ");
    if (names.length > 1) {
      return (names[0][0] + names[1][0]).toUpperCase();
    }
    return names[0][0].toUpperCase();
  }
}

