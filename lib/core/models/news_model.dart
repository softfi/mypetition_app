class NewsModel {
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
  final String priority;
  final String userType;
  final int userId;
  final String status;
  final String? comment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final NewsCategory? category;
  final NewsLocation? state;
  final NewsLocation? district;
  final NavigationNews? previous;
  final NavigationNews? next;
  final bool isSaved;
  final int views;

  NewsModel({
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
    required this.priority,
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
    this.previous,
    this.next,
    this.isSaved = false,
    this.views = 0,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      stateId: json['state_id'],
      districtId: json['district_id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      s3ImageUrl: json['s3_image_url'] ?? '',
      imageLinkUrl: json['image_link_url'],
      priority: json['priority'] ?? '',
      userType: json['user_type'] ?? '',
      userId: json['user_id'] ?? 0,
      status: json['status'] ?? '',
      comment: json['comment'],
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      category: json['category'] != null ? NewsCategory.fromJson(json['category']) : null,
      state: json['state'] != null ? NewsLocation.fromJson(json['state']) : null,
      district: json['district'] != null ? NewsLocation.fromJson(json['district']) : null,
      previous: json['previous'] != null ? NavigationNews.fromJson(json['previous']) : null,
      next: json['next'] != null ? NavigationNews.fromJson(json['next']) : null,
      isSaved: json['isSaved'] ?? false,
      views: json['views'] ?? 0,
    );
  }

  NewsModel copyWith({bool? isSaved, int? views}) {
    return NewsModel(
      id: id,
      categoryId: categoryId,
      stateId: stateId,
      districtId: districtId,
      title: title,
      slug: slug,
      description: description,
      content: content,
      s3ImageUrl: s3ImageUrl,
      imageLinkUrl: imageLinkUrl,
      priority: priority,
      userType: userType,
      userId: userId,
      status: status,
      comment: comment,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      category: category,
      state: state,
      district: district,
      previous: previous,
      next: next,
      isSaved: isSaved ?? this.isSaved,
      views: views ?? this.views,
    );
  }
}

class NewsCategory {
  final int id;
  final String name;

  NewsCategory({required this.id, required this.name});

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class NewsLocation {
  final int id;
  final String name;

  NewsLocation({required this.id, required this.name});

  factory NewsLocation.fromJson(Map<String, dynamic> json) {
    return NewsLocation(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class NavigationNews {
  final String slug;
  final String title;

  NavigationNews({required this.slug, required this.title});

  factory NavigationNews.fromJson(Map<String, dynamic> json) {
    return NavigationNews(
      slug: json['slug'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
