import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/connectivity_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  group('ConnectivityInterceptor Tests', () {
    test('proceeds when connected', () async {
      final mockNetworkInfo = MockNetworkInfo()..isConnectedResult = true;
      final interceptor = ConnectivityInterceptor(networkInfo: mockNetworkInfo);
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await handler.completer.future;

      expect(handler.nextOptions, isNotNull);
      expect(handler.rejectedError, isNull);
    });

    test('rejects request when disconnected', () async {
      final mockNetworkInfo = MockNetworkInfo()..isConnectedResult = false;
      final interceptor = ConnectivityInterceptor(networkInfo: mockNetworkInfo);
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await handler.completer.future;

      expect(handler.nextOptions, isNull);
      expect(handler.rejectedError, isNotNull);
      expect(handler.rejectedError!.type, DioExceptionType.connectionError);
      expect(handler.rejectedError!.error, 'No internet connection');
    });

    test('proceeds when connectivity check fails (throws)', () async {
      final interceptor = ConnectivityInterceptor(
        networkInfo: MockNetworkInfoThrowing(),
      );
      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);
      await handler.completer.future;

      expect(handler.nextOptions, isNotNull);
      expect(handler.rejectedError, isNull);
    });
  });
}
