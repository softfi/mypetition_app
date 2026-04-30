import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:get/get.dart';
import 'dart:io';

class ConnectivityController extends GetxController {
  static ConnectivityController get to => Get.find<ConnectivityController>();

  final RxBool isConnected = true.obs;
  bool _wasDisconnected = false;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitial();
    _subscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    await _verify(result, isInitial: true);
  }

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    await _verify(results);
  }

  Future<void> _verify(List<ConnectivityResult> results, {bool isInitial = false}) async {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      isConnected.value = false;
      _wasDisconnected = true;
      return;
    }

    // Verify actual internet access via DNS
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      final hasInternet = lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;

      if (hasInternet) {
        isConnected.value = true;

        // ✅ Agar pehle disconnect tha aur ab connected hua → splash pe jaao
        if (_wasDisconnected && !isInitial) {
          _wasDisconnected = false;
          await Future.delayed(const Duration(milliseconds: 300));
          Get.offAllNamed(AppRoutes.splash);
        }
      } else {
        isConnected.value = false;
        _wasDisconnected = true;
      }
    } catch (_) {
      isConnected.value = false;
      _wasDisconnected = true;
    }
  }
}
