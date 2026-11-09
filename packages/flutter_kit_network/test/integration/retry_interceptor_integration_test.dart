@Tags(['integration'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_kit_network/core/network/interceptors/retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_test_server.dart';

// Local server — controllable status codes, no external network dependency.
// RetryInterceptor logic is what we're testing; the server is just a transport fixture.

Dio _buildDio(String baseUrl, {int maxRetries = 2, Duration? receiveTimeout}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl, receiveTimeout: receiveTimeout));
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      maxRetries: maxRetries,
      baseDelay: Duration.zero,
      waitUntilOnline: false,
    ),
  );
  return dio;
}

void main() {
  group('RetryInterceptor — integration (local server)', () {
    test(
      'retries GET on 500 exactly maxRetries times then throws',
      () async {
        var fetchCount = 0;
        final server = await LocalTestServer.start(
          handler: (req) async {
            fetchCount++;
            return fixedStatus(500)(req);
          },
        );
        addTearDown(server.close);

        final dio = _buildDio(server.baseUrl, maxRetries: 2);

        await expectLater(
          dio.get<dynamic>('/'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              500,
            ),
          ),
        );

        // 1 initial + 2 retries
        expect(fetchCount, 3);
      },
    );

    test(
      'succeeds without retrying when server eventually returns 200',
      () async {
        var calls = 0;
        final server = await LocalTestServer.start(
          handler: (req) async {
            calls++;
            final sc = calls <= 2 ? 500 : 200;
            req.response
              ..statusCode = sc
              ..write('{}');
            await req.response.close();
          },
        );
        addTearDown(server.close);

        final dio = _buildDio(server.baseUrl, maxRetries: 3);
        final res = await dio.get<dynamic>('/');

        expect(res.statusCode, 200);
        expect(calls, 3); // 2 failures + 1 success
      },
    );

    test(
      'does not retry POST on 500 — fails immediately',
      () async {
        var fetchCount = 0;
        final server = await LocalTestServer.start(
          handler: (req) async {
            fetchCount++;
            return fixedStatus(500)(req);
          },
        );
        addTearDown(server.close);

        final dio = _buildDio(server.baseUrl, maxRetries: 2);

        await expectLater(
          dio.post<dynamic>('/'),
          throwsA(isA<DioException>()),
        );

        expect(fetchCount, 1);
      },
    );

    test(
      'does not retry on 4xx client errors',
      () async {
        var fetchCount = 0;
        final server = await LocalTestServer.start(
          handler: (req) async {
            fetchCount++;
            return fixedStatus(404)(req);
          },
        );
        addTearDown(server.close);

        final dio = _buildDio(server.baseUrl, maxRetries: 2);

        await expectLater(
          dio.get<dynamic>('/'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              404,
            ),
          ),
        );

        expect(fetchCount, 1);
      },
    );

    test(
      'throws receiveTimeout when server is too slow',
      () async {
        final server = await LocalTestServer.start(
          handler: delayed(const Duration(seconds: 10)),
        );
        addTearDown(server.close);

        final dio = _buildDio(
          server.baseUrl,
          maxRetries: 0,
          receiveTimeout: const Duration(milliseconds: 500),
        );

        await expectLater(
          dio.get<dynamic>('/'),
          throwsA(
            isA<DioException>().having(
              (e) => e.type,
              'type',
              DioExceptionType.receiveTimeout,
            ),
          ),
        );
      },
    );

    test(
      'succeeds on 200 without triggering any retry',
      () async {
        var fetchCount = 0;
        final server = await LocalTestServer.start(
          handler: (req) async {
            fetchCount++;
            return fixedStatus(200)(req);
          },
        );
        addTearDown(server.close);

        final dio = _buildDio(server.baseUrl, maxRetries: 2);
        final res = await dio.get<dynamic>('/');

        expect(res.statusCode, 200);
        expect(fetchCount, 1);
      },
    );
  });
}
