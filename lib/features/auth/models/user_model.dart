import 'package:my_petition_app/core/service/api/api_sanitizer.dart';

class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? token;
  final int? stateId;
  final int? cityId;
  final String? emailVerifiedAt;
  final bool isMobileVerified;
  final bool isEmailVerified;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? profileImage;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.token,
    this.stateId,
    this.cityId,
    this.emailVerifiedAt,
    this.isMobileVerified = false,
    this.isEmailVerified = false,
    this.firstName,
    this.middleName,
    this.lastName,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if user is nested inside 'user' or 'data'
    final userData = json['user'] ?? json;
    
    return UserModel(
      id: ApiSanitizer.sanitizeInt(userData['id']),
      name: ApiSanitizer.sanitizeString(userData['name']),
      email: ApiSanitizer.sanitizeString(userData['email']),
      mobile: ApiSanitizer.sanitizeString(userData['mobile']),
      token: ApiSanitizer.sanitizeString(json['token']),
      stateId: ApiSanitizer.sanitizeInt(userData['state_id']),
      cityId: ApiSanitizer.sanitizeInt(userData['city_id']),
      emailVerifiedAt: ApiSanitizer.sanitizeString(userData['email_verified_at']),
      isMobileVerified: userData['is_mobile_verified'] == true,
      isEmailVerified: userData['is_email_verified'] == true || (userData['email_verified_at'] != null),
      firstName: ApiSanitizer.sanitizeString(userData['first_name']),
      middleName: ApiSanitizer.sanitizeString(userData['middle_name']),
      lastName: ApiSanitizer.sanitizeString(userData['last_name']),
      profileImage: ApiSanitizer.sanitizeString(userData['profile_image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'token': token,
      'state_id': stateId,
      'city_id': cityId,
      'email_verified_at': emailVerifiedAt,
      'is_mobile_verified': isMobileVerified,
      'is_email_verified': isEmailVerified,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'profile_image': profileImage,
    };
  }
}
