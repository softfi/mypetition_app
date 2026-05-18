
// https://api.mypetition.co/api/v1/public/states

class AppUrls {
  static const String baseUrl = 'https://api.mypetition.co/api/v1';
  static const String webBaseUrl = 'https://mypetition.co';


  static const String states = '/public/states';
  static const String districts = '/public/districts';
  static const String signup = '/public/auth/signup';
  static const String login = '/public/auth/login';
  static const String verify = '/public/auth/verify';
  static const String updateLocation = '/public/update-user-location';
  static const String updateProfile = '/public/user/profile';
  static const String news = '/public/news';
  static const String insights = '/public/insights';
  static const String petitions = '/public/petitions';
  static const String categories = '/public/categories';
  static const String sendEmailOtp = '/public/send-email-otp';
  static const String verifyEmailOtp = '/public/verify-email-otp';
  static String votePetition(int id) => '/public/petitions/$id/vote';
  static const String s3BaseUrl = 'https://petition-prod.s3.ap-south-1.amazonaws.com';
  static const String saveFcmToken = '/public/user/fcms';
  static const String userPetitions = '/public/user/petitions';
  static const String feed = '/public/feed';
  static String saveNews(int id) => '/public/news/$id/save';
  static String newsSaveStatus(int id) => '/public/news/$id/save-status';
  static const String savedNews = '/public/user/news/saved';
}





