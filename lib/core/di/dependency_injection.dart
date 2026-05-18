import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/service/storage/storage_service.dart';
import 'package:my_petition_app/core/service/connectivity/connectivity_controller.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/controllers/location_controller.dart';
import 'package:my_petition_app/controllers/splash_controller.dart';
import 'package:my_petition_app/controllers/profile_controller.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';
import 'package:my_petition_app/controllers/theme_controller.dart';
import 'package:my_petition_app/controllers/home_controller.dart';

import 'package:my_petition_app/core/service/notification/notification_service.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);

    // Feature Controllers
    Get.lazyPut(() => SplashController());
    Get.lazyPut(() => AuthController());
    Get.put<LocationController>(LocationController(), permanent: true);
    Get.put<ProfileController>(ProfileController(), permanent: true);
    Get.put<DiscoverController>(DiscoverController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
    
    // Non-existent controllers (commented out for now)
    // Get.lazyPut(() => ProfileController());
    // Get.lazyPut(() => DashboardController());
    // Get.lazyPut(() => CourseController());
    // Get.lazyPut(() => SubscriptionController());
    // Get.lazyPut(() => NotificationController());
  }
}
