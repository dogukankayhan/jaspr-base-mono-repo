@Tags(['integration'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_kit_network/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_kit_network/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

// DummyJSON — free public API with real JWT auth
// Docs: https://dummyjson.com/docs/auth
const _kBase = 'https://dummyjson.com';
const _kUsername = 'emilys';
const _kPassword = 'emilyspass';

// Login and return fresh tokens
Future<({String accessToken, String refreshToken})> _login() async {
  final res = await Dio().post<Map<String, dynamic>>(
    '$_kBase/auth/login',
    data: {'username': _kUsername, 'password': _kPassword},
  );
  return (
    accessToken: res.data!['accessToken'] as String,
    refreshToken: res.data!['refreshToken'] as String,
  );
}

// Calls /auth/refresh and returns new accessToken (null on failure)
Future<String?> _doRefresh(String refreshToken) async {
  try {
    final res = await Dio().post<Map<String, dynamic>>(
      '$_kBase/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return res.data!['accessToken'] as String?;
  } catch (_) {
    return null;
  }
}

Dio _buildDio({
  required String Function() currentToken,
  required Future<String?> Function() getRefreshToken,
  required void Function(String) onRefreshed,
}) {
  final dio = Dio(BaseOptions(baseUrl: _kBase));
  dio.interceptors.add(
    RefreshTokenInterceptor(
      dio: dio,
      getRefreshToken: getRefreshToken,
      refreshToken: _doRefresh,
      onTokenRefreshed: (newAccess, _) => onRefreshed(newAccess),
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(authTokenProvider: () async => currentToken()),
  );
  return dio;
}

void main() {
  group('RefreshTokenInterceptor — integration (DummyJSON)', () {
    test(
      'recovers from 401 caused by invalid access token and retries successfully',
      () async {
        final tokens = await _login();
        var currentAccess = 'deliberately-invalid-token';

        final dio = _buildDio(
          currentToken: () => currentAccess,
          getRefreshToken: () async => tokens.refreshToken,
          onRefreshed: (t) => currentAccess = t,
        );

        // /auth/me returns 401 with invalid access token.
        // Interceptor should refresh and retry automatically.
        final res = await dio.get<Map<String, dynamic>>('/auth/me');

        expect(res.statusCode, 200);
        expect(res.data!['username'], _kUsername);
        // Token was updated after refresh
        expect(currentAccess, isNot('deliberately-invalid-token'));
      },
    );

    test(
      'calls the refresh endpoint exactly once when 3 requests hit 401 concurrently',
      () async {
        final tokens = await _login();
        var currentAccess = 'deliberately-invalid-token';
        var refreshCallCount = 0;

        final dio = Dio(BaseOptions(baseUrl: _kBase));
        dio.interceptors.add(
          RefreshTokenInterceptor(
            dio: dio,
            getRefreshToken: () async => tokens.refreshToken,
            refreshToken: (rt) async {
              refreshCallCount++;
              // Small delay to ensure concurrent requests all enter _ensureFreshToken
              await Future<void>.delayed(const Duration(milliseconds: 80));
              return _doRefresh(rt);
            },
            onTokenRefreshed: (newAccess, _) => currentAccess = newAccess,
          ),
        );
        dio.interceptors.add(
          AuthInterceptor(authTokenProvider: () async => currentAccess),
        );

        final results = await Future.wait([
          dio.get<Map<String, dynamic>>('/auth/me'),
          dio.get<Map<String, dynamic>>('/auth/me'),
          dio.get<Map<String, dynamic>>('/auth/me'),
        ]);

        for (final res in results) {
          expect(res.statusCode, 200);
        }
        // All three requests shared the single refresh call
        expect(refreshCallCount, 1);
      },
    );

    test(
      'propagates 401 when the refresh token itself is invalid',
      () async {
        var currentAccess = 'invalid-access';

        final dio = _buildDio(
          currentToken: () => currentAccess,
          getRefreshToken: () async => 'invalid-refresh-token',
          onRefreshed: (_) {},
        );

        await expectLater(
          dio.get<dynamic>('/auth/me'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
      },
    );

    test(
      'valid token reaches protected endpoint without triggering refresh',
      () async {
        final tokens = await _login();
        var refreshCallCount = 0;

        final dio = Dio(BaseOptions(baseUrl: _kBase));
        dio.interceptors.add(
          RefreshTokenInterceptor(
            dio: dio,
            getRefreshToken: () async => tokens.refreshToken,
            refreshToken: (rt) async {
              refreshCallCount++;
              return _doRefresh(rt);
            },
            onTokenRefreshed: (_, _) {},
          ),
        );
        dio.interceptors.add(
          AuthInterceptor(authTokenProvider: () async => tokens.accessToken),
        );

        final res = await dio.get<Map<String, dynamic>>('/auth/me');

        expect(res.statusCode, 200);
        expect(refreshCallCount, 0);
      },
    );
  });
}
