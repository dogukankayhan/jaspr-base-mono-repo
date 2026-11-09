import '../model/webview_result.dart';

abstract class RequestInterceptor {
  const RequestInterceptor();

  bool matchesRequest(String url, String method);

  Future<WebViewResult<dynamic>?> handleResponse({
    required String url,
    required String method,
    required int statusCode,
    required String? body,
  });
}
