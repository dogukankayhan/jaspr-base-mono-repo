import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/refresh_token_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  group('RefreshTokenInterceptor Tests', () {
    late Dio dio;
    late MockAdapter mockAdapter;
    late int fetchCount;
    late List<String> savedTokens;

    setUp(() {
      dio = Dio();
      mockAdapter = MockAdapter();
      dio.httpClientAdapter = mockAdapter;
      fetchCount = 0;
      savedTokens = [];
    });

    test(
      'automatically refreshes token on 401 and retries original request',
      () async {
        dio.interceptors.add(
          RefreshTokenInterceptor(
            dio: dio,
            getRefreshToken: () async => 'valid_refresh_token',
            refreshToken: (refreshToken) async {
              if (refreshToken == 'valid_refresh_token') {
                return 'new_access_token';
              }
              return null;
            },
            onTokenRefreshed: (accessToken, refreshToken) {
              savedTokens.add(accessToken);
            },
          ),
        );

        mockAdapter.fetchHandler = (options) async {
          fetchCount++;
          if (fetchCount == 1) {
            return ResponseBody.fromString(
              '{"error": "Unauthorized"}',
              401,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }

          final authHeader = options.headers['Authorization'];
          if (authHeader == 'Bearer new_access_token') {
            return ResponseBody.fromString(
              '{"success": true}',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }

          return ResponseBody.fromString('{"error": "Bad Token"}', 400);
        };

        final response = await dio.get<Map<String, dynamic>>('/test');

        expect(response.statusCode, 200);
        expect(response.data!['success'], true);
        expect(fetchCount, 2);
        expect(savedTokens, ['new_access_token']);
      },
    );

    test(
      'does not retry and propagates error if new token is null/empty',
      () async {
        dio.interceptors.add(
          RefreshTokenInterceptor(
            dio: dio,
            getRefreshToken: () async => 'valid_refresh_token',
            refreshToken: (refreshToken) async => null,
            onTokenRefreshed: (accessToken, refreshToken) {},
          ),
        );

        mockAdapter.fetchHandler = (options) async {
          fetchCount++;
          return ResponseBody.fromString('{"error": "Unauthorized"}', 401);
        };

        await expectLater(
          dio.get<dynamic>('/test'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );

        expect(fetchCount, 1);
      },
    );

    test(
      'handles concurrent 401s by queueing waiters and calling refresh token only once',
      () async {
        int refreshCallCount = 0;

        dio.interceptors.add(
          RefreshTokenInterceptor(
            dio: dio,
            getRefreshToken: () async => 'valid_refresh_token',
            refreshToken: (refreshToken) async {
              refreshCallCount++;
              await Future<void>.delayed(const Duration(milliseconds: 100));
              return 'shared_new_token';
            },
            onTokenRefreshed: (accessToken, refreshToken) {
              savedTokens.add(accessToken);
            },
          ),
        );

        mockAdapter.fetchHandler = (options) async {
          fetchCount++;
          final authHeader = options.headers['Authorization'];
          if (authHeader == 'Bearer shared_new_token') {
            return ResponseBody.fromString('{"success": true}', 200);
          }
          return ResponseBody.fromString('{"error": "Unauthorized"}', 401);
        };

        final results = await Future.wait([
          dio.get<void>('/req1'),
          dio.get<void>('/req2'),
          dio.get<void>('/req3'),
        ]);

        for (final res in results) {
          expect(res.statusCode, 200);
        }

        expect(refreshCallCount, 1);
        expect(fetchCount, 6); // 3 initial + 3 retry
        expect(savedTokens, ['shared_new_token']);
      },
    );
  });
}
