import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/auth_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  group('AuthInterceptor Tests', () {
    test('adds Bearer token when provider returns token', () async {
      final interceptor = AuthInterceptor(
        authTokenProvider: () async => 'test_token',
      );
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await handler.completer.future;

      expect(options.headers['Authorization'], 'Bearer test_token');
      expect(handler.nextOptions, isNotNull);
    });

    test(
      'does not add Authorization header when provider returns null',
      () async {
        final interceptor = AuthInterceptor(
          authTokenProvider: () async => null,
        );
        final options = RequestOptions(path: '/test');
        final handler = MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);
        await handler.completer.future;

        expect(options.headers.containsKey('Authorization'), isFalse);
        expect(handler.nextOptions, isNotNull);
      },
    );

    test(
      'does not add Authorization header when provider returns empty string',
      () async {
        final interceptor = AuthInterceptor(authTokenProvider: () async => '');
        final options = RequestOptions(path: '/test');
        final handler = MockRequestInterceptorHandler();

        interceptor.onRequest(options, handler);
        await handler.completer.future;

        expect(options.headers.containsKey('Authorization'), isFalse);
        expect(handler.nextOptions, isNotNull);
      },
    );
  });
}
