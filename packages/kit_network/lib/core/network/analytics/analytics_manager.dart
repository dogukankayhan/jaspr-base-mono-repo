import 'package:kit_network/core/utils/kit_print.dart';

/// Analytics manager for request monitoring
///
/// Features:
/// - Request lifecycle tracking
/// - Performance metrics
/// - Error tracking
/// - Custom event tracking
/// - Pluggable analytics providers
abstract class AnalyticsManager {
  /// Track request start
  void trackRequestStart(String path, String method);

  /// Track successful request
  void trackRequestSuccess(String path, String method, Duration duration);

  /// Track failed request
  void trackRequestFailure(
    String path,
    String method,
    Duration duration,
    dynamic error,
  );

  /// Track unexpected error
  void trackRequestError(
    String path,
    String method,
    Duration duration,
    dynamic error,
  );

  /// Track custom event
  void trackEvent(String eventName, [Map<String, dynamic>? properties]);

  /// Get analytics metrics
  AnalyticsMetrics getMetrics();
}

/// Default analytics implementation with in-memory metrics
class DefaultAnalyticsManager implements AnalyticsManager {
  final _metrics = AnalyticsMetrics();
  final List<AnalyticsProvider> _providers = [];

  DefaultAnalyticsManager({List<AnalyticsProvider>? providers}) {
    if (providers != null) {
      _providers.addAll(providers);
    }
  }

  @override
  void trackRequestStart(String path, String method) {
    _metrics._totalRequests++;
    _metrics._activeRequests++;

    for (final provider in _providers) {
      provider.trackRequestStart(path, method);
    }
  }

  @override
  void trackRequestSuccess(String path, String method, Duration duration) {
    _metrics._decrementActive();
    _metrics._successfulRequests++;
    _metrics._totalDuration += duration;

    for (final provider in _providers) {
      provider.trackRequestSuccess(path, method, duration);
    }
  }

  @override
  void trackRequestFailure(
    String path,
    String method,
    Duration duration,
    dynamic error,
  ) {
    _metrics._decrementActive();
    _metrics._failedRequests++;
    _metrics._totalDuration += duration;

    for (final provider in _providers) {
      provider.trackRequestFailure(path, method, duration, error);
    }
  }

  @override
  void trackRequestError(
    String path,
    String method,
    Duration duration,
    dynamic error,
  ) {
    _metrics._decrementActive();
    _metrics._failedRequests++;

    for (final provider in _providers) {
      provider.trackRequestError(path, method, duration, error);
    }
  }

  @override
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    for (final provider in _providers) {
      provider.trackEvent(eventName, properties);
    }
  }

  @override
  AnalyticsMetrics getMetrics() => _metrics;

  /// Add analytics provider
  void addProvider(AnalyticsProvider provider) {
    _providers.add(provider);
  }

  /// Remove analytics provider
  void removeProvider(AnalyticsProvider provider) {
    _providers.remove(provider);
  }

  /// Reset metrics
  void resetMetrics() {
    _metrics._totalRequests = 0;
    _metrics._successfulRequests = 0;
    _metrics._failedRequests = 0;
    _metrics._activeRequests = 0;
    _metrics._totalDuration = Duration.zero;
  }
}

/// Analytics metrics
class AnalyticsMetrics {
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  int _activeRequests = 0;
  Duration _totalDuration = Duration.zero;

  void _decrementActive() {
    if (_activeRequests > 0) _activeRequests--;
  }

  int get totalRequests => _totalRequests;
  int get successfulRequests => _successfulRequests;
  int get failedRequests => _failedRequests;
  int get activeRequests => _activeRequests;

  double get successRate =>
      _totalRequests == 0 ? 0.0 : (_successfulRequests / _totalRequests) * 100;

  double get averageResponseTime => _totalRequests == 0
      ? 0.0
      : _totalDuration.inMilliseconds / _totalRequests;

  @override
  String toString() =>
      '''
AnalyticsMetrics(
  totalRequests: $totalRequests,
  successful: $successfulRequests,
  failed: $failedRequests,
  active: $activeRequests,
  successRate: ${successRate.toStringAsFixed(2)}%,
  avgResponseTime: ${averageResponseTime.toStringAsFixed(2)}ms
)''';
}

/// Analytics provider interface
///
/// Implement this to integrate with third-party analytics:
/// - Firebase Analytics
/// - Mixpanel
/// - Amplitude
/// - Custom analytics
abstract class AnalyticsProvider {
  void trackRequestStart(String path, String method);
  void trackRequestSuccess(String path, String method, Duration duration);
  void trackRequestFailure(
    String path,
    String method,
    Duration duration,
    dynamic error,
  );
  void trackRequestError(
    String path,
    String method,
    Duration duration,
    dynamic error,
  );
  void trackEvent(String eventName, [Map<String, dynamic>? properties]);
}

/// Console logger analytics provider (for debugging)
class ConsoleAnalyticsProvider implements AnalyticsProvider {
  @override
  void trackRequestStart(String path, String method) {
    kitPrint('📤 [$method] $path - Started');
  }

  @override
  void trackRequestSuccess(String path, String method, Duration duration) {
    kitPrint('✅ [$method] $path - Success (${duration.inMilliseconds}ms)');
  }

  @override
  void trackRequestFailure(
    String path,
    String method,
    Duration duration,
    dynamic error,
  ) {
    kitPrint(
      '❌ [$method] $path - Failed (${duration.inMilliseconds}ms): $error',
    );
  }

  @override
  void trackRequestError(
    String path,
    String method,
    Duration duration,
    dynamic error,
  ) {
    kitPrint(
      '⚠️ [$method] $path - Error (${duration.inMilliseconds}ms): $error',
    );
  }

  @override
  void trackEvent(String eventName, [Map<String, dynamic>? properties]) {
    kitPrint('📊 Event: $eventName ${properties ?? ''}');
  }
}
