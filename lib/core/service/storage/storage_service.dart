import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:my_petition_app/core/routes/app_routes.dart';
import 'package:my_petition_app/features/auth/models/user_model.dart';

class StorageService {

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  late GetStorage _box;
  bool _isInitialized = false;



  final String userDataKey = "user_data";
  final String authTokenKey = "auth_token";
  final String deviceIdKey = "device_id";
  final String deviceTypeKey = "device_type";

  // Initialize GetStorage
  Future<void> initialize() async {
    if (_isInitialized) return;

    await GetStorage.init();
    _box = GetStorage();
    _isInitialized = true;

    // ✅ Detect fresh install (First run after install/uninstall)
    // On iOS, Keychain (SecureStorage) persists after uninstall.
    // We check a GetStorage flag (which is deleted on uninstall) to determine if we should clear SecureStorage.
    if (_box.read('has_been_run') == null) {
      debugPrint('🆕 Fresh install detected. Clearing SecureStorage...');
      await _secureStorage.deleteAll();
      await _box.write('has_been_run', true);
    }

    debugPrint('✅ StorageService initialized');
  }

  // Check if initialized
  void _checkInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'StorageService not initialized. Call initialize() first.',
      );
    }
  }

  // Save string
  Future<void> setString(String key, String value) async {
    _checkInitialized();
    await _box.write(key, value);
    debugPrint('💾 Saved: $key = $value');
  }

  // Get string
  String? getString(String key) {
    _checkInitialized();
    final value = _box.read<String>(key);
    debugPrint('📖 Read: $key = $value');
    return value;
  }

  // Save int
  Future<void> setInt(String key, int value) async {
    _checkInitialized();
    await _box.write(key, value);
  }

  // Get int
  int? getInt(String key) {
    _checkInitialized();
    return _box.read<int>(key);
  }

  // Save bool
  Future<void> setBool(String key, bool value) async {
    _checkInitialized();
    await _box.write(key, value);
  }

  // Get bool
  bool? getBool(String key) {
    _checkInitialized();
    return _box.read<bool>(key);
  }

  // Save double
  Future<void> setDouble(String key, double value) async {
    _checkInitialized();
    await _box.write(key, value);
  }

  // Get double
  double? getDouble(String key) {
    _checkInitialized();
    return _box.read<double>(key);
  }

  // Save object (Map/List)
  Future<void> setObject(String key, dynamic value) async {
    _checkInitialized();
    await _box.write(key, value);
  }

  // Get object
  dynamic getObject(String key) {
    _checkInitialized();
    return _box.read(key);
  }

  // Remove key
  Future<void> remove(String key) async {
    _checkInitialized();
    await _box.remove(key);
    debugPrint('🗑️ Removed: $key');
  }

  // Check if key exists
  bool containsKey(String key) {
    _checkInitialized();
    return _box.hasData(key);
  }

  // Clear all data
  Future<void> clearAll() async {
    _checkInitialized();
    await _box.erase();
    debugPrint('🗑️ All data cleared');
  }



  // Get all keys
  Iterable<String> getAllKeys() {
    _checkInitialized();
    return _box.getKeys().cast<String>();
  }

  // User Data Save
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    _checkInitialized();
    final jsonString = jsonEncode(userData);
    await setString(userDataKey, jsonString);
    debugPrint("✅ User data saved: $jsonString");
  }

  // get User Data
  UserModel? getUserData()  {
    _checkInitialized();

    final jsonString = getString(userDataKey);
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint("⚠️ No user data found");
      return null;
    }

    try {
      final Map<String, dynamic> dataMap = jsonDecode(jsonString);
      return UserModel.fromJson(dataMap);
    } catch (e) {
      debugPrint("❌ Error decoding user data: $e");
      return null;
    }
  }

  bool isUserLoggedIn() {
    _checkInitialized();
    // debugPrint("✅ User logged in: ${getUserData()?.isProfiled}");
    return getUserData() != null;
  }

  // ✅ Auth token — SECURE storage
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Save token
  // Future<void> saveAuthToken(String token)  async {
  //   _checkInitialized();
  //   await setString(authTokenKey, token);
  //   debugPrint("✅ Token saved: $token");
  // }
  //
  // // get Token
  // String? getAuthToken() {
  //   _checkInitialized();
  //   return getString(authTokenKey);  // already sync
  // }

  Future<void> setDeviceId(String deviceId)  async {
    _checkInitialized();
    await setString(deviceIdKey, deviceId);
  }

  // get Token
  String? getDeviceId() {
    _checkInitialized();
    return getString(deviceIdKey);  // already sync
  }

  Future<void> setDeviceType(String deviceType)  async {
    _checkInitialized();
    await setString(deviceTypeKey, deviceType);
  }

  // get Token
  String? getDeviceType() {
    _checkInitialized();
    return getString(deviceTypeKey);  // already sync
  }

  Future<void> logout() async {
    _checkInitialized();

    // Remove token from both GetStorage and SecureStorage to be safe
    await remove(authTokenKey);
    await _secureStorage.delete(key: 'auth_token');

    // Remove user data
    await remove(userDataKey);

    // await remove(deviceIdKey);
    // await remove(deviceTypeKey);

    debugPrint("🚪 User logged out: token & user data removed");
    // Navigation should be handled by the caller (controller) to avoid redundant navigations
  }
}

