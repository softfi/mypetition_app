class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final bool isActive;
  final String? s3IconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    this.s3IconUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      isActive: json['is_active'] ?? true,
      s3IconUrl: json['s3_icon_url'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }
}
