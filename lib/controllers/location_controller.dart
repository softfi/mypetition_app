import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/features/location/models/location_models.dart';
import 'package:my_petition_app/core/service/storage/storage_service.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';
import 'package:my_petition_app/features/auth/models/user_model.dart';

class LocationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final _states = <StateModel>[].obs;
  final _districts = <DistrictModel>[].obs;
  
  final _selectedState = Rxn<StateModel>();
  final _selectedDistrict = Rxn<DistrictModel>();
  
  final _isStatesLoading = false.obs;
  final _isDistrictsLoading = false.obs;
  final _isSubmitting = false.obs;

  // Getters
  List<StateModel> get stateModels => _states;
  List<DistrictModel> get districtModels => _districts;
  
  StateModel? get selectedState => _selectedState.value;
  DistrictModel? get selectedDistrict => _selectedDistrict.value;
  
  bool get isStatesLoading => _isStatesLoading.value;
  bool get isDistrictsLoading => _isDistrictsLoading.value;
  bool get isSubmitting => _isSubmitting.value;

  @override
  void onInit() {
    super.onInit();
    fetchStates();
  }

  // Fetch States from API
  Future<void> fetchStates() async {
    if (_states.isNotEmpty || _isStatesLoading.value) return;
    _isStatesLoading.value = true;
    try {
      final response = await _apiService.get(AppUrls.states);
      if (response != null && response.data['success'] == true) {
        final List data = response.data['data'];
        _states.value = data.map((json) => StateModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.log("Error fetching states: $e");
    } finally {
      _isStatesLoading.value = false;
    }
  }

  // Fetch Districts from API based on state_id
  Future<void> fetchDistricts(int stateId) async {
    if (_isDistrictsLoading.value) return;
    _isDistrictsLoading.value = true;
    _districts.clear();
    try {
      final response = await _apiService.get(
        AppUrls.districts,
        queryParameters: {'state_id': stateId},
      );
      if (response != null && response.data['success'] == true) {
        final List data = response.data['data'];
        _districts.value = data.map((json) => DistrictModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.log("Error fetching districts: $e");
    } finally {
      _isDistrictsLoading.value = false;
    }
  }

  // Select state
  Future<void> selectState(StateModel? state) async {
    if (_selectedState.value?.id == state?.id) return;
    
    _selectedState.value = state;
    _selectedDistrict.value = null; // Reset district when state changes
    
    if (state != null) {
      await fetchDistricts(state.id);
    }
  }

  // Select district
  void selectDistrict(DistrictModel? district) {
    _selectedDistrict.value = district;
  }

  // Submit location
  Future<bool> submitLocation() async {
    if (_selectedState.value == null || _selectedDistrict.value == null) {
      CommonToast.showToastError("Please select state and district");
      return false;
    }

    final user = _storageService.getUserData();
    if (user == null || user.id == null) {
      CommonToast.showToastError("User not found. Please log in again.");
      return false;
    }

    _isSubmitting.value = true;
    try {
      final response = await _apiService.post(
        AppUrls.updateLocation,
        data: {
          "userId": user.id,
          "state_id": _selectedState.value!.id,
          "district_id": _selectedDistrict.value!.id,
        },
      );

      if (response != null && response.data['success'] == true) {
        CommonToast.showToastSuccess(response.data['message'] ?? "Location updated successfully");
        
        // Update local user data if necessary
        final updatedUserData = response.data['data'];
        if (updatedUserData != null) {
           final updatedUser = user.copyWith(
            stateId: updatedUserData['state_id'],
            cityId: updatedUserData['city_id'],
          );
          await _storageService.saveUserData(updatedUser.toJson());
        }

        return true;
      } else {
        CommonToast.showToastError(response?.data['message'] ?? "Failed to update location");
        return false;
      }
    } catch (e) {
      CommonToast.showToastError("An error occurred. Please try again.");
      return false;
    } finally {
      _isSubmitting.value = false;
    }
  }

  // Reset
  void reset() {
    _selectedState.value = null;
    _selectedDistrict.value = null;
    _districts.clear();
    _isStatesLoading.value = false;
    _isDistrictsLoading.value = false;
    _isSubmitting.value = false;
  }
}

extension on UserModel {
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? mobile,
    String? token,
    int? stateId,
    int? cityId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      token: token ?? this.token,
      stateId: stateId ?? this.stateId,
      cityId: cityId ?? this.cityId,
    );
  }
}
