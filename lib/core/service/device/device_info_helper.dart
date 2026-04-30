import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../utils/app_logger.dart';
import '../storage/storage_service.dart';
import 'package:android_id/android_id.dart';




class DeviceInfoHelper {
  static final DeviceInfoHelper _instance = DeviceInfoHelper._internal();
  factory DeviceInfoHelper() => _instance;
  DeviceInfoHelper._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final StorageService _storageService = StorageService();

  /// Generate or get existing device ID
  Future<String> getDeviceId() async {
    await DeviceInfoHelper().printFullAndroidDeviceInfo();

    try {
      // Ensure storage initialized
      // (Make sure initialize() app start me call ho raha ho)

      // Check existing
      String? existingDeviceId =
      _storageService.getString(_storageService.deviceIdKey);

      if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
        return existingDeviceId;
      }

      String newDeviceId;

      if (kIsWeb) {
        newDeviceId = await _generateWebDeviceId();
      } else if (Platform.isAndroid) {
        newDeviceId = await _generateAndroidDeviceId();
      } else if (Platform.isIOS) {
        newDeviceId = await _generateIOSDeviceId();
      } else {
        newDeviceId = const Uuid().v4();
      }

      /// ✅ SAVE DEVICE ID
      await _storageService.setString(
        _storageService.deviceIdKey,
        newDeviceId,
      );

      /// ✅ SAVE DEVICE TYPE
      await _storageService.setString(
        _storageService.deviceTypeKey,
        getDeviceType(),
      );

      return newDeviceId;
    } catch (e) {


      throw "$e";
    }
  }

  /// 🔍 Debug: Print all Android device info
  Future<void> printFullAndroidDeviceInfo() async {
    if (!Platform.isAndroid) {
      debugPrint("❌ Not an Android device");
      return;
    }

    try {
      final androidInfo = await _deviceInfo.androidInfo;

      debugPrint("========== ANDROID DEVICE INFO ==========");

      debugPrint("🔹 ID: ${androidInfo.id}");
      debugPrint(androidInfo.data.toString());
      // debugPrint("🔹 Android ID: ${androidInfo.androidId}");
      debugPrint("🔹 Brand: ${androidInfo.brand}");
      debugPrint("🔹 Model: ${androidInfo.model}");
      debugPrint("🔹 Device: ${androidInfo.device}");
      debugPrint("🔹 Product: ${androidInfo.product}");
      debugPrint("🔹 Hardware: ${androidInfo.hardware}");
      debugPrint("🔹 Manufacturer: ${androidInfo.manufacturer}");
      debugPrint("🔹 Board: ${androidInfo.board}");
      debugPrint("🔹 Bootloader: ${androidInfo.bootloader}");
      debugPrint("🔹 Display: ${androidInfo.display}");
      debugPrint("🔹 Fingerprint: ${androidInfo.fingerprint}");
      debugPrint("🔹 Host: ${androidInfo.host}");
      debugPrint("🔹 Tags: ${androidInfo.tags}");
      debugPrint("🔹 Type: ${androidInfo.type}");
      debugPrint("🔹 Is Physical Device: ${androidInfo.isPhysicalDevice}");

      debugPrint("----- VERSION INFO -----");
      debugPrint("🔹 Version Release: ${androidInfo.version.release}");
      debugPrint("🔹 SDK Int: ${androidInfo.version.sdkInt}");
      debugPrint("🔹 Incremental: ${androidInfo.version.incremental}");
      debugPrint("🔹 Codename: ${androidInfo.version.codename}");
      debugPrint("🔹 Base OS: ${androidInfo.version.baseOS}");
      debugPrint("🔹 Security Patch: ${androidInfo.version.securityPatch}");

      debugPrint("=========================================");

    } catch (e) {
      debugPrint("❌ Error fetching Android device info: $e");
    }
  }


  /// Generate Android device ID
  Future<String> _generateAndroidDeviceId() async {
    try {
      const androidIdPlugin = AndroidId();
      final androidId = await androidIdPlugin.getId();

      debugPrint("📱 RAW ANDROID_ID: $androidId");

      if (androidId != null && androidId.isNotEmpty) {
        debugPrint("✅ FINAL DEVICE ID (Android): $androidId");
        return androidId;
      }

      final fallback = const Uuid().v4();
      debugPrint("⚠️ Fallback UUID Generated: $fallback");
      return fallback;

    } catch (e) {
      final fallback = const Uuid().v4();
      debugPrint("❌ Error getting Android ID: $e");
      debugPrint("⚠️ Fallback UUID Generated: $fallback");
      return fallback;
    }
  }




  // Future<String> _generateAndroidDeviceId() async {
  //
  //   try {
  //     final androidInfo = await _deviceInfo.androidInfo;
  //     final androidId =
  //     androidInfo.data['android_id']?.toString();
  //
  //     debugPrint("ANDROID_ID: $androidId");
  //
  //     final combinedId =
  //         "${androidInfo.brand}_"
  //         "${androidInfo.manufacturer}_"
  //         "${androidInfo.model}_"
  //         "${androidInfo.device}_"
  //         "${androidInfo.board}_"
  //         "${androidInfo.hardware}_"
  //         "${androidInfo.isPhysicalDevice}";
  //
  //     return combinedId ?? const Uuid().v4();
  //     // return androidInfo.id ?? const Uuid().v4();
  //   } catch (e) {
  //     Logger.e('Error getting Android device ID', error: e);
  //     return const Uuid().v4();
  //   }
  // }


  /// Generate iOS device ID
  Future<String> _generateIOSDeviceId() async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;
      // Use identifierForVendor (unique for each app installation)
      return iosInfo.identifierForVendor ?? const Uuid().v4();
    } catch (e) {
      Logger.e('Error getting iOS device ID',  error: e);
      return const Uuid().v4();
    }
  }

  /// Generate Web device ID
  Future<String> _generateWebDeviceId() async {
    try {
      final webInfo = await _deviceInfo.webBrowserInfo;
      // Combine user agent and other info to create unique ID
      final userAgent = webInfo.userAgent ?? '';
      final vendor = webInfo.vendor ?? '';
      final platform = webInfo.platform ?? '';

      // Create hash or use UUID
      return const Uuid().v5(
        Uuid.NAMESPACE_URL,
        '$userAgent-$vendor-$platform',
      );
    } catch (e) {
      Logger.e('Error getting Web device ID', error: e);
      return const Uuid().v4();
    }
  }

  /// Get device type
  String getDeviceType() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else {
      return 'unknown';
    }
  }

  /// Get detailed device info
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        return {
          'device_type': 'web',
          'browser': webInfo.browserName.name,
          'platform': webInfo.platform ?? 'unknown',
          'user_agent': webInfo.userAgent ?? 'unknown',
        };
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'device_type': 'android',
          'device_id': androidInfo.id,
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt.toString(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'device_type': 'ios',
          'device_id': iosInfo.identifierForVendor ?? 'unknown',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'system_version': iosInfo.systemVersion,
        };
      } else {
        return {
          'device_type': getDeviceType(),
        };
      }
    } catch (e) {
      Logger.e('Error getting device info', error: e);
      return {
        'device_type': getDeviceType(),
      };
    }
  }
}
