import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/service/storage/storage_service.dart';
import 'core/service/api/api_services.dart';
import 'core/di/dependency_injection.dart';
import 'core/service/notification/notification_service.dart';
import 'package:my_petition_app/controllers/theme_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  printNotificationPayload('BACKGROUND_RECEIVE', message);
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase initialization failed: $e. Make sure you have added google-services.json/GoogleService-Info.plist");
  }
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize Core Services
  Get.put(StorageService(), permanent: true);
  await Get.find<StorageService>().initialize();
  
  Get.put(ApiService(), permanent: true);
  await Get.find<ApiService>().initialize();

  // Initialize Notifications
  Get.put(NotificationService(), permanent: true);
  await Get.find<NotificationService>().init();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure ThemeController is initialized before accessing it
    final themeController = Get.put(ThemeController());
    
    return GetMaterialApp(
      title: 'My Petition',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.theme, 
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialBinding: InitialBindings(),
    );
  }
}
