import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../connectivity/network_info.dart';

/// Retries only idempotent requests (GET/HEAD) with exponential backoff + jitter.
/// If offline, optionally waits until connectivity is restored before retrying.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;
  final bool waitUntilOnline;

  /// Source of connectivity state used by [waitUntilOnline]. Left null, the
  /// interceptor assumes it is online and retries on backoff alone.
  final NetworkInfo? networkInfo;

  /// How long to wait for connectivity to come back before giving up and
  /// letting the original error propagate. Without this bound, a flaky or
  /// incorrect connectivity report (a known issue on some emulators)
  /// can make this wait forever, since `onConnectivityChanged` may never
  /// fire again if the device was actually online the whole time — which
  /// permanently occupies one of `RequestQueue`'s concurrency slots and
  /// starves every other queued request (e.g. an unrelated POST) behind it.
  final Duration maxOfflineWait;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 400),
    this.waitUntilOnline = true,
    this.maxOfflineWait = const Duration(seconds: 15),
    this.networkInfo,
  });

  bool _isIdempotent(String method) =>
      const ['GET', 'HEAD'].contains(method.toUpperCase());

  bool _isRetryable(DioException err) {
    final sc = err.response?.statusCode;
    final type = err.type;
    final retryableType =
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.unknown;
    final serverError = sc != null && sc >= 500;
    return retryableType || serverError;
  }

  Future<void> _waitBackoff(int attempt) async {
    final jitter = (Random().nextDouble() * 0.4) + 0.8; // 0.8x – 1.2x
    final delay = baseDelay * (1 << attempt);
    await Future<void>.delayed(
      Duration(milliseconds: (delay.inMilliseconds * jitter).round()),
    );
  }

  Future<void> _waitUntilOnlineIfNeeded() async {
    final info = networkInfo;
    if (!waitUntilOnline || info == null) return;
    if (await info.isConnected) return;
    // Wait until we're back online, but don't wait forever.
    await info.onConnectivityChanged
        .firstWhere((online) => online)
        .timeout(maxOfflineWait, onTimeout: () => false);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final current = (requestOptions.extra['retries'] as int?) ?? 0;

    if (!_isIdempotent(requestOptions.method) ||
        !_isRetryable(err) ||
        current >= maxRetries) {
      return handler.next(err);
    }

    await _waitUntilOnlineIfNeeded();
    await _waitBackoff(current);

    requestOptions.extra['retries'] = current + 1;

    try {
      final Response response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}
