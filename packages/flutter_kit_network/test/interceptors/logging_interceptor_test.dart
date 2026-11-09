import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/interceptors/logging_interceptor.dart';
import 'interceptor_test_helpers.dart';

void main() {
  group('LoggingInterceptor Tests', () {
    test('onRequest, onResponse, onError execute without exceptions', () async {
      final interceptor = LoggingInterceptor();

      final reqHandler = MockRequestInterceptorHandler();
      interceptor.onRequest(RequestOptions(path: '/test'), reqHandler);
      await reqHandler.completer.future;
      expect(reqHandler.nextOptions, isNotNull);

      final resHandler = MockResponseInterceptorHandler();
      interceptor.onResponse(
        Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 200,
        ),
        resHandler,
      );
      await resHandler.completer.future;
      expect(resHandler.nextResponse, isNotNull);

      final errHandler = MockErrorInterceptorHandler();
      interceptor.onError(
        DioException(requestOptions: RequestOptions(path: '/test')),
        errHandler,
      );
      await errHandler.completer.future;
      expect(errHandler.nextError, isNotNull);
    });
  });
}
