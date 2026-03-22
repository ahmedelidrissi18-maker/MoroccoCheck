import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Storage instances
  late final FlutterSecureStorage _secureStorage;
  late SharedPreferences _prefs;

  // Storage keys
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _preferredLanguageKey = 'settings_preferred_language';
  static const String _notificationsEnabledKey =
      'settings_notifications_enabled';
  static const String _preciseLocationEnabledKey =
      'settings_precise_location_enabled';
  static const String _technicalInfoVisibleKey =
      'settings_technical_info_visible';

  // Initialize storage
  Future<void> init() async {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(),
    );
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== JWT Token Methods (Secure Storage) ====================

  /// Save JWT token securely
  Future<bool> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      await _prefs.setBool(_isLoggedInKey, true);
      return true;
    } catch (e) {
      debugPrint('Error saving token: $e');
      return false;
    }
  }

  /// Get JWT token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error reading token: $e');
      return null;
    }
  }

  /// Save refresh token securely
  Future<bool> saveRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      return true;
    } catch (e) {
      debugPrint('Error saving refresh token: $e');
      return false;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('Error reading refresh token: $e');
      return null;
    }
  }

  /// Delete JWT token
  Future<bool> deleteToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _prefs.setBool(_isLoggedInKey, false);
      return true;
    } catch (e) {
      debugPrint('Error deleting token: $e');
      return false;
    }
  }

  // ==================== User Data Methods (SharedPreferences) ====================

  /// Save user data as JSON
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _prefs.setString(_userDataKey, jsonString);
      return true;
    } catch (e) {
      debugPrint('Error saving user data: $e');
      return false;
    }
  }

  /// Get user data as Map
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = _prefs.getString(_userDataKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error reading user data: $e');
      return null;
    }
  }

  /// Get specific user field
  Future<T?> getUserField<T>(String key) async {
    try {
      final userData = await getUserData();
      if (userData == null) return null;
      return userData[key] as T?;
    } catch (e) {
      debugPrint('Error reading user field: $e');
      return null;
    }
  }

  /// Update specific user field
  Future<bool> updateUserField(String key, dynamic value) async {
    try {
      final userData = await getUserData() ?? {};
      userData[key] = value;
      return await saveUserData(userData);
    } catch (e) {
      debugPrint('Error updating user field: $e');
      return false;
    }
  }

  /// Delete user data
  Future<bool> deleteUserData() async {
    try {
      await _prefs.remove(_userDataKey);
      return true;
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      return false;
    }
  }

  // ==================== Authentication State Methods ====================

  /// Check if user is logged in
  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  /// Set login state
  Future<bool> setLoggedIn(bool value) async {
    try {
      await _prefs.setBool(_isLoggedInKey, value);
      return true;
    } catch (e) {
      debugPrint('Error setting login state: $e');
      return false;
    }
  }

  // ==================== Clear All Data (Logout) ====================

  /// Clear all stored data (use on logout)
  Future<bool> clearAll() async {
    try {
      // Clear secure storage (tokens)
      await _secureStorage.deleteAll();

      // Clear user data
      await _prefs.remove(_userDataKey);
      await _prefs.setBool(_isLoggedInKey, false);

      return true;
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      return false;
    }
  }

  // ==================== Generic Storage Methods ====================

  /// Save generic string value
  Future<bool> saveString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      return true;
    } catch (e) {
      debugPrint('Error saving string: $e');
      return false;
    }
  }

  /// Get generic string value
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      debugPrint('Error reading string: $e');
      return null;
    }
  }

  /// Save generic bool value
  Future<bool> saveBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      return true;
    } catch (e) {
      debugPrint('Error saving bool: $e');
      return false;
    }
  }

  /// Get generic bool value
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      debugPrint('Error reading bool: $e');
      return null;
    }
  }

  /// Save generic int value
  Future<bool> saveInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      return true;
    } catch (e) {
      debugPrint('Error saving int: $e');
      return false;
    }
  }

  /// Get generic int value
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      debugPrint('Error reading int: $e');
      return null;
    }
  }

  /// Remove a specific key
  Future<bool> remove(String key) async {
    try {
      await _prefs.remove(key);
      return true;
    } catch (e) {
      debugPrint('Error removing key: $e');
      return false;
    }
  }

  /// Check if a key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // ==================== App Preferences ====================

  Future<bool> savePreferredLanguage(String value) async {
    return saveString(_preferredLanguageKey, value);
  }

  String getPreferredLanguage() {
    return getString(_preferredLanguageKey) ?? 'fr';
  }

  Future<bool> saveNotificationsEnabled(bool value) async {
    return saveBool(_notificationsEnabledKey, value);
  }

  bool getNotificationsEnabled() {
    return getBool(_notificationsEnabledKey) ?? true;
  }

  Future<bool> savePreciseLocationEnabled(bool value) async {
    return saveBool(_preciseLocationEnabledKey, value);
  }

  bool getPreciseLocationEnabled() {
    return getBool(_preciseLocationEnabledKey) ?? true;
  }

  Future<bool> saveTechnicalInfoVisible(bool value) async {
    return saveBool(_technicalInfoVisibleKey, value);
  }

  bool getTechnicalInfoVisible() {
    return getBool(_technicalInfoVisibleKey) ?? false;
  }

  Future<void> resetAppPreferences() async {
    await remove(_preferredLanguageKey);
    await remove(_notificationsEnabledKey);
    await remove(_preciseLocationEnabledKey);
    await remove(_technicalInfoVisibleKey);
  }
}
