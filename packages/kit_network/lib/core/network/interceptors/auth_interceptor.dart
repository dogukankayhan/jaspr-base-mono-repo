import 'package:dio/dio.dart';

typedef AuthTokenProvider = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  final AuthTokenProvider? authTokenProvider;
  AuthInterceptor({this.authTokenProvider});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await authTokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
