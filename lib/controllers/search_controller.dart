import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_petition_app/core/service/api/api_services.dart';
import 'package:my_petition_app/core/config/app_urls.dart';
import 'package:my_petition_app/core/models/search_result_model.dart';

class AppSearchController extends GetxController {
  final ApiService _apiService = ApiService();

  final RxList<SearchResult> results = <SearchResult>[].obs;
  final RxBool isLoading = false.obs;
  final RxString query = ''.obs;
  final RxString errorMsg = ''.obs;

  Timer? _debounce;

  void onQueryChanged(String q) {
    _debounce?.cancel();
    query.value = q.trim();

    if (query.value.isEmpty) {
      results.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _search(query.value);
    });
  }

  Future<void> _search(String q) async {
    if (q.isEmpty) return;
    errorMsg.value = '';
    try {
      final response = await _apiService.get(
        AppUrls.search,
        queryParameters: {'q': q},
      );

      if (response != null &&
          response.data != null &&
          response.data['success'] == true) {
        final List raw = response.data['data'] as List? ?? [];
        results.assignAll(
          raw.map((json) => SearchResult.fromJson(json as Map<String, dynamic>)).toList(),
        );
      } else {
        results.clear();
        errorMsg.value = response?.data?['message'] as String? ?? 'No results found.';
      }
    } catch (e) {
      debugPrint('Search error: $e');
      results.clear();
      errorMsg.value = 'Something went wrong. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    query.value = '';
    results.clear();
    isLoading.value = false;
    errorMsg.value = '';
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
