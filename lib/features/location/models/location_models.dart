import 'package:my_petition_app/core/service/api/api_sanitizer.dart';

class StateModel {
  final int id;
  final String name;
  final String slug;
  final String code;

  StateModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.code,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: ApiSanitizer.sanitizeInt(json['id']),
      name: ApiSanitizer.sanitizeString(json['name']),
      slug: ApiSanitizer.sanitizeString(json['slug']),
      code: ApiSanitizer.sanitizeString(json['code']),
    );
  }
}

class DistrictModel {
  final int id;
  final String name;
  final String slug;
  final int stateId;

  DistrictModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.stateId,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: ApiSanitizer.sanitizeInt(json['id']),
      name: ApiSanitizer.sanitizeString(json['name']),
      slug: ApiSanitizer.sanitizeString(json['slug']),
      stateId: ApiSanitizer.sanitizeInt(json['state_id']),
    );
  }
}
