import 'package:flutter/material.dart';

import '../config/webview_config.dart';
import '../model/webview_result.dart';
import '../widget/webview_screen.dart';

final class WebViewNavigator {
  const WebViewNavigator._();

  static Future<WebViewResult<dynamic>?> show(
    BuildContext context, {
    required WebViewConfig config,
  }) {
    return Navigator.of(
      context,
      rootNavigator: true,
    ).push<WebViewResult<dynamic>>(
      MaterialPageRoute(
        builder: (_) => WebViewScreen(config: config),
        fullscreenDialog: true,
      ),
    );
  }
}
