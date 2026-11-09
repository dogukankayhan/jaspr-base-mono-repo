import 'package:dio/dio.dart';

class CacheInterceptor extends Interceptor {
  final Map<String, _CacheEntry> _cache = {};
  final Duration defaultMaxAge;
  final int maxEntries;

  CacheInterceptor({
    this.defaultMaxAge = const Duration(minutes: 5),
    this.maxEntries = 100,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Only cache GET requests
    if (options.method != 'GET') {
      return handler.next(options);
    }

    final cacheKey = _getCacheKey(options);
    final cached = _cache[cacheKey];

    if (cached != null) {
      if (!cached.isExpired) {
        return handler.resolve(cached.response, true);
      }
      // Delete expired entry
      _cache.remove(cacheKey);
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cache successful GET responses
    if (response.requestOptions.method == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final cacheKey = _getCacheKey(response.requestOptions);
      final maxAge = _getMaxAge(response);

      // If max entry limit is reached, clear expired entries
      if (_cache.length >= maxEntries) {
        _evictExpired();
      }
      // If still full, remove the oldest entry (LRU)
      if (_cache.length >= maxEntries) {
        _cache.remove(_cache.keys.first);
      }

      _cache[cacheKey] = _CacheEntry(
        response: response,
        expiresAt: DateTime.now().add(maxAge),
      );
    }

    handler.next(response);
  }

  /// Clear all expired entries
  void _evictExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  String _getCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final query = options.queryParameters.toString();
    return '$uri?$query';
  }

  Duration _getMaxAge(Response response) {
    final cacheControl = response.headers.value('cache-control');
    if (cacheControl != null) {
      final match = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
      if (match != null) {
        final seconds = int.tryParse(match.group(1)!);
        if (seconds != null) {
          return Duration(seconds: seconds);
        }
      }
    }
    return defaultMaxAge;
  }

  void clearCache() {
    _cache.clear();
  }

  void removeCacheEntry(String url) {
    _cache.removeWhere((key, _) => key.contains(url));
  }
}

class _CacheEntry {
  final Response response;
  final DateTime expiresAt;

  _CacheEntry({required this.response, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
