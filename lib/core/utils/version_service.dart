// lib/core/services/version_service.dart
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static Future<String> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return "1.0.0"; // Fallback version
    }
  }

  static Future<String> getBuildNumber() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber;
    } catch (e) {
      return "1";
    }
  }

  static Future<Map<String, String>> getAllPackageInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return {
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
      };
    } catch (e) {
      return {
        'version': '1.0.0',
        'buildNumber': '1',
        'appName': 'Contrast App',
        'packageName': 'com.contrast.app',
      };
    }
  }
}
