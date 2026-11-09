import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/refresh_token_interceptor.dart';
import '../interceptors/connectivity_interceptor.dart';
import '../interceptors/rate_limiter_interceptor.dart';
import '../interceptors/cache_interceptor.dart';
import '../interceptors/retry_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../connectivity/network_info.dart';
import 'http_client_interface.dart';

class DioClient implements HttpClient {
  @override
  late final Dio dio;

  DioClient(
    ApiConfig config, {
    Future<String?> Function()? authTokenProvider,
    Future<String?> Function()? refreshTokenProvider,
    Future<String?> Function(String refreshToken)? refreshTokenFunction,
    void Function(String accessToken, String? refreshToken)? onTokenRefreshed,
    NetworkInfo? networkInfo,
    List<Interceptor>? extraInterceptors,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (config.headers != null) ...config.headers!,
          if (config.defaultHeaders != null) ...config.defaultHeaders!,
        },
        responseType: ResponseType.json,
      ),
    );

    // Interceptor order is important:
    // 1. Connectivity → If no internet, reject immediately, don't proceed
    // 2. Auth         → Add token
    // 3. RateLimiter  → Rate limit control
    // 4. Cache        → Do not go to server if exists in cache
    // 5. Retry        → Retry on error
    // 6. Refresh      → Refresh token on 401 and retry request
    // 7. Logging      → At the end, log everything

    // 1. Connectivity
    if (networkInfo != null) {
      dio.interceptors.add(ConnectivityInterceptor(networkInfo: networkInfo));
    }

    // 2. Auth
    if (authTokenProvider != null) {
      dio.interceptors.add(
        AuthInterceptor(authTokenProvider: authTokenProvider),
      );
    }

    // 3. Rate Limiter
    if (config.enableRateLimiter) {
      dio.interceptors.add(RateLimiterInterceptor());
    }

    // 4. Cache
    if (config.enableCache) {
      dio.interceptors.add(CacheInterceptor());
    }

    // 5. Retry
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        maxRetries: config.maxRetries,
        baseDelay: config.retryBaseDelay,
        networkInfo: networkInfo,
      ),
    );

    // 6. Refresh Token
    if (refreshTokenFunction != null &&
        refreshTokenProvider != null &&
        onTokenRefreshed != null) {
      dio.interceptors.add(
        RefreshTokenInterceptor(
          dio: dio,
          refreshToken: refreshTokenFunction,
          getRefreshToken: refreshTokenProvider,
          onTokenRefreshed: onTokenRefreshed,
        ),
      );
    }

    // 7. Logging (last)
    if (config.enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    // 8. Extra interceptors (e.g. RequestsInspector for debug)
    if (extraInterceptors != null) {
      dio.interceptors.addAll(extraInterceptors);
    }
  }
}
