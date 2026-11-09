import '../interceptors/request_interceptor.dart';
import '../interceptors/url_interceptor.dart';
import '../js/js_channel.dart';
import '../js/js_injection.dart';

class WebViewConfig {
  final String initialUrl;
  final String? title;
  final List<UrlInterceptor> urlInterceptors;

  /// When non-empty, the XHR/fetch wrapper JS is automatically injected.
  final List<RequestInterceptor> requestInterceptors;

  final List<JsInjection> jsInjections;
  final List<JsChannel> jsChannels;
  final Map<String, String> headers;
  final String? userAgent;
  final bool clearCache;
  final bool enableJavaScript;
  final bool allowsBackForwardGestures;

  const WebViewConfig({
    required this.initialUrl,
    this.title,
    this.urlInterceptors = const [],
    this.requestInterceptors = const [],
    this.jsInjections = const [],
    this.jsChannels = const [],
    this.headers = const {},
    this.userAgent,
    this.clearCache = false,
    this.enableJavaScript = true,
    this.allowsBackForwardGestures = true,
  });
}
