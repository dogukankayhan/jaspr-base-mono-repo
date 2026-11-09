import '../network/logger/network_logger.dart';
import 'environment_config.dart';

/// API Configuration
class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, String>? headers;
  final Map<String, dynamic>? defaultHeaders;
  final int maxRetries;
  final Duration retryBaseDelay;
  final bool enableLogging;
  final LogLevel logLevel;
  final bool enableCache;
  final bool enableRateLimiter;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.headers,
    this.defaultHeaders,
    this.maxRetries = 3,
    this.retryBaseDelay = const Duration(seconds: 1),
    this.enableLogging = false,
    this.logLevel = LogLevel.info,
    this.enableCache = false,
    this.enableRateLimiter = false,
  });

  /// Create ApiConfig from EnvironmentConfig
  factory ApiConfig.fromEnvironmentConfig(EnvironmentConfig config) {
    return ApiConfig(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      defaultHeaders: config.defaultHeaders,
      maxRetries: config.maxRetries ?? 3,
      retryBaseDelay: config.retryBaseDelay ?? const Duration(seconds: 1),
      enableLogging: config.enableLogging,
      logLevel: config.logLevel,
      // Off, for every endpoint. [CacheInterceptor] answers a GET from memory
      // for five minutes and knows nothing about writes, so any save was
      // invisible to the next read until the process restarted — and a cache
      // hit is resolved with `callFollowingResponseInterceptor: true`, so it
      // reaches the logger and the request inspector looking exactly like a
      // fresh response from the server. Correctness first: nothing in the app
      // is slow enough to be worth reads that can silently be stale, and
      // turning it back on means giving it an invalidation contract first —
      // see [ApiManager.invalidateCache].
      enableCache: false,
      enableRateLimiter: true,
    );
  }

  /// Copy with method
  ApiConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? headers,
    Map<String, dynamic>? defaultHeaders,
    int? maxRetries,
    Duration? retryBaseDelay,
    bool? enableLogging,
    LogLevel? logLevel,
    bool? enableCache,
    bool? enableRateLimiter,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      headers: headers ?? this.headers,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      maxRetries: maxRetries ?? this.maxRetries,
      retryBaseDelay: retryBaseDelay ?? this.retryBaseDelay,
      enableLogging: enableLogging ?? this.enableLogging,
      logLevel: logLevel ?? this.logLevel,
      enableCache: enableCache ?? this.enableCache,
      enableRateLimiter: enableRateLimiter ?? this.enableRateLimiter,
    );
  }
}
