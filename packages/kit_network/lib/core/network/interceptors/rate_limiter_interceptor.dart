import 'dart:async';
import 'package:dio/dio.dart';

/// Rate limiter interceptor
///
/// Features:
/// - Per-endpoint rate limiting
/// - Global rate limiting
/// - Configurable time windows
/// - Auto-retry with delay
/// - Rate limit status tracking
class RateLimiterInterceptor extends Interceptor {
  final Map<String, _RateLimitBucket> _buckets = {};
  final int? globalLimit;
  final Duration window;
  final bool autoRetry;

  RateLimiterInterceptor({
    this.globalLimit,
    this.window = const Duration(minutes: 1),
    this.autoRetry = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = _getEndpointKey(options);
    final bucket = _getBucket(key);

    if (!bucket.tryConsume()) {
      if (autoRetry) {
        // Calculate wait time
        final waitTime = bucket.getWaitTime();

        // Delay and retry
        Future.delayed(waitTime, () {
          handler.next(options);
        });
      } else {
        // Reject immediately
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            error: RateLimitException(
              'Rate limit exceeded for $key. Retry after ${bucket.getWaitTime()}',
            ),
          ),
        );
      }
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check for rate limit headers
    final remaining = response.headers.value('x-ratelimit-remaining');
    final resetTime = response.headers.value('x-ratelimit-reset');

    if (remaining != null && resetTime != null) {
      final key = _getEndpointKey(response.requestOptions);
      final bucket = _getBucket(key);

      bucket.updateFromHeaders(
        remaining: int.tryParse(remaining) ?? 0,
        resetTime: int.tryParse(resetTime),
      );
    }

    handler.next(response);
  }

  String _getEndpointKey(RequestOptions options) {
    // Use path as key (you can customize this)
    return '${options.method}:${options.path}';
  }

  _RateLimitBucket _getBucket(String key) {
    return _buckets.putIfAbsent(
      key,
      () => _RateLimitBucket(limit: globalLimit ?? 100, window: window),
    );
  }

  /// Configure rate limit for specific endpoint
  void configureEndpoint(
    String endpoint, {
    required int limit,
    Duration? window,
  }) {
    _buckets[endpoint] = _RateLimitBucket(
      limit: limit,
      window: window ?? this.window,
    );
  }

  /// Get rate limit status for endpoint
  RateLimitStatus? getStatus(String endpoint) {
    final bucket = _buckets[endpoint];
    return bucket?.getStatus();
  }

  /// Reset all rate limits
  void reset() {
    _buckets.clear();
  }
}

class _RateLimitBucket {
  final int limit;
  final Duration window;
  final List<DateTime> _requests = [];
  int? _remainingFromServer;
  DateTime? _resetTimeFromServer;

  _RateLimitBucket({required this.limit, required this.window});

  bool tryConsume() {
    _cleanup();

    // Check server-provided limits first
    if (_remainingFromServer != null) {
      if (_remainingFromServer! <= 0) {
        if (_resetTimeFromServer != null &&
            DateTime.now().isAfter(_resetTimeFromServer!)) {
          // Reset period passed
          _remainingFromServer = null;
          _resetTimeFromServer = null;
        } else {
          return false;
        }
      }
    }

    // Check local limit
    if (_requests.length >= limit) {
      return false;
    }

    _requests.add(DateTime.now());
    if (_remainingFromServer != null) {
      _remainingFromServer = _remainingFromServer! - 1;
    }

    return true;
  }

  Duration getWaitTime() {
    // Use server reset time if available
    if (_resetTimeFromServer != null) {
      final wait = _resetTimeFromServer!.difference(DateTime.now());
      return wait.isNegative ? Duration.zero : wait;
    }

    // Otherwise use local window
    _cleanup();
    if (_requests.isEmpty) return Duration.zero;

    final oldestRequest = _requests.first;
    final elapsed = DateTime.now().difference(oldestRequest);
    final remaining = window - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  void updateFromHeaders({required int remaining, int? resetTime}) {
    _remainingFromServer = remaining;

    if (resetTime != null) {
      _resetTimeFromServer = DateTime.fromMillisecondsSinceEpoch(
        resetTime * 1000,
      );
    }
  }

  void _cleanup() {
    final cutoff = DateTime.now().subtract(window);
    _requests.removeWhere((time) => time.isBefore(cutoff));
  }

  RateLimitStatus getStatus() {
    _cleanup();

    return RateLimitStatus(
      limit: limit,
      remaining: limit - _requests.length,
      resetTime: _resetTimeFromServer,
      windowEnd: _requests.isEmpty
          ? DateTime.now()
          : _requests.first.add(window),
    );
  }
}

class RateLimitStatus {
  final int limit;
  final int remaining;
  final DateTime? resetTime;
  final DateTime windowEnd;

  RateLimitStatus({
    required this.limit,
    required this.remaining,
    this.resetTime,
    required this.windowEnd,
  });

  @override
  String toString() =>
      '''
RateLimitStatus(
  limit: $limit,
  remaining: $remaining,
  resetTime: $resetTime,
  windowEnd: $windowEnd
)''';
}

class RateLimitException implements Exception {
  final String message;

  RateLimitException(this.message);

  @override
  String toString() => message;
}
