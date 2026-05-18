import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:path_provider/path_provider.dart';

import '../../utils/api_error_screen.dart';
import '../../utils/toast_message.dart';
import '../../config/app_urls.dart';
import '../storage/storage_service.dart';
import '../device/device_info_helper.dart';
import 'api_response_printer.dart';
import 'api_sanitizer.dart';
import 'package:my_petition_app/core/routes/app_routes.dart';



// Custom Exception Class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorData,
  });

  @override
  String toString() => '$message';
}



class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  late Dio _dio;
  late CacheStore _cacheStore;
  final StorageService _storageService = StorageService();
  final DeviceInfoHelper _deviceInfoHelper = DeviceInfoHelper();

  Future<void> initialize() async {
    await _deviceInfoHelper.getDeviceId();
    final appDocDir = await getApplicationDocumentsDirectory();
    final cacheDir = '${appDocDir.path}/cache';

    _cacheStore = HiveCacheStore(cacheDir, hiveBoxName: 'dio_cache');

    final cacheOptions = CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.request,
      maxStale: const Duration(days: 1),
      priority: CachePriority.normal,
      keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    );



    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        baseUrl: AppUrls.baseUrl,
      ),
    );

    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

    // Add request interceptor to set device info on every request
    // _dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) async {
    //     // Get device info
    //     final deviceId =  _storageService.getDeviceId();
    //     final deviceType = _storageService.getDeviceType();
    //
    //     // Set headers
    //     options.headers['device_id'] = deviceId;
    //     options.headers['device_type'] = deviceType;
    //
    //     // Set auth token if exists
    //     final token = _storageService.getAuthToken();
    //     if (token != null && token.isNotEmpty) {
    //       options.headers['Authorization'] = 'Bearer $token';
    //     }
    //
    //     // Print request using Printer mixin (compatible format)
    //     ApiResponsePrinter. printRequest(options);
    //
    //     return handler.next(options);
    //   },
    //   onResponse: (response, handler) {
    //     // Print response using Printer mixin (compatible format)
    //     ApiResponsePrinter.printResponse(response);
    //     return handler.next(response);
    //   },
    //   onError: (error, handler) {
    //     // Print error
    //     ApiResponsePrinter.printError(error);
    //     return handler.next(error);
    //   },
    // ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check if headers should be sent (default to true)
          final bool useHeaders = options.extra['useHeaders'] ?? true;

          if (useHeaders) {
            final token = await _storageService.getAuthToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            options.headers['device_id'] = _storageService.getDeviceId();
            options.headers['device_type'] = _storageService.getDeviceType();
          }

          ApiResponsePrinter.printRequest(options);
          handler.next(options);
        },

        onResponse: (response, handler) {
          ApiResponsePrinter.printResponse(response);

          // Deep Sanitize Response Data
          if (response.data != null) {
            response.data = ApiSanitizer.deepSanitize(response.data);
          }

          if (response.statusCode == 401) {
            _handleUnauthorized();
            return;
          }

          handler.next(response);
        },

        onError: (DioException e, handler) async {
          ApiResponsePrinter.printError(e);

          // if (e.response?.statusCode == 401) {
          if (e.response?.statusCode == 401) {
            debugPrint("🚨 401 Error detected!");
            _handleUnauthorized();
            return;
          }

          handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void initializeWithDefaultUrl() {
    _dio.options.baseUrl = AppUrls.baseUrl;
  }

  // Set auth token - headers will be added automatically via interceptor
  Future<void> setAuthToken(String token) async {
    await _storageService.setString(_storageService.authTokenKey, token);
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Generic GET request
  Future<Response?> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useHeaders = true,
  }) async {
    try {
      final requestOptions = options ?? Options();
      requestOptions.extra ??= {};
      requestOptions.extra!['useHeaders'] = useHeaders;

      final response = await _dio.get(
        path, 
        queryParameters: queryParameters,
        options: requestOptions,
      );

      return response;
    } on DioException catch (e) {
      int? statusCode = e.response?.statusCode;
      String? errorMessage = e.message;
      // OLD CODE:
      // if (statusCode == 401) {
      //   CommonToast.showToastError("Unauthorized access. Please log in again.");
      // } else {
      
      // if (statusCode == 401 ) {
      if (statusCode == 401) {
        debugPrint('❌ UI Error Suppressed (Unauthorized)');
        // CommonToast.showToastError("Unauthorized access. Please log in again.");
        _handleUnauthorized();
      } else {
        if (path.contains("all-role-features-assignments")) {
          Get.offAll(ApiErrorScreen(message: errorMessage ?? ""));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Response?> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(validateStatus: (status) => true),
      );

      return response;
    } catch (e) {
      print("Unexpected error in post(): $e");
      return null;
    }
  }

  Future<Response?> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      int? statusCode = e.response?.statusCode;
      // OLD CODE:
      // if (statusCode == 401) {
      //   CommonToast.showToastError("Unauthorized access. Please log in again.");
      // }

      // if (statusCode == 401 ) {
      if (statusCode == 401) {
        debugPrint('❌ UI Error Suppressed (Unauthorized)');
        // CommonToast.showToastError("Unauthorized access. Please log in again.");
        _handleUnauthorized();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Response?> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        data: data,
      );

      return response;
    } on DioException catch (e) {
      int? statusCode = e.response?.statusCode;
      // OLD CODE:
      // if (statusCode == 401) {
      //   CommonToast.showToastError("Unauthorized access. Please log in again.");
      // }

      // if (statusCode == 401 ) {
      if (statusCode == 401) {
        debugPrint('❌ UI Error Suppressed (Unauthorized)');
        // CommonToast.showToastError("Unauthorized access. Please log in again.");
        _handleUnauthorized();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Response?> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      int? statusCode = e.response?.statusCode;
      // OLD CODE:
      // if (statusCode == 401) {
      //   CommonToast.showToastError("Unauthorized access. Please log in again.");
      // } else {

      // if (statusCode == 401 ) {
      if (statusCode == 401) {
        debugPrint('❌ UI Error Suppressed (Unauthorized)');
        // CommonToast.showToastError("Unauthorized access. Please log in again.");
        _handleUnauthorized();
      } else {
        debugPrint("PATCH error: ${e.message}");
      }
      return null;
    } catch (e) {
      debugPrint("Unexpected PATCH error: $e");
      return null;
    }
  }

  Future<Response?> uploadFile(String path, FormData formData) async {
    try {
      final response = await _dio.post(path, data: formData);

      return response;
    } on DioException catch (e) {
      int? statusCode = e.response?.statusCode;
      // OLD CODE:
      // if (statusCode == 401) {
      //   CommonToast.showToastError("Unauthorized access. Please log in again.");
      // }

      // if (statusCode == 401 ) {
      if (statusCode == 401) {
        debugPrint('❌ UI Error Suppressed (Unauthorized)');
        // CommonToast.showToastError("Unauthorized access. Please log in again.");
        _handleUnauthorized();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    await _cacheStore.clean();
  }

  bool _isRedirectingToLogin = false;

  Future<void> _handleUnauthorized() async {
    if (_isRedirectingToLogin) return;
    
    _isRedirectingToLogin = true;
    debugPrint('❌ Unauthorized! Initiating logout and redirect...');
    
    try {
      await _storageService.logout();
      // Redirect to login only if not already on login or splash screen
      if (Get.currentRoute != AppRoutes.login && Get.currentRoute != AppRoutes.splash) {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      // Small delay to prevent clearing the flag too quickly if multiple requests arrive in a tight loop
      await Future.delayed(const Duration(seconds: 2));
      _isRedirectingToLogin = false;
    }
  }
}
