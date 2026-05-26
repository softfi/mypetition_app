import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/models/news_model.dart';
import 'package:my_petition_app/core/models/insight_model.dart';
import 'package:my_petition_app/core/models/petition_model.dart';
import 'package:my_petition_app/core/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:my_petition_app/controllers/auth_controller.dart';
import 'package:my_petition_app/core/utils/guest_dialog.dart';
import 'package:my_petition_app/core/utils/toast_message.dart';
import 'package:my_petition_app/controllers/home_controller.dart';
import 'package:my_petition_app/core/models/feed_model.dart';
import 'package:my_petition_app/core/models/news_comment_model.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class DiscoverController extends GetxController {
  final ApiService _apiService = ApiService();

  // Categories State
  final RxList<CategoryModel> categoriesList = <CategoryModel>[].obs;
  final RxBool isCategoriesLoading = false.obs;

  // News State
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxBool isNewsLoading = false.obs;
  final RxBool isMoreNewsLoading = false.obs;
  final RxInt currentNewsPage = 1.obs;
  final RxBool hasMoreNews = true.obs;
  final int newsLimit = 10;
  final RxInt selectedNewsCategoryId = (-1).obs; // -1 means 'All'

  // Insights State
  final RxList<InsightModel> insightsList = <InsightModel>[].obs;
  final RxBool isInsightsLoading = false.obs;
  final RxBool isSavingInsight = false.obs;

  Future<void> toggleSaveInsight(InsightModel insight) async {
    final authController = Get.find<AuthController>();
    if (authController.isGuest) {
      GuestDialog.showLoginPrompt();
      return;
    }

    final bool originalSavedState = insight.isSaved;
    _updateInsightState(insight.id, !originalSavedState);

    try {
      isSavingInsight.value = true;
      final response = await _apiService.post(AppUrls.saveInsight(insight.id));

      if (response != null && response.data != null && response.data['success'] == true) {
        final bool serverSavedState = response.data['isSaved'] ?? !originalSavedState;
        
        if (serverSavedState != !originalSavedState) {
          _updateInsightState(insight.id, serverSavedState);
        }
        
        CommonToast.showToastSuccess(response.data['message'] ?? 'Action successful');
      } else {
        _updateInsightState(insight.id, originalSavedState);
        CommonToast.showToastError(response?.data['message'] ?? 'Failed to update bookmark');
      }
    } catch (e) {
      debugPrint('Error toggling save insight: $e');
      _updateInsightState(insight.id, originalSavedState);
    } finally {
      isSavingInsight.value = false;
    }
  }

  void _updateInsightState(int insightId, bool isSaved) {
    final index = insightsList.indexWhere((e) => e.id == insightId);
    if (index != -1) {
      insightsList[index] = insightsList[index].copyWith(isSaved: isSaved);
    }

    if (selectedInsight.value?.id == insightId) {
      selectedInsight.value = selectedInsight.value!.copyWith(isSaved: isSaved);
    }
  }

  Future<void> getInsightSaveStatus(int insightId) async {
    final authController = Get.find<AuthController>();
    if (authController.isGuest) return;

    try {
      final response = await _apiService.get(AppUrls.insightSaveStatus(insightId));

      if (response != null && response.data != null && response.data['success'] == true) {
        final bool isSaved = response.data['isSaved'] ?? false;
        _updateInsightState(insightId, isSaved);
      }
    } catch (e) {
      debugPrint('Error getting insight save status: $e');
    }
  }

  // Petitions State
  final RxList<PetitionModel> petitionsList = <PetitionModel>[].obs;
  final RxBool isPetitionsLoading = false.obs;
  final RxBool isMorePetitionsLoading = false.obs;
  final RxInt currentPetitionsPage = 1.obs;
  final RxBool hasMorePetitions = true.obs;
  final int petitionsLimit = 10;

  // Detail State
  final Rx<NewsModel?> selectedNews = Rx<NewsModel?>(null);
  final RxBool isNewsDetailLoading = false.obs;

  // News Comments State
  final RxList<NewsCommentModel> newsCommentsList = <NewsCommentModel>[].obs;
  final RxBool isNewsCommentsLoading = false.obs;
  final RxBool isSubmittingComment = false.obs;

  final Rx<InsightModel?> selectedInsight = Rx<InsightModel?>(null);
  final RxBool isInsightDetailLoading = false.obs;

  final Rx<PetitionModel?> selectedPetition = Rx<PetitionModel?>(null);
  final RxBool isPetitionDetailLoading = false.obs;

  // Font Size for Detail Screens
  final RxDouble fontSizeFactor = 0.9.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    fetchCategories();
    fetchNews(isRefresh: true);
    fetchInsights();
    fetchPetitions(isRefresh: true);
  }

  void changeFontSize(double delta) {
    fontSizeFactor.value = (fontSizeFactor.value + delta).clamp(0.8, 2.0);
  }

  void resetFontSize() {
    fontSizeFactor.value = 0.9;
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;
      final response = await _apiService.get(AppUrls.categories);

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        final List data = response.data['data'];
        categoriesList.assignAll(
            data.map((json) => CategoryModel.fromJson(json)).toList());
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  void setNewsCategory(int categoryId) {
    if (selectedNewsCategoryId.value == categoryId) return;
    selectedNewsCategoryId.value = categoryId;
    newsList.clear(); // Clear list to show shimmer
    fetchNews(isRefresh: true);
  }


  /// Initial fetch or refresh for News
  Future<void> fetchNews({bool isRefresh = true}) async {
    if (isRefresh) {
      currentNewsPage.value = 1;
      hasMoreNews.value = true;
      isNewsLoading.value = true;
    }
    // isme discover page me latest news me jo category tabs ha to usme jab ham categor tabs me click kr rhe hai to categoyr news to fetc ho rhi hia lekin jo tab me maine click kiya vo tab slected nhi show ho rha hia

    try {
      final Map<String, dynamic> queryParams = {
        'page': currentNewsPage.value,
        'limit': newsLimit,
      };

      if (selectedNewsCategoryId?.value != null &&
          selectedNewsCategoryId?.value != -1) {
        queryParams['category_id'] = selectedNewsCategoryId!.value;
      }

      final response = await _apiService.get(
        AppUrls.news,
        queryParameters: queryParams,
        useHeaders: !Get.find<AuthController>().isGuest,
        options: isRefresh 
          ? CacheOptions(store: MemCacheStore(), policy: CachePolicy.noCache).toOptions() 
          : null,
      );

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        final List data = response.data['data'];
        final List<NewsModel> fetchedNews = data.map((json) =>
            NewsModel.fromJson(json)).toList();

        if (isRefresh) {
          newsList.assignAll(fetchedNews);
        } else {
          newsList.addAll(fetchedNews);
        }

        // Check save status for each item if logged in
        final authController = Get.find<AuthController>();
        if (!authController.isGuest) {
          for (var news in fetchedNews) {
            getNewsSaveStatus(news.id);
          }
        }

        if (fetchedNews.length < newsLimit) {
          hasMoreNews.value = false;
        } else {
          currentNewsPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
    } finally {
      isNewsLoading.value = false;
      isMoreNewsLoading.value = false;
    }
  }

  Future<void> loadMoreNews() async {
    if (isMoreNewsLoading.value || !hasMoreNews.value) return;
    isMoreNewsLoading.value = true;
    await fetchNews(isRefresh: false);
  }

  /// Initial fetch or refresh for Petitions
  Future<void> fetchPetitions({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPetitionsPage.value = 1;
      hasMorePetitions.value = true;
      isPetitionsLoading.value = true;
    }

    try {
      final response = await _apiService.get(
        AppUrls.petitions,
        queryParameters: {
          'page': currentPetitionsPage.value,
          'limit': petitionsLimit,
        },
        useHeaders: !Get.find<AuthController>().isGuest,
        options: isRefresh 
          ? CacheOptions(store: MemCacheStore(), policy: CachePolicy.noCache).toOptions() 
          : null,
      );

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        final List data = response.data['data'];
        final List<PetitionModel> fetchedPetitions = data.map((json) =>
            PetitionModel.fromJson(json)).toList();

        if (isRefresh) {
          petitionsList.assignAll(fetchedPetitions);
        } else {
          petitionsList.addAll(fetchedPetitions);
        }

        if (fetchedPetitions.length < petitionsLimit) {
          hasMorePetitions.value = false;
        } else {
          currentPetitionsPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error fetching petitions: $e');
    } finally {
      isPetitionsLoading.value = false;
      isMorePetitionsLoading.value = false;
    }
  }

  Future<void> loadMorePetitions() async {
    if (isMorePetitionsLoading.value || !hasMorePetitions.value) return;
    isMorePetitionsLoading.value = true;
    await fetchPetitions(isRefresh: false);
  }

  Future<void> fetchInsights() async {
    try {
      isInsightsLoading.value = true;
      final response = await _apiService.get(
        AppUrls.insights,
        useHeaders: !Get.find<AuthController>().isGuest,
        options: CacheOptions(store: MemCacheStore(), policy: CachePolicy.noCache).toOptions(),
      );

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        final List data = response.data['data'];
        final fetchedInsights = data.map((json) => InsightModel.fromJson(json)).toList();
        insightsList.assignAll(fetchedInsights);

        final authController = Get.find<AuthController>();
        if (!authController.isGuest) {
          for (var insight in fetchedInsights) {
            getInsightSaveStatus(insight.id);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching insights: $e');
    } finally {
      isInsightsLoading.value = false;
    }
  }

  Future<void> fetchNewsDetail(String slug) async {
    try {
      isNewsDetailLoading.value = true;
      selectedNews.value = null;

      final response = await _apiService.get('${AppUrls.news}/$slug');

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        selectedNews.value = NewsModel.fromJson(response.data['data']);
        getNewsSaveStatus(selectedNews.value!.id);
        fetchNewsComments(selectedNews.value!.id);
      }
    } catch (e) {
      debugPrint('Error fetching news detail: $e');
    } finally {
      isNewsDetailLoading.value = false;
    }
  }

  Future<void> getNewsSaveStatus(int newsId) async {
    final authController = Get.find<AuthController>();
    if (authController.isGuest) return;

    try {
      final response = await _apiService.get(AppUrls.newsSaveStatus(newsId));

      if (response != null && response.data != null && response.data['success'] == true) {
        final bool isSaved = response.data['isSaved'] ?? false;
        _updateNewsState(newsId, isSaved);
      }
    } catch (e) {
      debugPrint('Error getting news save status: $e');
    }
  }

  Future<void> fetchNewsComments(int newsId) async {
    try {
      isNewsCommentsLoading.value = true;
      newsCommentsList.clear();

      final response = await _apiService.get(AppUrls.newsComments(newsId));

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        newsCommentsList.assignAll(
          data.map((json) => NewsCommentModel.fromJson(json)).toList()
        );
      }
    } catch (e) {
      debugPrint('Error fetching news comments: $e');
    } finally {
      isNewsCommentsLoading.value = false;
    }
  }

  Future<bool> addNewsComment(int newsId, String commentText) async {
    final authController = Get.find<AuthController>();
    if (authController.isGuest) {
      GuestDialog.showLoginPrompt();
      return false;
    }

    if (commentText.trim().isEmpty) return false;

    try {
      isSubmittingComment.value = true;
      final response = await _apiService.post(
        AppUrls.newsComments(newsId),
        data: {
          "comment": commentText.trim(),
        },
      );

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        final newComment = NewsCommentModel.fromJson(response.data['data']);
        newsCommentsList.insert(0, newComment);
        CommonToast.showToastSuccess(response.data['message'] ?? 'Comment added');
        return true;
      } else {
        CommonToast.showToastError(response?.data['message'] ?? 'Failed to add comment');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding comment: $e');
      CommonToast.showToastError('An error occurred');
      return false;
    } finally {
      isSubmittingComment.value = false;
    }
  }

  Future<void> fetchInsightDetail(String slug) async {
    try {
      isInsightDetailLoading.value = true;
      selectedInsight.value = null;

      final response = await _apiService.get('${AppUrls.insights}/$slug');

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        selectedInsight.value = InsightModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error fetching insight detail: $e');
    } finally {
      isInsightDetailLoading.value = false;
    }
  }

  Future<void> fetchPetitionDetail(String slug) async {
    try {
      isPetitionDetailLoading.value = true;
      selectedPetition.value = null;

      final response = await _apiService.get('${AppUrls.petitions}/$slug');

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        selectedPetition.value = PetitionModel.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error fetching petition detail: $e');
    } finally {
      isPetitionDetailLoading.value = false;
    }
  }

  // '' = idle, 'yes' = yes-button loading, 'no' = no-button loading
  final RxString votingFor = ''.obs;

  Future<bool> castVote({
    required int petitionId,
    required String vote,
    String? comment,
  }) async {
    try {
      votingFor.value = vote; // mark only this button as loading
      final response = await _apiService.post(
        AppUrls.votePetition(petitionId),
        data: {
          "vote": vote,
          "comment": comment ?? "",
        },
      );

      if (response != null && response.data != null &&
          response.data['success'] == true) {
        // Refresh petition detail to show updated counts
        fetchPetitionDetail(selectedPetition.value!.slug);
        return true;
      } else {
        debugPrint('Vote failed: ${response?.data['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error casting vote: $e');
      return false;
    } finally {
      votingFor.value = ''; // clear loading state
    }
  }
  final RxBool isSavingPetition = false.obs;

  Future<void> toggleSavePetition(PetitionModel petition) async {
    final authController = Get.find<AuthController>();
    if (authController.isGuest) {
      GuestDialog.showLoginPrompt();
      return;
    }

    final bool originalSavedState = petition.isSaved;
    _updatePetitionState(petition.id, !originalSavedState);

    try {
      isSavingPetition.value = true;
      final response = await _apiService.post(AppUrls.savePetition(petition.id));

      if (response != null && response.data != null && response.data['success'] == true) {
        final bool serverSavedState = response.data['isSaved'] ?? !originalSavedState;
        if (serverSavedState != !originalSavedState) {
          _updatePetitionState(petition.id, serverSavedState);
        }
        CommonToast.showToastSuccess(response.data['message'] ?? 'Action successful');
      } else {
        _updatePetitionState(petition.id, originalSavedState);
        CommonToast.showToastError(response?.data['message'] ?? 'Failed to update bookmark');
      }
    } catch (e) {
      debugPrint('Error toggling save petition: $e');
      _updatePetitionState(petition.id, originalSavedState);
    } finally {
      isSavingPetition.value = false;
    }
  }

  void _updatePetitionState(int petitionId, bool isSaved) {
    final index = petitionsList.indexWhere((e) => e.id == petitionId);
    if (index != -1) {
      petitionsList[index] = petitionsList[index].copyWith(isSaved: isSaved);
    }
    if (selectedPetition.value?.id == petitionId) {
      selectedPetition.value = selectedPetition.value!.copyWith(isSaved: isSaved);
    }
  }

  Future<void> getPetitionSaveStatus(int petitionId) async {
    final authController = Get.find<AuthController>();
    if (authController.isGuest) return;
    try {
      final response = await _apiService.get(AppUrls.petitionSaveStatus(petitionId));
      if (response != null && response.data != null && response.data['success'] == true) {
        final bool isSaved = response.data['isSaved'] ?? false;
        _updatePetitionState(petitionId, isSaved);
      }
    } catch (e) {
      debugPrint('Error getting petition save status: $e');
    }
  }

  final RxBool isSavingNews = false.obs;

  Future<void> toggleSaveNews(NewsModel news) async {
    final authController = Get.find<AuthController>();
    if (authController.isGuest) {
      GuestDialog.showLoginPrompt();
      return;
    }

    // Optimistic Update: Toggle immediately for instant UI feedback
    final bool originalSavedState = news.isSaved;
    _updateNewsState(news.id, !originalSavedState);

    try {
      isSavingNews.value = true;
      final response = await _apiService.post(AppUrls.saveNews(news.id));

      if (response != null && response.data != null && response.data['success'] == true) {
        final bool serverSavedState = response.data['isSaved'] ?? !originalSavedState;
        
        // Sync with server state just in case it's different from our toggle
        if (serverSavedState != !originalSavedState) {
          _updateNewsState(news.id, serverSavedState);
        }
        
        CommonToast.showToastSuccess(response.data['message'] ?? 'Action successful');
      } else {
        // Rollback on failure
        _updateNewsState(news.id, originalSavedState);
        CommonToast.showToastError(response?.data['message'] ?? 'Failed to update bookmark');
      }
    } catch (e) {
      debugPrint('Error toggling save news: $e');
      // Rollback on error
      _updateNewsState(news.id, originalSavedState);
    } finally {
      isSavingNews.value = false;
    }
  }

  void _updateNewsState(int newsId, bool isSaved) {
    // Update newsList
    final index = newsList.indexWhere((e) => e.id == newsId);
    if (index != -1) {
      newsList[index] = newsList[index].copyWith(isSaved: isSaved);
    }

    // Update selectedNews if it's the one being toggled
    if (selectedNews.value?.id == newsId) {
      selectedNews.value = selectedNews.value!.copyWith(isSaved: isSaved);
    }

    // Also update HomeController if it has this news
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      final homeIndex = homeController.feedList.indexWhere((e) => e.feedType == 'news' && e.data.id == newsId);
      if (homeIndex != -1) {
        final currentItem = homeController.feedList[homeIndex];
        homeController.feedList[homeIndex] = FeedItem(
          feedType: 'news',
          data: (currentItem.data as NewsModel).copyWith(isSaved: isSaved),
        );
      }
    }
  }
}