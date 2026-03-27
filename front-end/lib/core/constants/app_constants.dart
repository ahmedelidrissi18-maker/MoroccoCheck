import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';

class AppConstants {
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5001/api';
  static const String androidUsbDebugBaseUrl = 'http://127.0.0.1:5001/api';
  static const String _appEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
  );
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String firebaseAndroidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const String firebaseIosAppId = String.fromEnvironment(
    'FIREBASE_IOS_APP_ID',
  );
  static const String firebaseIosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );
  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String _sentryTracesSampleRate = String.fromEnvironment(
    'SENTRY_TRACES_SAMPLE_RATE',
    defaultValue: '0',
  );

  static String get appEnvironment => _appEnvironment;
  static double get sentryTracesSampleRate =>
      double.tryParse(_sentryTracesSampleRate) ?? 0;

  static String normalizeApiBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    final normalized = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    return normalized.endsWith('/api') ? normalized : '$normalized/api';
  }

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5001/api';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidEmulatorBaseUrl;
      default:
        return 'http://127.0.0.1:5001/api';
    }
  }

  static List<String> get androidConnectionFallbackBaseUrls {
    return const <String>[androidUsbDebugBaseUrl, androidEmulatorBaseUrl];
  }

  static String get baseUrl {
    final storedOverride = StorageService().getApiBaseUrl();
    if (storedOverride != null && storedOverride.isNotEmpty) {
      return normalizeApiBaseUrl(storedOverride);
    }

    if (_apiBaseUrlOverride.isNotEmpty) {
      return normalizeApiBaseUrl(_apiBaseUrlOverride);
    }

    return defaultBaseUrl;
  }

  static bool get supportsGoogleAuth {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get hasFirebaseCoreConfig {
    if (kIsWeb) {
      return false;
    }

    final hasSharedFields =
        firebaseApiKey.isNotEmpty &&
        firebaseProjectId.isNotEmpty &&
        firebaseMessagingSenderId.isNotEmpty;

    if (!hasSharedFields) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return firebaseAndroidAppId.isNotEmpty;
      case TargetPlatform.iOS:
        return firebaseIosAppId.isNotEmpty;
      default:
        return false;
    }
  }

  static bool get isGoogleSignInConfigured {
    if (!supportsGoogleAuth || !hasFirebaseCoreConfig) {
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return googleServerClientId.isNotEmpty && googleIosClientId.isNotEmpty;
    }

    return googleServerClientId.isNotEmpty;
  }

  static String? get firebaseStorageBucketOrNull {
    return firebaseStorageBucket.isEmpty ? null : firebaseStorageBucket;
  }

  static String? get firebaseIosBundleIdOrNull {
    return firebaseIosBundleId.isEmpty ? null : firebaseIosBundleId;
  }

  static String? get googleIosClientIdOrNull {
    return googleIosClientId.isEmpty ? null : googleIosClientId;
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String authBasePath = '/auth';
  static const String appVersion = '1.0.0+1';
  static const String supportEmail = '';
  static const String deepLinkScheme = 'moroccocheck';
  static const String focusCity = 'Agadir';
  static const String focusRegion = 'Souss-Massa';
  static const double focusLatitude = 30.4278;
  static const double focusLongitude = -9.5981;

  static bool get hasOperationalSupportContact {
    return supportEmail.trim().isNotEmpty &&
        !supportEmail.trim().toLowerCase().endsWith('.local');
  }

  AppConstants._();
}
