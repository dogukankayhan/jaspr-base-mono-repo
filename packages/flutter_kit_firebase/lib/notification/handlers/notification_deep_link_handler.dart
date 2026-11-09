import 'package:flutter/foundation.dart';
import '../models/notification_payload.dart';

/// Callback pattern is used to break router dependency.
/// App layer sets `onNavigate` at start:
/// `NotificationDeepLinkHandler.onNavigate = (path, params) => router.go(path);`
abstract final class NotificationDeepLinkHandler {
  static void Function(String path, Map<String, dynamic>? params)? onNavigate;

  static void handle(NotificationPayload payload) {
    switch (payload.actionType) {
      case NotificationActionType.navigate:
        _navigate(payload);
      case NotificationActionType.openUrl:
        debugPrint('[Notification] Open URL: ${payload.url}');
      case NotificationActionType.dismiss:
      case NotificationActionType.approval:
        break;
    }
  }

  static void _navigate(NotificationPayload payload) {
    final path = payload.path;
    if (path == null) return;
    assert(
      onNavigate != null,
      '[NotificationDeepLinkHandler] onNavigate is null. '
      'Set it in main.dart after GoRouter is created: '
      'NotificationDeepLinkHandler.onNavigate = (path, params) => router.go(path);',
    );
    onNavigate?.call(path, payload.params.isNotEmpty ? payload.params : null);
  }
}
