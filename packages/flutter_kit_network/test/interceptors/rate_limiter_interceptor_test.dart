import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/rate_limiter_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  group('RateLimiterInterceptor Tests', () {
    test(
      'rejects immediately when limit exceeded and autoRetry is false',
      () async {
        final interceptor = RateLimiterInterceptor(
          globalLimit: 2,
          window: const Duration(seconds: 10),
          autoRetry: false,
        );

        final opt = RequestOptions(path: '/test');

        final h1 = MockRequestInterceptorHandler();
        interceptor.onRequest(opt, h1);
        await h1.completer.future;
        expect(h1.nextOptions, isNotNull);

        final h2 = MockRequestInterceptorHandler();
        interceptor.onRequest(opt, h2);
        await h2.completer.future;
        expect(h2.nextOptions, isNotNull);

        final h3 = MockRequestInterceptorHandler();
        interceptor.onRequest(opt, h3);
        await h3.completer.future;
        expect(h3.nextOptions, isNull);
        expect(h3.rejectedError, isNotNull);
        expect(h3.rejectedError!.error, isA<RateLimitException>());
      },
    );

    test(
      'delays and retries when limit exceeded and autoRetry is true',
      () async {
        final interceptor = RateLimiterInterceptor(
          globalLimit: 1,
          window: const Duration(milliseconds: 300),
          autoRetry: true,
        );

        final opt = RequestOptions(path: '/test');

        final h1 = MockRequestInterceptorHandler();
        interceptor.onRequest(opt, h1);
        await h1.completer.future;
        expect(h1.nextOptions, isNotNull);

        final h2 = MockRequestInterceptorHandler();
        interceptor.onRequest(opt, h2);
        // Wait to see if it triggers after 350ms
        await Future<void>.delayed(const Duration(milliseconds: 350));
        await h2.completer.future;
        expect(h2.nextOptions, isNotNull);
      },
    );

    test('synchronizes limits with headers', () async {
      final interceptor = RateLimiterInterceptor(
        globalLimit: 10,
        autoRetry: false,
      );

      final opt = RequestOptions(path: '/test');
      final resHeaders = Headers();
      resHeaders.add('x-ratelimit-remaining', '0');
      final resetTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 10;
      resHeaders.add('x-ratelimit-reset', resetTime.toString());

      final response = Response(
        requestOptions: opt,
        statusCode: 200,
        headers: resHeaders,
      );

      final resHandler = MockResponseInterceptorHandler();
      interceptor.onResponse(response, resHandler);
      await resHandler.completer.future;

      final h = MockRequestInterceptorHandler();
      interceptor.onRequest(opt, h);
      await h.completer.future;
      expect(h.nextOptions, isNull);
      expect(h.rejectedError, isNotNull);
    });

    test('configureEndpoint overrides global limits', () async {
      final interceptor = RateLimiterInterceptor(
        globalLimit: 1,
        autoRetry: false,
      );

      interceptor.configureEndpoint('GET:/custom', limit: 5);

      final opt = RequestOptions(method: 'GET', path: '/custom');

      for (int i = 0; i < 5; i++) {
        final h = MockRequestInterceptorHandler();
        interceptor.onRequest(opt, h);
        await h.completer.future;
        expect(h.nextOptions, isNotNull);
      }

      final h = MockRequestInterceptorHandler();
      interceptor.onRequest(opt, h);
      await h.completer.future;
      expect(h.nextOptions, isNull);
      expect(h.rejectedError, isNotNull);
    });
  });
}
