import 'package:my_petition_app/core/config/app_urls.dart';

enum SearchResultType { news, petition, insight }

class SearchResult {
  final int id;
  final String title;
  final String slug;
  final String type; // 'news' | 'petition' | 'insight'
  final String? description;
  final String? s3ImageUrl;       // news / petition
  final String? insightImageUrl;  // insight (from files[0])
  final String? categoryName;
  final DateTime createdAt;

  SearchResult({
    required this.id,
    required this.title,
    required this.slug,
    required this.type,
    this.description,
    this.s3ImageUrl,
    this.insightImageUrl,
    this.categoryName,
    required this.createdAt,
  });

  SearchResultType get resultType {
    switch (type) {
      case 'petition':
        return SearchResultType.petition;
      case 'insight':
        return SearchResultType.insight;
      default:
        return SearchResultType.news;
    }
  }

  /// Full image URL ready to use in CachedNetworkImage
  String? get imageUrl {
    if (resultType == SearchResultType.insight) {
      return insightImageUrl != null
          ? '${AppUrls.s3BaseUrl}$insightImageUrl'
          : null;
    }
    return s3ImageUrl != null ? '${AppUrls.s3BaseUrl}$s3ImageUrl' : null;
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'news';

    // Insight: image comes from files array
    String? insightImageUrl;
    if (type == 'insight') {
      final files = json['files'] as List?;
      if (files != null && files.isNotEmpty) {
        insightImageUrl = files.first['s3_image_url'] as String?;
      }
    }

    return SearchResult(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      type: type,
      description: json['description'] as String?,
      s3ImageUrl: json['s3_image_url'] as String?,
      insightImageUrl: insightImageUrl,
      categoryName: (json['category'] as Map?)?['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
