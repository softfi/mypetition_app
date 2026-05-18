import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/models/news_model.dart';

class SavedNewsController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<NewsModel> savedNewsList = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final int limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchSavedNews();
  }

  Future<void> fetchSavedNews({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
      isLoading.value = true;
    }

    try {
      final response = await _apiService.get(
        AppUrls.savedNews,
        queryParameters: {
          'page': currentPage.value,
          'limit': limit,
        },
      );

      if (response != null && response.data != null && response.data['success'] == true) {
        final List data = response.data['data'];
        final List<NewsModel> fetchedNews = data.map((json) => NewsModel.fromJson(json)).toList();

        if (isRefresh) {
          savedNewsList.assignAll(fetchedNews);
        } else {
          savedNewsList.addAll(fetchedNews);
        }

        if (fetchedNews.length < limit) {
          hasMore.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error fetching saved news: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;
    await fetchSavedNews(isRefresh: false);
  }
}
