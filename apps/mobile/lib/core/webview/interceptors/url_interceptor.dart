import '../model/webview_result.dart';

abstract class UrlInterceptor {
  const UrlInterceptor();

  bool matches(String url);

  WebViewResult<dynamic>? handle(String url, Map<String, String> queryParams);
}
