import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_number_input_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/location/screens/enter_location_screen.dart';
import '../../features/auth/screens/enter_details_screen.dart';
import '../../features/navigation/main_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String otpInput = '/otp-input';
  static const String otpVerify = '/otp-verify';
  static const String location = '/location';
  static const String enterDetails = '/enter-details';
  static const String main = '/main';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case otpInput:
        return _buildRoute(const OtpNumberInputScreen(), settings);
      case otpVerify:
        return _buildRoute(const OtpVerifyScreen(), settings);
      case location:
        return _buildRoute(const EnterLocationScreen(), settings);
      case enterDetails:
        return _buildRoute(const EnterDetailsScreen(), settings);
      case main:
        return _buildRoute(const MainShell(), settings);
      default:
        return _buildRoute(const SplashScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
