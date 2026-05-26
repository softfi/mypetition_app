import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/models/petition_model.dart';

class SavedPetitionsController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<PetitionModel> savedPetitionsList = <PetitionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final int limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchSavedPetitions();
  }

  Future<void> fetchSavedPetitions({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
      isLoading.value = true;
    }

    try {
      final response = await _apiService.get(
        AppUrls.savedPetitions,
        queryParameters: {
          'page': currentPage.value,
          'limit': limit,
        },
      );

      if (response != null && response.data != null && response.data['success'] == true) {
        final List data = response.data['data'];
        final List<PetitionModel> fetched = data.map((json) {
          return PetitionModel.fromJson(json).copyWith(isSaved: true);
        }).toList();

        if (isRefresh) {
          savedPetitionsList.assignAll(fetched);
        } else {
          savedPetitionsList.addAll(fetched);
        }

        if (fetched.length < limit) {
          hasMore.value = false;
        } else {
          currentPage.value++;
        }
      }
    } catch (e) {
      debugPrint('Error fetching saved petitions: $e');
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isMoreLoading.value || !hasMore.value) return;
    isMoreLoading.value = true;
    await fetchSavedPetitions(isRefresh: false);
  }
}
