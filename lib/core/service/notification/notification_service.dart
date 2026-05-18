import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/service/storage/storage_service.dart';
import 'package:flutter/foundation.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  late FlutterLocalNotificationsPlugin _localNotifications;

  Future<NotificationService> init() async {
    await _initializeLocalNotifications();
    await _requestPermissions();
    _configureMessaging();
    return this;
  }

  Future<void> _initializeLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint("Notification tapped: ${details.payload}");
      },
    );
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  void _configureMessaging() {
    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message received: ${message.notification?.title}");
      _showLocalNotification(message);
    });

    // Handle background/terminated state click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification opened from background: ${message.data}");
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: details,
      payload: message.data.toString(),
    );
  }

  Future<String?> getFcmToken() async {
    try {
      String? token = await _fcm.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  Future<void> saveTokenToBackend() async {
    // Only save if user is logged in (has token)
    final authToken = await _storageService.getAuthToken();
    if (authToken == null || authToken.isEmpty) {
      debugPrint("Skipping FCM token save: User not logged in");
      return;
    }
































    String? fcmToken = await getFcmToken();
    if (fcmToken == null) return;

    try {
      final response = await _apiService.post(
        AppUrls.saveFcmToken,
        data: {
          "token": fcmToken,
          "device_type": "app",
        },
      );

      if (response != null && response.data['success'] == true) {
        debugPrint("FCM token saved successfully to backend");
      }
    } catch (e) {
      debugPrint("Error saving FCM token to backend: $e");
    }
  }
}
