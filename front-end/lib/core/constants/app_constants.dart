import 'package:flutter/foundation.dart';

class AppConstants {
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:5001/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:5001/api';
      default:
        return 'http://127.0.0.1:5001/api';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String authBasePath = '/auth';
  static const String appVersion = '1.0.0+1';
  static const String supportEmail = 'support@moroccocheck.local';
  static const String focusCity = 'Agadir';
  static const String focusRegion = 'Souss-Massa';
  static const double focusLatitude = 30.4278;
  static const double focusLongitude = -9.5981;

  AppConstants._();
}
