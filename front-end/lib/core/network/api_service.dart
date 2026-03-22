import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';
import '../../features/profile/presentation/models/leaderboard_entry.dart';
import '../../features/profile/presentation/models/badge_catalog_item.dart';
import '../../features/professional/models/professional_site_detail.dart';
import '../../features/professional/models/professional_site.dart';
import '../../features/sites/presentation/models/review.dart';
import '../../features/sites/presentation/models/site_photo.dart';
import '../../features/sites/presentation/sites/site.dart';
import '../../shared/models/site_category.dart';

class ApiService {
  static Future<bool>? _refreshFuture;

  late final Dio _dio;
  late final Dio _refreshDio;

  ApiService() {
    final options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);
    _refreshDio = Dio(options);
    _setupInterceptors();
  }

  bool _canRefreshRequest(RequestOptions options) {
    final path = options.path;
    final isAuthBootstrapRoute =
        path == '${AppConstants.authBasePath}/login' ||
        path == '${AppConstants.authBasePath}/register' ||
        path == '${AppConstants.authBasePath}/refresh';

    return options.extra['tokenRefreshed'] != true && !isAuthBootstrapRoute;
  }

  Future<void> _clearStoredSession() async {
    await StorageService().clearAll();
    _dio.options.headers.remove('Authorization');
  }

  Future<bool> _refreshAccessToken() async {
    final pendingRefresh = _refreshFuture;
    if (pendingRefresh != null) {
      return pendingRefresh;
    }

    final completer = Completer<bool>();
    _refreshFuture = completer.future;

    try {
      final refreshToken = await StorageService().getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _clearStoredSession();
        completer.complete(false);
        return completer.future;
      }

      final response = await _refreshDio.post(
        '${AppConstants.authBasePath}/refresh',
        data: <String, dynamic>{'refresh_token': refreshToken},
      );

      final payload = _asStringKeyedMap(_extractData(response.data));
      final accessToken =
          payload['access_token'] as String? ?? payload['token'] as String?;
      final nextRefreshToken = payload['refresh_token'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        await _clearStoredSession();
        completer.complete(false);
        return completer.future;
      }

      await StorageService().saveToken(accessToken);
      if (nextRefreshToken != null && nextRefreshToken.isNotEmpty) {
        await StorageService().saveRefreshToken(nextRefreshToken);
      }
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      completer.complete(true);
      return completer.future;
    } on DioException catch (_) {
      await _clearStoredSession();
      completer.complete(false);
      return completer.future;
    } catch (_) {
      await _clearStoredSession();
      completer.complete(false);
      return completer.future;
    } finally {
      _refreshFuture = null;
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService().getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint('REQUEST[${options.method}] => ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}',
          );

          final shouldRefresh =
              error.response?.statusCode == 401 &&
              _canRefreshRequest(error.requestOptions);

          if (shouldRefresh) {
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              final token = await StorageService().getToken();
              if (token != null && token.isNotEmpty) {
                final requestOptions = error.requestOptions;
                final retryResponse = await _dio.request<dynamic>(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  cancelToken: requestOptions.cancelToken,
                  onReceiveProgress: requestOptions.onReceiveProgress,
                  onSendProgress: requestOptions.onSendProgress,
                  options: Options(
                    method: requestOptions.method,
                    headers: <String, dynamic>{
                      ...requestOptions.headers,
                      'Authorization': 'Bearer $token',
                    },
                    extra: <String, dynamic>{
                      ...requestOptions.extra,
                      'tokenRefreshed': true,
                    },
                    responseType: requestOptions.responseType,
                    contentType: requestOptions.contentType,
                    sendTimeout: requestOptions.sendTimeout,
                    receiveTimeout: requestOptions.receiveTimeout,
                    followRedirects: requestOptions.followRedirects,
                    validateStatus: requestOptions.validateStatus,
                    receiveDataWhenStatusError:
                        requestOptions.receiveDataWhenStatusError,
                  ),
                );

                return handler.resolve(retryResponse);
              }
            }
          }

          return handler.reject(_handleError(error));
        },
      ),
    );
  }

  DioException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DioException(
          requestOptions: error.requestOptions,
          error:
              'Delai de connexion depasse. Verifiez votre connexion internet.',
          type: error.type,
        );
      case DioExceptionType.connectionError:
        return DioException(
          requestOptions: error.requestOptions,
          error: 'Impossible de se connecter au serveur.',
          type: error.type,
        );
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return error;
    }
  }

  String? _getErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String? ??
          data['errors']?.toString();
    }
    if (data is String) return data;
    return null;
  }

  ApiException _formatException(DioException e) {
    String message = 'Une erreur est survenue';
    int? statusCode;
    String? code;
    dynamic details;

    if (e.response != null) {
      statusCode = e.response?.statusCode;
      final responseMap = _asStringKeyedMap(e.response?.data);
      code = responseMap['code'] as String?;
      details = responseMap['details'];
      message =
          _getErrorMessage(responseMap) ??
          e.response?.statusMessage ??
          'Erreur serveur';
    } else if (e.error != null) {
      message = e.error.toString();
    } else if (e.message != null) {
      message = e.message!;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      type: e.type,
      code: code,
      details: details,
    );
  }

  Map<String, dynamic> _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return <String, dynamic>{};
  }

  dynamic _extractData(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload['data'] ?? payload;
    }
    if (payload is Map) {
      final map = _asStringKeyedMap(payload);
      return map['data'] ?? map;
    }
    return payload;
  }

  List<dynamic> _extractList(dynamic payload) {
    final data = _extractData(payload);
    if (data is List<dynamic>) {
      return data;
    }
    return <dynamic>[];
  }

  Future<List<Map<String, dynamic>>> _fetchAllPaginatedItems(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final baseParams = <String, dynamic>{...?queryParameters};
    final hasExplicitPage = baseParams.containsKey('page');

    if (hasExplicitPage) {
      final response = await get(path, queryParameters: baseParams);
      final items = _extractList(response.data);
      return items.whereType<Map>().map((item) {
        final rawMap = item;
        return rawMap.map((key, value) => MapEntry(key.toString(), value));
      }).toList();
    }

    final requestedLimit = int.tryParse('${baseParams['limit']}');
    final limit = requestedLimit != null && requestedLimit > 0
        ? requestedLimit
        : 100;

    final collected = <Map<String, dynamic>>[];
    var page = 1;

    while (true) {
      final response = await get(
        path,
        queryParameters: <String, dynamic>{
          ...baseParams,
          'page': page,
          'limit': limit,
        },
      );

      final items = _extractList(response.data);
      collected.addAll(
        items.whereType<Map>().map((item) {
          final rawMap = item;
          return rawMap.map((key, value) => MapEntry(key.toString(), value));
        }),
      );

      final responseMap = _asStringKeyedMap(response.data);
      final meta = _asStringKeyedMap(responseMap['meta']);
      final pagination = _asStringKeyedMap(meta['pagination']);
      final total = int.tryParse('${pagination['total']}');

      if (items.isEmpty) {
        break;
      }
      if (total != null && collected.length >= total) {
        break;
      }
      if (items.length < limit) {
        break;
      }

      page += 1;
    }

    return collected;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _formatException(e);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _formatException(e);
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _formatException(e);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _formatException(e);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _formatException(e);
    }
  }

  Future<void> updateAuthToken(String token) async {
    await StorageService().saveToken(token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> clearAuthToken() async {
    await StorageService().deleteToken();
    _dio.options.headers.remove('Authorization');
  }

  Future<void> submitCheckin({
    required String siteId,
    required double latitude,
    required double longitude,
    String? status,
    String? comment,
    bool hasPhoto = false,
  }) async {
    await post(
      '/checkins',
      data: <String, dynamic>{
        'site_id': int.tryParse(siteId) ?? 0,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': 20,
        'has_photo': hasPhoto,
        'status': status,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  Future<ReviewSubmissionResult> submitReview({
    required String siteId,
    required int rating,
    required String content,
    String? title,
  }) async {
    final response = await post(
      '/reviews',
      data: <String, dynamic>{
        'site_id': int.tryParse(siteId) ?? 0,
        'rating': rating,
        'content': content,
        if (title != null && title.isNotEmpty) 'title': title,
      },
    );

    final data = _asStringKeyedMap(_extractData(response.data));
    return ReviewSubmissionResult(
      moderationStatus: data['moderation_status'] as String?,
      pointsEarned: int.tryParse('${data['points_earned']}') ?? 0,
    );
  }

  Future<List<Site>> fetchSites({Map<String, dynamic>? queryParameters}) async {
    final items = await _fetchAllPaginatedItems(
      '/sites',
      queryParameters: queryParameters,
    );

    return items.map(Site.fromJson).toList();
  }

  Future<List<SiteCategory>> fetchCategories({
    bool topLevelOnly = false,
    bool includeChildren = true,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await get(
      '/categories',
      queryParameters: <String, dynamic>{
        ...?queryParameters,
        if (topLevelOnly) 'top_level': 'true',
        if (!includeChildren) 'include_children': 'false',
      },
    );
    final items = _extractList(response.data);

    return items.whereType<Map>().map((item) {
      final rawMap = item;
      return SiteCategory.fromJson(
        rawMap.map((key, value) => MapEntry(key.toString(), value)),
      );
    }).toList();
  }

  Future<List<ProfessionalSite>> fetchProfessionalSites({
    Map<String, dynamic>? queryParameters,
  }) async {
    final items = await _fetchAllPaginatedItems(
      '/sites/mine',
      queryParameters: queryParameters,
    );

    return items.map(ProfessionalSite.fromJson).toList();
  }

  Future<ProfessionalSiteDetail> fetchProfessionalSiteDetail(
    String siteId,
  ) async {
    final response = await get('/sites/mine/$siteId');
    final data = _asStringKeyedMap(_extractData(response.data));
    return ProfessionalSiteDetail.fromJson(data);
  }

  Future<ProfessionalSite> createSite({
    required String name,
    required int categoryId,
    required double latitude,
    required double longitude,
    String? description,
    String? address,
    String? city,
    String? region,
    String? phoneNumber,
    String? email,
    String? website,
    String? priceRange,
    bool acceptsCardPayment = false,
    bool hasWifi = false,
    bool hasParking = false,
    bool isAccessible = false,
  }) async {
    final response = await post(
      '/sites',
      data: <String, dynamic>{
        'name': name,
        'category_id': categoryId,
        'latitude': latitude,
        'longitude': longitude,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (address != null && address.isNotEmpty) 'address': address,
        if (city != null && city.isNotEmpty) 'city': city,
        if (region != null && region.isNotEmpty) 'region': region,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
        if (email != null && email.isNotEmpty) 'email': email,
        if (website != null && website.isNotEmpty) 'website': website,
        if (priceRange != null && priceRange.isNotEmpty)
          'price_range': priceRange,
        'accepts_card_payment': acceptsCardPayment,
        'has_wifi': hasWifi,
        'has_parking': hasParking,
        'is_accessible': isAccessible,
        'country': 'MA',
      },
    );

    final data = _asStringKeyedMap(_extractData(response.data));
    final siteData = _asStringKeyedMap(data['site'] ?? data);
    return ProfessionalSite.fromJson(siteData);
  }

  Future<ProfessionalSite> updateSite({
    required String siteId,
    required String name,
    required int categoryId,
    required double latitude,
    required double longitude,
    String? description,
    String? address,
    String? city,
    String? region,
    String? phoneNumber,
    String? email,
    String? website,
    String? priceRange,
    bool acceptsCardPayment = false,
    bool hasWifi = false,
    bool hasParking = false,
    bool isAccessible = false,
  }) async {
    final response = await put(
      '/sites/$siteId',
      data: <String, dynamic>{
        'name': name,
        'category_id': categoryId,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'address': address,
        'city': city,
        'region': region,
        'phone_number': phoneNumber,
        'email': email,
        'website': website,
        'price_range': priceRange,
        'accepts_card_payment': acceptsCardPayment,
        'has_wifi': hasWifi,
        'has_parking': hasParking,
        'is_accessible': isAccessible,
      },
    );

    final data = _asStringKeyedMap(_extractData(response.data));
    final siteData = _asStringKeyedMap(data['site'] ?? data);
    return ProfessionalSite.fromJson(siteData);
  }

  Future<Site> fetchSiteDetail(String siteId) async {
    final response = await get('/sites/$siteId');
    final data = _asStringKeyedMap(_extractData(response.data));
    final siteData = _asStringKeyedMap(data['site'] ?? data);
    return Site.fromJson(siteData);
  }

  Future<List<Review>> fetchSiteReviews(
    String siteId, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final items = await _fetchAllPaginatedItems(
      '/sites/$siteId/reviews',
      queryParameters: queryParameters,
    );

    return items.map(Review.fromJson).toList();
  }

  Future<List<SitePhoto>> fetchSitePhotos(
    String siteId, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final items = await _fetchAllPaginatedItems(
      '/sites/$siteId/photos',
      queryParameters: queryParameters,
    );

    return items.map(SitePhoto.fromJson).toList();
  }

  Future<Map<String, dynamic>> fetchMyStats() async {
    final response = await get('/users/me/stats');
    return _asStringKeyedMap(_extractData(response.data));
  }

  Future<UserProfileUpdateResult> updateMyProfile({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? nationality,
    String? bio,
    String? profilePicture,
  }) async {
    final response = await put(
      '${AppConstants.authBasePath}/profile',
      data: <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'nationality': nationality,
        'bio': bio,
        'profile_picture': profilePicture,
      },
    );

    final data = _asStringKeyedMap(_extractData(response.data));
    final userData = _asStringKeyedMap(data['user'] ?? data);
    final badges = data['badges'];

    return UserProfileUpdateResult(
      userData: userData,
      badges: badges is List ? badges : const <dynamic>[],
    );
  }

  Future<List<Map<String, dynamic>>> fetchMyBadges() async {
    final response = await get('/users/me/badges');
    final items = _extractList(response.data);

    return items.whereType<Map>().map((item) {
      final rawMap = item;
      return rawMap.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  Future<List<BadgeCatalogItem>> fetchBadgesCatalog() async {
    final response = await get('/badges');
    final items = _extractList(response.data);

    return items.whereType<Map>().map((item) {
      final rawMap = item;
      return BadgeCatalogItem.fromJson(
        rawMap.map((key, value) => MapEntry(key.toString(), value)),
      );
    }).toList();
  }

  Future<PaginatedResult<LeaderboardEntry>> fetchLeaderboard({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get(
      '/leaderboard',
      queryParameters: <String, dynamic>{'page': page, 'limit': limit},
    );
    final items = _extractList(response.data);
    final responseMap = _asStringKeyedMap(response.data);
    final meta = _asStringKeyedMap(responseMap['meta']);
    final pagination = _asStringKeyedMap(meta['pagination']);

    return PaginatedResult<LeaderboardEntry>(
      items: items.whereType<Map>().map((item) {
        final rawMap = item;
        return LeaderboardEntry.fromJson(
          rawMap.map((key, value) => MapEntry(key.toString(), value)),
        );
      }).toList(),
      page: int.tryParse('${pagination['page']}') ?? page,
      limit: int.tryParse('${pagination['limit']}') ?? limit,
      total: int.tryParse('${pagination['total']}') ?? items.length,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final DioExceptionType? type;
  final String? code;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.type,
    this.code,
    this.details,
  });

  @override
  String toString() => message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;
}

class ReviewSubmissionResult {
  final String? moderationStatus;
  final int pointsEarned;

  const ReviewSubmissionResult({
    required this.moderationStatus,
    required this.pointsEarned,
  });

  bool get isPendingModeration => moderationStatus == 'PENDING';
  bool get isPublished => moderationStatus == 'APPROVED';
}

class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int limit;
  final int total;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });
}

class UserProfileUpdateResult {
  final Map<String, dynamic> userData;
  final List<dynamic> badges;

  const UserProfileUpdateResult({required this.userData, required this.badges});
}
