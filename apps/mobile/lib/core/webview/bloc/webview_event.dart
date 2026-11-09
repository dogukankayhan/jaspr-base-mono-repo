import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../model/webview_result.dart';

sealed class WebViewEvent {
  const WebViewEvent();
}

final class WebViewControllerCreated extends WebViewEvent {
  final InAppWebViewController controller;
  const WebViewControllerCreated(this.controller);
}

final class WebViewPageStarted extends WebViewEvent {
  final String url;
  const WebViewPageStarted(this.url);
}

final class WebViewProgressChanged extends WebViewEvent {
  final int progress;
  const WebViewProgressChanged(this.progress);
}

final class WebViewPageFinished extends WebViewEvent {
  final String url;
  const WebViewPageFinished(this.url);
}

/// [interceptedResult] is non-null when a [UrlInterceptor] matched the URL.
final class WebViewNavigationRequested extends WebViewEvent {
  final String url;
  final WebViewResult<dynamic>? interceptedResult;
  const WebViewNavigationRequested(this.url, {this.interceptedResult});
}

/// Fired by the hidden '_wk_xhr' JS channel with a JSON-encoded XHR/fetch response.
final class WebViewXhrResponseReceived extends WebViewEvent {
  final String payload;
  const WebViewXhrResponseReceived(this.payload);
}

final class WebViewErrorOccurred extends WebViewEvent {
  final String description;
  const WebViewErrorOccurred(this.description);
}

final class WebViewDismissRequested extends WebViewEvent {
  const WebViewDismissRequested();
}
