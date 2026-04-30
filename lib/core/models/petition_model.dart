class PetitionModel {
  final int id;
  final int categoryId;
  final int? stateId;
  final int? districtId;
  final String title;
  final String slug;
  final String description;
  final String content;
  final String s3ImageUrl;
  final String? imageLinkUrl;
  final String userType;
  final int userId;
  final String status;
  final String? comment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final PetitionCategory? category;
  final PetitionLocation? state;
  final PetitionLocation? district;
  final int yesCount;
  final int noCount;
  final int voteCount;

  PetitionModel({
    required this.id,
    required this.categoryId,
    this.stateId,
    this.districtId,
    required this.title,
    required this.slug,
    required this.description,
    required this.content,
    required this.s3ImageUrl,
    this.imageLinkUrl,
    required this.userType,
    required this.userId,
    required this.status,
    this.comment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.category,
    this.state,
    this.district,
    required this.yesCount,
    required this.noCount,
    required this.voteCount,
  });

  factory PetitionModel.fromJson(Map<String, dynamic> json) {
    return PetitionModel(
      id: json['id'],
      categoryId: json['category_id'],
      stateId: json['state_id'],
      districtId: json['district_id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      s3ImageUrl: json['s3_image_url'] ?? '',
      imageLinkUrl: json['image_link_url'],
      userType: json['user_type'] ?? '',
      userId: json['user_id'],
      status: json['status'] ?? '',
      comment: json['comment'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      category: json['category'] != null ? PetitionCategory.fromJson(json['category']) : null,
      state: json['state'] != null ? PetitionLocation.fromJson(json['state']) : null,
      district: json['district'] != null ? PetitionLocation.fromJson(json['district']) : null,
      yesCount: json['yesCount'] ?? 0,
      noCount: json['noCount'] ?? 0,
      voteCount: json['voteCount'] ?? 0,
    );
  }
}

class PetitionCategory {
  final int id;
  final String name;

  PetitionCategory({required this.id, required this.name});

  factory PetitionCategory.fromJson(Map<String, dynamic> json) {
    return PetitionCategory(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class PetitionLocation {
  final int id;
  final String name;

  PetitionLocation({required this.id, required this.name});

  factory PetitionLocation.fromJson(Map<String, dynamic> json) {
    return PetitionLocation(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
