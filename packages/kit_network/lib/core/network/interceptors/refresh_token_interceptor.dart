import 'dart:async';
import 'package:dio/dio.dart';

typedef RefreshTokenFunction = Future<String?> Function(String refreshToken);
typedef RefreshTokenProvider = Future<String?> Function();
typedef AccessTokenSaver =
    void Function(String accessToken, String? refreshToken);

class RefreshTokenInterceptor extends Interceptor {
  final Dio dio;
  final RefreshTokenFunction refreshToken;
  final RefreshTokenProvider getRefreshToken;
  final AccessTokenSaver onTokenRefreshed;

  bool _isRefreshing = false;
  final List<Completer<String?>> _waiters = [];

  RefreshTokenInterceptor({
    required this.dio,
    required this.refreshToken,
    required this.getRefreshToken,
    required this.onTokenRefreshed,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    // Prevent infinite loop
    if (requestOptions.extra['retryAfterRefresh'] == true) {
      return handler.next(err);
    }

    try {
      final newAccess = await _ensureFreshToken();
      if (newAccess == null || newAccess.isEmpty) {
        return handler.next(err);
      }

      final RequestOptions replay = requestOptions
        ..headers['Authorization'] = 'Bearer $newAccess'
        ..extra['retryAfterRefresh'] = true;

      final response = await dio.fetch(replay);
      return handler.resolve(response);
    } catch (exception) {
      return handler.next(err);
    }
  }

  Future<String?> _ensureFreshToken() async {
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _waiters.add(completer);
      // Backstop: the only thing that ever completes a waiter is the
      // in-flight refresh's `finally` block. If that refresh call somehow
      // never resolves (e.g. it re-enters this same lock), fall back to
      // propagating the original error instead of hanging forever.
      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );
    }

    _isRefreshing = true;
    String? newAccessToken;
    try {
      final currentRefreshToken = await getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        return null;
      }

      newAccessToken = await refreshToken(currentRefreshToken);
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        onTokenRefreshed(newAccessToken, currentRefreshToken);
      }
      return newAccessToken;
    } finally {
      // drain waiters
      final waiters = List<Completer<String?>>.from(_waiters);
      _waiters.clear();
      for (final waiter in waiters) {
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          waiter.complete(newAccessToken);
        } else {
          waiter.complete(null);
        }
      }
      _isRefreshing = false;
    }
  }
}
