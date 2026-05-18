import 'news_model.dart';
import 'insight_model.dart';
import 'petition_model.dart';

class FeedItem {
  final String feedType;
  final dynamic data;

  FeedItem({required this.feedType, required this.data});

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    String type = json['feed_type'] ?? '';
    dynamic itemData;

    if (type == 'news') {
      itemData = NewsModel.fromJson(json);
    } else if (type == 'insight') {
      itemData = InsightModel.fromJson(json);
    } else if (type == 'petition') {
      itemData = PetitionModel.fromJson(json);
    } else {
      itemData = json;
    }

    return FeedItem(
      feedType: type,
      data: itemData,
    );
  }
}

class FeedResponse {
  final bool success;
  final String message;
  final List<FeedItem> data;

  FeedResponse({required this.success, required this.message, required this.data});

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((i) => FeedItem.fromJson(i)).toList() ?? [],
    );
  }
}
