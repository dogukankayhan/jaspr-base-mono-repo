import 'package:dio/dio.dart';
import 'package:kit_network/core/utils/kit_print.dart';
import '../connectivity/network_info.dart';

class ConnectivityInterceptor extends Interceptor {
  final NetworkInfo networkInfo;

  ConnectivityInterceptor({required this.networkInfo});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final connected = await networkInfo.isConnected.timeout(
        const Duration(seconds: 5),
      );

      if (!connected) {
        kitPrint('[CONNECTIVITY] No internet — rejecting ${options.uri}');
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'No internet connection',
          ),
        );
      }
      handler.next(options);
    } catch (e) {
      // Connectivity check timeout or error → let the request pass, it will be understood if the main request fails
      kitPrint('[CONNECTIVITY] Check failed: $e — proceeding anyway');
      handler.next(options);
    }
  }
}
