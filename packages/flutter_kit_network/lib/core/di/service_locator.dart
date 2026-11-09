import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:kit_network/core/di/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment_config.dart';
import '../config/api_config.dart';
import '../network/client/dio_client.dart';
import '../network/client/http_client_interface.dart';
import '../network/api/api_manager.dart';
import '../network/api/api_manager_interface.dart';
import '../network/serializer/json_serializer.dart';
import '../network/connectivity/network_info.dart';
import '../network/queue/request_queue.dart';
import '../network/queue/offline_queue.dart';
import '../network/analytics/analytics_manager.dart';
import '../network/logger/network_logger.dart';
import '../network/cache/persistent_cache_manager.dart';

export 'package:kit_network/core/di/locator.dart';

/// Enhanced service locator setup with EnvironmentConfig
///
/// Usage:
/// ```dart
/// await setupNetworking(
///   config: EnvironmentConfig.development(
///     baseUrl: 'https://api.example.com',
///   ),
///   tokenProvider: () async => await getToken(),
/// );
/// ```
Future<void> setupNetworking({
  required EnvironmentConfig config,
  Future<String?> Function()? tokenProvider,
  Future<String?> Function()? refreshTokenProvider,
  Future<String?> Function(String refreshToken)? refreshTokenFunction,
  void Function(String accessToken, String? refreshToken)? onTokenRefreshed,
  List<AnalyticsProvider>? analyticsProviders,
  List<Interceptor>? extraInterceptors,
  String locale = 'en_US',
}) async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<Connectivity>(Connectivity());

  // Environment config
  getIt.registerSingleton<EnvironmentConfig>(config);

  // Logger
  final logger = NetworkLogger(
    level: config.logLevel,
    enableColors: config.isDevelopment,
    enableTimestamp: true,
  );
  getIt.registerSingleton<NetworkLogger>(logger);

  // Network Info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );

  // Persistent Cache Manager
  final cacheManager = PersistentCacheManager();
  await cacheManager.init();
  getIt.registerSingleton<PersistentCacheManager>(cacheManager);

  // Request Queue (with priority)
  final requestQueue = RequestQueue(maxConcurrent: 3);
  getIt.registerSingleton<RequestQueue>(requestQueue);

  // Offline Queue
  final offlineQueue = OfflineQueue(
    prefs: sharedPreferences,
    networkInfo: getIt<NetworkInfo>(),
    executor: (request) async {
      final api = getIt<ApiManager>();
      final headers = request.headers?.map((k, v) => MapEntry(k, v.toString()));
      switch (request.method.toUpperCase()) {
        case 'GET':
          await api.get<dynamic>(path: request.url, headers: headers);
        case 'POST':
          await api.post<dynamic>(
            path: request.url,
            body: request.body,
            headers: headers,
          );
        case 'PUT':
          await api.put<dynamic>(
            path: request.url,
            body: request.body,
            headers: headers,
          );
        case 'PATCH':
          await api.patch<dynamic>(
            path: request.url,
            body: request.body,
            headers: headers,
          );
        case 'DELETE':
          await api.delete<dynamic>(
            path: request.url,
            body: request.body,
            headers: headers,
          );
      }
    },
  );
  await offlineQueue.init();
  getIt.registerSingleton<OfflineQueue>(offlineQueue);

  // Analytics Manager
  final analyticsManager = DefaultAnalyticsManager(
    providers: [
      if (config.isDevelopment) ConsoleAnalyticsProvider(),
      ...?analyticsProviders,
    ],
  );
  getIt.registerSingleton<AnalyticsManager>(analyticsManager);

  // Create ApiConfig from EnvironmentConfig
  final apiConfig = ApiConfig.fromEnvironmentConfig(config);

  // Http client with all interceptors
  getIt.registerLazySingleton<HttpClient>(
    () => DioClient(
      apiConfig,
      authTokenProvider: tokenProvider,
      refreshTokenProvider: refreshTokenProvider,
      refreshTokenFunction: refreshTokenFunction,
      onTokenRefreshed: onTokenRefreshed,
      networkInfo: getIt<NetworkInfo>(),
      extraInterceptors: extraInterceptors,
    ),
  );

  // Api manager with all features
  getIt.registerLazySingleton<ApiManager>(
    () => DioApiManager(
      client: getIt<HttpClient>(),
      serializer: const JsonSerializer(),
      requestQueue: requestQueue,
      analyticsManager: analyticsManager,
    ),
  );

  // A second, interceptor-free ApiManager used only for the token-refresh
  // HTTP call. It must never carry AuthInterceptor/RefreshTokenInterceptor:
  // the refresh call is what RefreshTokenInterceptor's onError waits on, so
  // routing it back through that same interceptor (e.g. if the refresh
  // token itself is expired and the call also comes back 401) would re-enter
  // its refresh lock and hang forever. It also gets its own RequestQueue so
  // ordinary API traffic can never starve it of a concurrency slot.
  getIt.registerLazySingleton<ApiManager>(
    () => DioApiManager(
      client: DioClient(apiConfig, networkInfo: getIt<NetworkInfo>()),
      serializer: const JsonSerializer(),
      requestQueue: RequestQueue(maxConcurrent: 1),
      analyticsManager: analyticsManager,
    ),
    instanceName: 'refreshApiManager',
  );

  logger.info('✅ Networking initialized for ${config.environment} environment');
}

