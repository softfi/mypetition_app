import 'package:get/get.dart';
import 'package:my_petition_app/core/service/storage/storage_service.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final _isInitialized = false.obs;
  bool get isInitialized => _isInitialized.value;

  Future<void> initialize() async {
    // Simulate initialization (loading config, checking auth, etc.)
    await Future.delayed(const Duration(seconds: 3));

    _isInitialized.value = true;

    if (_storageService.isUserLoggedIn()) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
