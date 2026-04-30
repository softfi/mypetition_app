import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/service/storage/storage_service.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';
import 'package:my_petition_app/features/auth/models/user_model.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/core/service/notification/notification_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final _phoneNumber = ''.obs;
  final _otp = ''.obs;
  final _isLoading = false.obs;
  final _isOtpSent = false.obs;
  final _isLogin = false.obs;
  final _isGuest = false.obs;
  final _isEmailOtpSent = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Save FCM token if already logged in
    Get.find<NotificationService>().saveTokenToBackend();
  }

  // Getters
  String get phoneNumber => _phoneNumber.value;
  String get otp => _otp.value;
  bool get isLoading => _isLoading.value;
  bool get isOtpSent => _isOtpSent.value;
  bool get isLogin => _isLogin.value;
  bool get isGuest => _isGuest.value;
  bool get isEmailOtpSent => _isEmailOtpSent.value;

  // Email Verification Logic
  Future<bool> sendEmailOtp(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      CommonToast.showToastError("Please enter a valid email");
      return false;
    }

    _isLoading.value = true;
    try {
      final response = await _apiService.post(
        AppUrls.sendEmailOtp,
        data: {"email": email},
      );

      if (response != null && response.data['success'] == true) {
        _isEmailOtpSent.value = true;
        CommonToast.showToastSuccess(response.data['message'] ?? "OTP sent to email");
        return true;
      } else {
        CommonToast.showToastError(response?.data['message'] ?? "Failed to send OTP");
        return false;
      }
    } catch (e) {
      CommonToast.showToastError("An error occurred");
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> verifyEmailOtp(String emailOtp) async {
    if (emailOtp.isEmpty) {
      CommonToast.showToastError("Please enter OTP");
      return false;
    }

    _isLoading.value = true;
    try {
      final response = await _apiService.post(
        AppUrls.verifyEmailOtp,
        data: {"otp": emailOtp},
      );

      if (response != null && response.data['success'] == true) {
        CommonToast.showToastSuccess(response.data['message'] ?? "Email verified successfully");
        
        // 1. Refresh profile to get verified status
        final profileController = Get.find<ProfileController>();
        await profileController.fetchProfile();

        // 2. Refresh all discover content (Petitions, News, etc.)
        final discoverController = Get.find<DiscoverController>();
        await discoverController.refreshAll();

        // 3. Navigate to Main Home with full state refresh
        Get.offAllNamed(AppRoutes.main);
        
        return true;
      } else {
        CommonToast.showToastError(response?.data['message'] ?? "Invalid OTP");
        return false;
      }
    } catch (e) {
      CommonToast.showToastError("Verification failed");
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Skip Login (Guest Mode)
  void skipAuth() {
    _isGuest.value = true;
    _storageService.saveAuthToken(''); // Clear token for guest
    Get.offAllNamed(AppRoutes.main);
  }

  // Setters
  void setPhoneNumber(String number) {
    _phoneNumber.value = number;
  }

  void setOtp(String otpValue) {
    _otp.value = otpValue;
  }

  void setIsLogin(bool value) {
    _isLogin.value = value;
  }

  // Request OTP (Login or Signup)
  Future<bool> requestOtp() async {
    if (_phoneNumber.value.isEmpty) {
      CommonToast.showToastError("Please enter mobile number");
      return false;
    }

    _isLoading.value = true;
    try {
      final endpoint = _isLogin.value ? AppUrls.login : AppUrls.signup;
      
      final response = await _apiService.post(
        endpoint,
        data: {"mobile": _phoneNumber.value},
      );

      if (response != null && response.data['success'] == true) {
        _isOtpSent.value = true;
        CommonToast.showToastSuccess(response.data['message'] ?? "OTP sent successfully");
        return true;
      } else {
        CommonToast.showToastError(response?.data['message'] ?? "Failed to send OTP");
        return false;
      }
    } catch (e) {
      CommonToast.showToastError("An error occurred. Please try again.");
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Backward compatibility (keeping sendOtp but calling requestOtp)
  Future<bool> sendOtp() async {
    return await requestOtp();
  }

  // Verify OTP
  Future<bool> verifyOtp() async {
    if (_otp.value.isEmpty) {
      CommonToast.showToastError("Please enter OTP");
      return false;
    }

    _isLoading.value = true;
    try {
      final response = await _apiService.post(
        AppUrls.verify,
        data: {
          "mobile": _phoneNumber.value,
          "otp": _otp.value,
        },
      );

      if (response != null && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final userJson = data['user'];
        
        // Save token to storage
        await _storageService.saveAuthToken(token);
        
        // Save FCM token to backend
        Get.find<NotificationService>().saveTokenToBackend();
        
        // Create user model and save
        final user = UserModel.fromJson({...userJson, 'token': token});
        await _storageService.saveUserData(user.toJson());
        
        CommonToast.showToastSuccess(response.data['message'] ?? "Verified successfully");
        
        _isLoading.value = false;
        
        // Navigate based on flow (Login vs Signup)
        _isGuest.value = false;
        
        // Global Refresh all data after login
        await refreshAppGlobalData();

        if (_isLogin.value) {
          // For Login, go straight to Dashboard
          Get.offAllNamed(AppRoutes.main);
        } else {
          // For Signup, if name is missing, go to location flow
          if (user.name == null || user.name!.isEmpty) {
            Get.offAllNamed(AppRoutes.location);
          } else {
            Get.offAllNamed(AppRoutes.main);
          }
        }
        
        return true;
      } else {
        CommonToast.showToastError(response?.data['message'] ?? "Invalid OTP");
        return false;
      }
    } catch (e) {
      CommonToast.showToastError("Verification failed. Please try again.");
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    await sendOtp();
  }

  // Reset state
  void reset() {
    _phoneNumber.value = '';
    _otp.value = '';
    _isLoading.value = false;
    _isOtpSent.value = false;
  }

  // Global Refresh after login/signup
  Future<void> refreshAppGlobalData() async {
    try {
      // 1. Refresh Profile
      if (Get.isRegistered<ProfileController>()) {
        await Get.find<ProfileController>().refreshAll();
      }
      
      // 2. Refresh Discover Content
      if (Get.isRegistered<DiscoverController>()) {
        await Get.find<DiscoverController>().refreshAll();
      }
      
      Get.log("✅ Global App Data Refreshed after Login");
    } catch (e) {
      Get.log("❌ Error during global refresh: $e");
    }
  }
}
