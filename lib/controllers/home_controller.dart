import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/models/feed_model.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/controllers/discover_controller.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<FeedItem> feedList = <FeedItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final int limit = 10;

  @override
  void onInit() {
    super.onInit();
    // API call removed from here as per user request
  }

  Future<void> fetchFeed({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
      isLoading.value = true;
    }

    try {
      final authController = Get.find<AuthController>();
      final response = await _apiService.get(
        AppUrls.feed,
        queryParameters: {
          'page': currentPage.value,
          'limit': limit,
        },
        useHeaders: !authController.isGuest,
        options: isRefresh 
          ? CacheOptions(store: MemCacheStore(), policy: CachePolicy.noCache).toOptions() 
          : null,
      );

      if (response != null && response.data != null && response.data['success'] == true) {
        final List data = response.data['data'];
        final List<FeedItem> fetchedItems = [];

        for (var json in data) {
          try {
            fetchedItems.add(FeedItem.fromJson(json));
          } catch (e) {
            debugPrint('Error mapping feed item: $e');
            // Skip faulty items instead of crashing the whole list
          }
        }

        if (isRefresh) {
          feedList.assignAll(fetchedItems);
        } else {
          feedList.addAll(fetchedItems);
        }

        // Check save status for news items in the feed if logged in
        final authController = Get.find<AuthController>();
        if (!authController.isGuest) {
          final discoverController = Get.find<DiscoverController>();
          for (var item in fetchedItems) {
            if (item.feedType == 'news') {
              discoverController.getNewsSaveStatus(item.data.id);
            }
          }
        }

        if (fetchedItems.length < limit) {
          hasMore.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error fetching feed: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;
    await fetchFeed(isRefresh: false);
  }
}
