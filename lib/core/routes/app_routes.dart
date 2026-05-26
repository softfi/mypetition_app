import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_number_input_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/location/screens/enter_location_screen.dart';
import '../../features/auth/screens/enter_details_screen.dart';
import '../../features/navigation/main_shell.dart';
import '../../features/discover/news_detail_screen.dart';
import '../../features/discover/news_view_all_screen.dart';
import '../../features/discover/insights_view_all_screen.dart';
import '../../features/discover/insight_detail_screen.dart';
import '../../features/discover/insight_reels_screen.dart';
import '../../features/discover/petitions_view_all_screen.dart';
import '../../features/discover/petition_detail_screen.dart';
import '../../features/auth/screens/email_verify_screen.dart';
import '../../features/profile/saved_petitions_screen.dart';
import '../../features/search/search_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String otpInput = '/otp-input';
  static const String otpVerify = '/otp-verify';
  static const String location = '/location';
  static const String enterDetails = '/enter-details';
  static const String main = '/main';
  static const String newsDetail = '/news-detail';
  static const String emailVerify = '/email-verify';
  static const String newsViewAll = '/news-view-all';
  static const String insightsViewAll = '/insights-view-all';
  static const String insightDetail = '/insight-detail';
  static const String insightReels = '/insight-reels';
  static const String petitionsViewAll = '/petitions-view-all';
  static const String petitionDetail = '/petition-detail';
  static const String savedPetitions = '/saved-petitions';
  static const String search = '/search';

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
      case newsDetail:
        return _buildRoute(const NewsDetailScreen(), settings);
      case emailVerify:
        return _buildRoute(const EmailVerifyScreen(), settings);
      case newsViewAll:
        return _buildRoute(const NewsViewAllScreen(), settings);
      case insightsViewAll:
        return _buildRoute(const InsightsViewAllScreen(), settings);
      case insightDetail:
        return _buildRoute(const InsightDetailScreen(), settings);
      case insightReels:
        return _buildRoute(const InsightReelsScreen(), settings);
      case petitionsViewAll:
        return _buildRoute(const PetitionsViewAllScreen(), settings);
      case petitionDetail:
        return _buildRoute(const PetitionDetailScreen(), settings);
      case savedPetitions:
        return _buildRoute(const SavedPetitionsScreen(), settings);
      case search:
        return _buildRoute(const SearchScreen(), settings);
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
