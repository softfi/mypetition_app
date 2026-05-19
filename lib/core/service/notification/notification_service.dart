import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/service/storage/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';

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
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(details.payload!));
            _handleNotificationClick(data);
          } catch (e) {
            debugPrint("Error parsing notification payload JSON: $e");
          }
        }
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
    // Check initial message if app was opened from terminated state
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        printNotificationPayload('TERMINATED_LAUNCH', message);
        _handleNotificationClick(message.data);
      }
    });

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      printNotificationPayload('FOREGROUND', message);
      _showLocalNotification(message);
    });

    // Handle background/terminated state click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printNotificationPayload('CLICKED_FROM_BACKGROUND', message);
      _handleNotificationClick(message.data);
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
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    try {
      debugPrint("Handling notification click with data: $data");
      
      // 1. Prioritize news_slug or slug for news redirection
      if (data.containsKey('news_slug') && data['news_slug'] != null && data['news_slug'].toString().isNotEmpty) {
        final newsSlug = data['news_slug'].toString();
        debugPrint("Navigating to news detail for slug: $newsSlug");
        
        Get.toNamed(
          AppRoutes.newsDetail,
          arguments: newsSlug,
        );
        return;
      } else if (data.containsKey('slug') && data['slug'] != null && data['slug'].toString().isNotEmpty) {
        final slug = data['slug'].toString();
        debugPrint("Navigating to detail for slug: $slug");
        
        Get.toNamed(
          AppRoutes.newsDetail,
          arguments: slug,
        );
        return;
      }

      // 2. Check for news_id (fallback to slug using local cache/newsList lookup)
      if (data.containsKey('news_id') && data['news_id'] != null) {
        final String newsIdStr = data['news_id'].toString();
        final int? newsId = int.tryParse(newsIdStr);
        debugPrint("FCM payload has news_id: $newsIdStr");
        
        if (newsId != null && Get.isRegistered<DiscoverController>()) {
          final discoverController = Get.find<DiscoverController>();
          final index = discoverController.newsList.indexWhere((e) => e.id == newsId);
          if (index != -1) {
            final cachedSlug = discoverController.newsList[index].slug;
            debugPrint("Resolved slug from local newsList cache: $cachedSlug");
            
            Get.toNamed(
              AppRoutes.newsDetail,
              arguments: cachedSlug,
            );
            return;
          }
        }
        
        // If not in cache, fallback to passing ID as a string parameter
        debugPrint("News ID $newsIdStr not in local cache, routing with ID directly as slug parameter");
        Get.toNamed(
          AppRoutes.newsDetail,
          arguments: newsIdStr,
        );
        return;
      }

      // 3. Check for petition_slug
      if (data.containsKey('petition_slug') && data['petition_slug'] != null) {
        final petitionSlug = data['petition_slug'].toString();
        debugPrint("Navigating to petition detail for slug: $petitionSlug");
        
        Get.toNamed(
          AppRoutes.petitionDetail,
          arguments: petitionSlug,
        );
        return;
      }

      // Default: If no recognizable keys, fallback to main shell
      debugPrint("No recognizable notification keys, navigating to Main Shell");
      Get.offAllNamed(AppRoutes.main);
      
    } catch (e) {
      debugPrint("Error handling notification click: $e");
    }
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

// Reusable Top-Level Helper to Print Notifications beautifully in Highlighted JSON format
void printNotificationPayload(String state, RemoteMessage message) {
  try {
    final Map<String, dynamic> payloadMap = {
      'state': state,
      'messageId': message.messageId,
      'from': message.from,
      'collapseKey': message.collapseKey,
      'sentTime': message.sentTime?.toIso8601String(),
      'notification': message.notification != null
          ? {
              'title': message.notification?.title,
              'body': message.notification?.body,
            }
          : null,
      'data': message.data,
    };

    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String prettyJson = encoder.convert(payloadMap);

    debugPrint('\n');
    debugPrint('╔══════════════════════════════════════════════════════════════════════════╗');
    debugPrint('║ 🔥 FIREBASE NOTIFICATION RECEIVED [$state] 🔥');
    debugPrint('╠══════════════════════════════════════════════════════════════════════════╣');
    prettyJson.split('\n').forEach((line) {
      debugPrint('║ $line');
    });
    debugPrint('╚══════════════════════════════════════════════════════════════════════════╝');
    debugPrint('\n');
  } catch (e) {
    debugPrint("Error formatting notification payload: $e");
    debugPrint("FCM Payload fallback ($state): ${message.data}");
  }
}
