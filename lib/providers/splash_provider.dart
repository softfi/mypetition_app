import 'package:flutter/material.dart';

class SplashProvider extends ChangeNotifier {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize(BuildContext context) async {
    // Simulate initialization (loading config, checking auth, etc.)
    await Future.delayed(const Duration(seconds: 3));

    _isInitialized = true;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
