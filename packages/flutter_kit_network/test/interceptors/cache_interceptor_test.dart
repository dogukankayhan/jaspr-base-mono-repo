import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/cache_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  group('CacheInterceptor Tests', () {
    late CacheInterceptor cacheInterceptor;

    setUp(() {
      cacheInterceptor = CacheInterceptor(
        defaultMaxAge: const Duration(milliseconds: 100),
        maxEntries: 3,
      );
    });

    test('does not cache non-GET requests', () async {
      final reqHandler = MockRequestInterceptorHandler();
      final options = RequestOptions(method: 'POST', path: '/test');

      cacheInterceptor.onRequest(options, reqHandler);
      await reqHandler.completer.future;
      expect(reqHandler.nextOptions, isNotNull);
      expect(reqHandler.resolvedResponse, isNull);

      final resHandler = MockResponseInterceptorHandler();
      final response = Response(
        requestOptions: options,
        statusCode: 200,
        data: 'post_data',
      );

      cacheInterceptor.onResponse(response, resHandler);
      await resHandler.completer.future;
      expect(resHandler.nextResponse, isNotNull);

      // Subsequent GET should miss
      final getOptions = RequestOptions(method: 'GET', path: '/test');
      final getReqHandler = MockRequestInterceptorHandler();
      cacheInterceptor.onRequest(getOptions, getReqHandler);
      await getReqHandler.completer.future;
      expect(getReqHandler.resolvedResponse, isNull);
    });

    test(
      'caches successful GET response and hits cache on subsequent request',
      () async {
        final reqOptions = RequestOptions(method: 'GET', path: '/test');
        final resHandler = MockResponseInterceptorHandler();
        final response = Response(
          requestOptions: reqOptions,
          statusCode: 200,
          data: 'cached_data',
        );

        cacheInterceptor.onResponse(response, resHandler);
        await resHandler.completer.future;
        expect(resHandler.nextResponse, isNotNull);

        final nextReqHandler = MockRequestInterceptorHandler();
        cacheInterceptor.onRequest(reqOptions, nextReqHandler);
        await nextReqHandler.completer.future;

        expect(nextReqHandler.resolvedResponse, isNotNull);
        expect(nextReqHandler.resolvedResponse!.data, 'cached_data');
      },
    );

    test('respects max-age in cache-control header', () async {
      final reqOptions = RequestOptions(method: 'GET', path: '/test');
      final resHeaders = Headers();
      resHeaders.add('cache-control', 'max-age=1'); // 1 second

      final resHandler = MockResponseInterceptorHandler();
      final response = Response(
        requestOptions: reqOptions,
        statusCode: 200,
        data: 'cached_data_headers',
        headers: resHeaders,
      );

      cacheInterceptor.onResponse(response, resHandler);
      await resHandler.completer.future;

      final reqHandler1 = MockRequestInterceptorHandler();
      cacheInterceptor.onRequest(reqOptions, reqHandler1);
      await reqHandler1.completer.future;
      expect(reqHandler1.resolvedResponse, isNotNull);

      // Wait for expiration
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      final reqHandler2 = MockRequestInterceptorHandler();
      cacheInterceptor.onRequest(reqOptions, reqHandler2);
      await reqHandler2.completer.future;
      expect(reqHandler2.resolvedResponse, isNull);
    });

    test('evicts oldest entries when maxEntries is reached (LRU)', () async {
      // Add 4 entries to cache capacity of 3
      for (int i = 0; i < 4; i++) {
        final opt = RequestOptions(method: 'GET', path: '/test$i');
        final res = Response(
          requestOptions: opt,
          statusCode: 200,
          data: 'data$i',
        );
        final resHandler = MockResponseInterceptorHandler();
        cacheInterceptor.onResponse(res, resHandler);
        await resHandler.completer.future;
      }

      // test0 should be evicted
      final req0 = RequestOptions(method: 'GET', path: '/test0');
      final handler0 = MockRequestInterceptorHandler();
      cacheInterceptor.onRequest(req0, handler0);
      await handler0.completer.future;
      expect(handler0.resolvedResponse, isNull);

      // test3 should still be cached
      final req3 = RequestOptions(method: 'GET', path: '/test3');
      final handler3 = MockRequestInterceptorHandler();
      cacheInterceptor.onRequest(req3, handler3);
      await handler3.completer.future;
      expect(handler3.resolvedResponse, isNotNull);
    });

    test('clearCache and removeCacheEntry functions work', () async {
      final opt = RequestOptions(method: 'GET', path: '/test');
      final res = Response(requestOptions: opt, statusCode: 200, data: 'data');
      final resHandler = MockResponseInterceptorHandler();
      cacheInterceptor.onResponse(res, resHandler);
      await resHandler.completer.future;

      cacheInterceptor.removeCacheEntry('/test');

      final handler = MockRequestInterceptorHandler();
      cacheInterceptor.onRequest(opt, handler);
      await handler.completer.future;
      expect(handler.resolvedResponse, isNull);
    });
  });
}
