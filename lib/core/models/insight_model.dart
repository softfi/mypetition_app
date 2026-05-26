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

  final bool isSaved;

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
    this.isSaved = false,
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
      isSaved: json['isSaved'] ?? false,
    );
  }

  InsightModel copyWith({
    int? id,
    String? title,
    String? slug,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<InsightFile>? files,
    int? fileCount,
    bool? isSaved,
  }) {
    return InsightModel(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      files: files ?? this.files,
      fileCount: fileCount ?? this.fileCount,
      isSaved: isSaved ?? this.isSaved,
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
