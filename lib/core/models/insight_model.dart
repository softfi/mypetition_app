class InsightModel {
  final int id;
  final String title;
  final String slug;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<InsightFile> files;
  final int fileCount;

  InsightModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.files,
    required this.fileCount,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      files: (json['files'] as List?)?.map((i) => InsightFile.fromJson(i)).toList() ?? [],
      fileCount: json['fileCount'] ?? 0,
    );
  }
}

class InsightFile {
  final int id;
  final int insightId;
  final String s3ImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  InsightFile({
    required this.id,
    required this.insightId,
    required this.s3ImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InsightFile.fromJson(Map<String, dynamic> json) {
    return InsightFile(
      id: json['id'],
      insightId: json['insight_id'],
      s3ImageUrl: json['s3_image_url'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