/// Simple setup with ApiConfig directly
///
/// Usage:
/// ```dart
/// await setupNetworkingWithApiConfig(
///   config: ApiConfig(
///     baseUrl: 'https://api.example.com',
///     enableLogging: true,
///   ),
///   tokenProvider: () async => await getToken(),
/// );
/// ```
Future<void> setupNetworkingWithApiConfig({
  required ApiConfig config,
  Future<String?> Function()? tokenProvider,
  Future<String?> Function()? refreshTokenProvider,
  Future<String?> Function(String refreshToken)? refreshTokenFunction,
  void Function(String accessToken, String? refreshToken)? onTokenRefreshed,
  NetworkInfo? networkInfo,
}) async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  if (networkInfo != null) {
    getIt.registerSingleton<NetworkInfo>(networkInfo);
  } else {
    getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(Connectivity()),
    );
  }

  // Api manager
  getIt.registerLazySingleton<ApiManager>(
    () => DioApiManager(
      client: DioClient(
        config,
        authTokenProvider: tokenProvider,
        refreshTokenProvider: refreshTokenProvider,
        refreshTokenFunction: refreshTokenFunction,
        onTokenRefreshed: onTokenRefreshed,
        networkInfo: networkInfo ?? getIt<NetworkInfo>(),
      ),
      serializer: const JsonSerializer(),
    ),
  );

  NetworkLogger(
    level: config.logLevel,
    enableColors: true,
    enableTimestamp: true,
  ).info('✅ Networking initialized');
}

/// Reset and clear all dependencies
Future<void> resetNetworking() async {
  // Close resources
  if (getIt.isRegistered<PersistentCacheManager>()) {
    await getIt<PersistentCacheManager>().close();
  }

  if (getIt.isRegistered<OfflineQueue>()) {
    getIt<OfflineQueue>().dispose();
  }

  if (getIt.isRegistered<RequestQueue>()) {
    getIt<RequestQueue>().clear();
  }

  await getIt.reset();
}

/// Quick setup for simple use cases
Future<void> setupSimpleNetworking({
  required String baseUrl,
  Future<String?> Function()? tokenProvider,
  bool enableLogging = true,
}) async {
  await setupNetworkingWithApiConfig(
    config: ApiConfig(baseUrl: baseUrl, enableLogging: enableLogging),
    tokenProvider: tokenProvider,
  );
}

/// Get API Manager instance
ApiManager getApiManager() => getIt<ApiManager>();

/// Get Network Info instance
NetworkInfo getNetworkInfo() => getIt<NetworkInfo>();

/// Get Logger instance
NetworkLogger getLogger() => getIt<NetworkLogger>();

/// Get Analytics Manager instance (if registered)
AnalyticsManager? getAnalyticsManager() =>
    getIt.isRegistered<AnalyticsManager>() ? getIt<AnalyticsManager>() : null;

/// Get Cache Manager instance (if registered)
PersistentCacheManager? getCacheManager() =>
    getIt.isRegistered<PersistentCacheManager>()
    ? getIt<PersistentCacheManager>()
    : null;

/// Get Offline Queue instance (if registered)
OfflineQueue? getOfflineQueue() =>
    getIt.isRegistered<OfflineQueue>() ? getIt<OfflineQueue>() : null;

/// Get Request Queue instance (if registered)
RequestQueue? getRequestQueue() =>
    getIt.isRegistered<RequestQueue>() ? getIt<RequestQueue>() : null;
