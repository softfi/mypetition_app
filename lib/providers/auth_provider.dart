import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _phoneNumber = '';
  String _otp = '';
  bool _isLoading = false;
  bool _isOtpSent = false;

  // Getters
  String get phoneNumber => _phoneNumber;
  String get otp => _otp;
  bool get isLoading => _isLoading;
  bool get isOtpSent => _isOtpSent;

  // Set phone number
  void setPhoneNumber(String number) {
    _phoneNumber = number;
    notifyListeners();
  }

  // Set OTP
  void setOtp(String otp) {
    _otp = otp;
    notifyListeners();
  }

  // Send OTP (simulated)
  Future<void> sendOtp() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _isOtpSent = true;
    _isLoading = false;
    notifyListeners();
  }

  // Verify OTP (simulated)
  Future<bool> verifyOtp() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();

    // For demo, always return true
    return true;
  }

  // Resend OTP
  Future<void> resendOtp() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _phoneNumber = '';
    _otp = '';
    _isLoading = false;
    _isOtpSent = false;
    notifyListeners();
  }
}
