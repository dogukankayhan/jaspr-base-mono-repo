import 'package:dio/dio.dart';
import 'package:kit_network/core/utils/kit_print.dart';

class LoggingInterceptor extends Interceptor {
  /// Static callback for screens to subscribe to network telemetry.
  static void Function(String)? onLog;

  static void _log(String message) {
    kitPrint(message);
    onLog?.call(message);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log(
      '[HTTP][REQ] ${options.method} ${options.uri} headers=${options.headers}',
    );
    if (options.data != null) {
      _log('[HTTP][REQ][BODY] ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('[HTTP][RES] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '[HTTP][ERR] ${err.type} ${err.message} url=${err.requestOptions.uri}',
    );
    if (err.response?.data != null) {
      _log('[HTTP][ERR][BODY] ${err.response?.data}');
    }
    handler.next(err);
  }
}
