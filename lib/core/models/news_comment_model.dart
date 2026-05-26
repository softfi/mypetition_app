class NewsCommentModel {
  final int id;
  final int newsId;
  final int userId;
  final String comment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final CommentUser? user;

  NewsCommentModel({
    required this.id,
    required this.newsId,
    required this.userId,
    required this.comment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.user,
  });

  factory NewsCommentModel.fromJson(Map<String, dynamic> json) {
    return NewsCommentModel(
      id: json['id'] ?? 0,
      newsId: json['news_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      comment: json['comment'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      user: json['user'] != null ? CommentUser.fromJson(json['user']) : null,
    );
  }
}

class CommentUser {
  final int id;
  final String name;
  final String? profileImage;

  CommentUser({
    required this.id,
    required this.name,
    this.profileImage,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}
