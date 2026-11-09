import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/retry_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RetryInterceptor Tests', () {
    late Dio dio;
    late MockAdapter mockAdapter;
    late int fetchCount;

    setUp(() {
      dio = Dio();
      mockAdapter = MockAdapter();
      dio.httpClientAdapter = mockAdapter;
      fetchCount = 0;
    });

    test(
      'retries idempotent GET request up to maxRetries on 500 error',
      () async {
        dio.interceptors.add(
          RetryInterceptor(
            dio: dio,
            maxRetries: 2,
            baseDelay: Duration.zero,
            waitUntilOnline: false,
          ),
        );

        mockAdapter.fetchHandler = (options) async {
          fetchCount++;
          if (fetchCount < 3) {
            return ResponseBody.fromString(
              '{"error": "Internal Server Error"}',
              500,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          return ResponseBody.fromString(
            '{"success": true}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final response = await dio.get<Map<String, dynamic>>('/test');

        expect(response.statusCode, 200);
        expect(response.data!['success'], true);
        expect(fetchCount, 3);
      },
    );

    test(
      'stops retrying after maxRetries is reached and propagates error',
      () async {
        dio.interceptors.add(
          RetryInterceptor(
            dio: dio,
            maxRetries: 2,
            baseDelay: Duration.zero,
            waitUntilOnline: false,
          ),
        );

        mockAdapter.fetchHandler = (options) async {
          fetchCount++;
          return ResponseBody.fromString(
            '{"error": "Internal Server Error"}',
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        await expectLater(
          dio.get<dynamic>('/test'),
          throwsA(
            isA<DioException>().having(
              (e) => e.response?.statusCode,
              'statusCode',
              500,
            ),
          ),
        );

        expect(fetchCount, 3);
      },
    );

    test(
      'does not retry non-idempotent POST request and propagates error immediately',
      () async {
        dio.interceptors.add(
          RetryInterceptor(
            dio: dio,
            maxRetries: 2,
            baseDelay: Duration.zero,
            waitUntilOnline: false,
          ),
        );

        mockAdapter.fetchHandler = (options) async {
          fetchCount++;
          return ResponseBody.fromString(
            '{"error": "Internal Server Error"}',
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        await expectLater(
          dio.post<dynamic>('/test'),
          throwsA(isA<DioException>()),
        );

        expect(fetchCount, 1);
      },
    );

    test('waits until online if waitUntilOnline is true', () async {
      // Starts offline, comes back online → the retry proceeds.
      final networkInfo = MockNetworkInfo()
        ..isConnectedResult = false
        ..onConnectivityChangedStream = Stream.fromIterable([false, true]);

      dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          maxRetries: 1,
          baseDelay: Duration.zero,
          waitUntilOnline: true,
          networkInfo: networkInfo,
        ),
      );

      mockAdapter.fetchHandler = (options) async {
        fetchCount++;
        if (fetchCount == 1) {
          return ResponseBody.fromString(
            '{"error": "Timeout"}',
            504,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{"success": true}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final response = await dio.get<dynamic>('/test');
      expect(response.statusCode, 200);
      expect(fetchCount, 2);
    });
  });
}
