import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/controllers/splash_controller.dart';

class DeepLinkService extends GetxService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  Uri? pendingUri;

  bool get hasPendingDeepLink => pendingUri != null;

  Future<DeepLinkService> init() async {
    // 1. Handle app launch from a terminated state via a link
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        // Delay slightly to ensure navigation stack is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(uri);
        });
      }
    } catch (e) {
      debugPrint('Error getting initial deep link: $e');
    }

    // 2. Handle links when app is running in the background/foreground
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint('Deep Link listener error: $err');
      },
    );

    return this;
  }

  void handlePendingDeepLink() {
    if (pendingUri != null) {
      final uri = pendingUri!;
      pendingUri = null;
      _handleDeepLink(uri);
    }
  }

  void _handleDeepLink(Uri uri) {
    final splashController = Get.isRegistered<SplashController>() ? Get.find<SplashController>() : null;
    final isAppInitialized = splashController?.isInitialized ?? true;

    if (!isAppInitialized) {
      pendingUri = uri;
      debugPrint('Deferred deep link processing (app not initialized): $uri');
      return;
    }

    debugPrint('Processing Incoming Deep Link: $uri');
    
    final pathSegments = uri.pathSegments;
    if (pathSegments.isEmpty) return;

    final type = pathSegments[0]; // e.g. "news" or "petition"
    if (pathSegments.length < 2) return;
    
    // In case the slug is path-like, join remaining segments
    final slug = pathSegments.sublist(1).join('/');

    if (type == 'news') {
      Get.toNamed(AppRoutes.newsDetail, arguments: slug);
    } else if (type == 'petition' || type == 'petitions') {
      Get.toNamed(AppRoutes.petitionDetail, arguments: slug);
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
