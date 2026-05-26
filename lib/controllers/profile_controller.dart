import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:flutter/material.dart';
import 'package:my_petition_app/core/utils/image_picker_service.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/service/storage/storage_service.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';
import 'package:my_petition_app/features/auth/models/user_model.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/core/models/petition_model.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  final _currentUser = Rxn<UserModel>();
  final _profileImage = Rxn<File>();
  final _isProfileLoading = false.obs;
  final _isSubmitting = false.obs;
  final _selectedCategoryIds = <int>[].obs;

  // User Petitions
  final _userPetitions = <PetitionModel>[].obs;
  final _isLoadingUserPetitions = false.obs;
  final _currentPage = 1.obs;
  final _totalPages = 1.obs;
  final _totalItems = 0.obs;

  UserModel? get currentUser => _currentUser.value;
  File? get profileImage => _profileImage.value;
  bool get isProfileLoading => _isProfileLoading.value;
  bool get isSubmitting => _isSubmitting.value;
  List<int> get selectedCategoryIds => _selectedCategoryIds;

  List<PetitionModel> get userPetitions => _userPetitions;
  bool get isLoadingUserPetitions => _isLoadingUserPetitions.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get totalItems => _totalItems.value;

  @override
  void onInit() {
    super.onInit();
    _currentUser.value = _storageService.getUserData();
    fetchProfile();
    fetchUserPetitions(refresh: true);
  }

  // Fetch Profile API
  Future<void> fetchProfile() async {
    _isProfileLoading.value = true;
    try {
      final response = await _apiService.get(AppUrls.updateProfile);
      if (response != null && response.data['success'] == true) {
        final data = response.data['data'];
        final token = await _storageService.getAuthToken();
        final user = UserModel.fromJson({...data, 'token': token});
        
        _currentUser.value = user;
        await _storageService.saveUserData(user.toJson());

        // Initialize selected category IDs
        if (data['category_ids'] != null) {
          final List ids = data['category_ids'];
          _selectedCategoryIds.assignAll(
            ids.map((e) => int.tryParse(e.toString()) ?? 0).where((id) => id != 0).toList(),
          );
        } else if (data['interestCategories'] != null) {
          final List categories = data['interestCategories'];
          _selectedCategoryIds.assignAll(
            categories.map((e) => int.tryParse(e['id'].toString()) ?? 0).where((id) => id != 0).toList(),
          );
        }
      }
    } catch (e) {
      Get.log("Error fetching profile: $e");
    } finally {
      _isProfileLoading.value = false;
    }
  }

  // Refresh all profile data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchProfile(),
      fetchUserPetitions(refresh: true),
    ]);
  }

  // Pick profile image
  Future<void> pickProfileImage(BuildContext context) async {
    final File? image = await _imagePickerService.showImageSourceBottomSheet(context);
    if (image != null) {
      _profileImage.value = image;
      Get.log("✅ Profile image updated: ${image.path}");
    }
  }

  // Toggle category selection
  void toggleCategory(int categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.remove(categoryId);
    } else {
      _selectedCategoryIds.add(categoryId);
    }
  }

  // Clear image
  Future<bool> updateProfile({
    String? firstName,
    String? middleName,
    String? lastName,
    String? email,
    int? stateId,
    int? districtId,
  }) async {
    final user = _currentUser.value ?? _storageService.getUserData();
    if (user == null) return false;

    _isSubmitting.value = true;
    try {
      // Build FormData for multipart support (profile_image as binary)
      final formFields = <String, dynamic>{
        "first_name": firstName ?? "",
        "middle_name": middleName ?? "",
        "last_name": lastName ?? "",
      };

      if (email != null && email.isNotEmpty) {
        formFields["email"] = email;
      }

      if (user.mobile != null && user.mobile!.isNotEmpty) {
        formFields["mobile"] = user.mobile;
      }

      // Only send state and district if they are valid IDs (> 0)
      final int? sId = stateId ?? user.stateId;
      final int? dId = districtId ?? user.cityId;

      if (sId != null && sId > 0) {
        formFields["state_id"] = sId.toString();
      }
      if (dId != null && dId > 0) {
        formFields["district_id"] = dId.toString();
      }

      // Add category_ids as a list of strings
      final formData = FormData();
      for (final entry in formFields.entries) {
        formData.fields.add(MapEntry(entry.key, entry.value.toString()));
      }
      for (final id in _selectedCategoryIds) {
        formData.fields.add(MapEntry("category_ids[]", id.toString()));
      }

      // Attach profile image if selected
      if (_profileImage.value != null) {
        formData.files.add(MapEntry(
          "profile_image",
          await MultipartFile.fromFile(
            _profileImage.value!.path,
            filename: _profileImage.value!.path.split('/').last,
          ),
        ));
      }

      final response = await _apiService.dio.put(
        AppUrls.updateProfile,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.data != null && response.data['success'] == true) {
        CommonToast.showToastSuccess(response.data['message'] ?? "Profile updated successfully");

        // Update local user data
        final updatedUserData = response.data['data'];
        if (updatedUserData != null) {
          final token = await _storageService.getAuthToken();
          final updatedUser = UserModel.fromJson({...updatedUserData, 'token': token});
          _currentUser.value = updatedUser;
          await _storageService.saveUserData(updatedUser.toJson());
          _profileImage.value = null; // Clear selected image after successful upload
        }

        return true;
      } else {
        CommonToast.showToastError(response.data?['message'] ?? "Failed to update profile");
        return false;
      }
    } catch (e) {
      CommonToast.showToastError("An error occurred. Please try again.");
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  // Clear image
  void clearImage() {
    _profileImage.value = null;
  }

  // Professional Logout
  Future<void> logout() async {
    await _storageService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  // Fetch User Petitions API
  Future<void> fetchUserPetitions({bool refresh = false}) async {
    if (refresh) {
      _currentPage.value = 1;
      _userPetitions.clear();
    } else {
      if (_currentPage.value >= _totalPages.value) return;
      _currentPage.value++;
    }

    _isLoadingUserPetitions.value = true;
    try {
      final response = await _apiService.get(
        AppUrls.userPetitions,
        queryParameters: {
          'page': _currentPage.value,
          'limit': 10,
        },
      );

      if (response != null && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        final List<PetitionModel> newPetitions = data.map((e) => PetitionModel.fromJson(e)).toList();
        
        if (refresh) {
          _userPetitions.assignAll(newPetitions);
        } else {
          _userPetitions.addAll(newPetitions);
        }

        final pagination = response.data['pagination'];
        if (pagination != null) {
          _totalPages.value = pagination['totalPages'] ?? 1;
          _totalItems.value = pagination['totalItems'] ?? 0;
        }
      }
    } catch (e) {
      Get.log("Error fetching user petitions: $e");
    } finally {
      _isLoadingUserPetitions.value = false;
    }
  }
}
