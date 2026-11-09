import 'package:flutter_kit_firebase/notification/handlers/notification_deep_link_handler.dart';
import 'package:flutter_kit_firebase/notification/models/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    NotificationDeepLinkHandler.onNavigate = null;
  });

  group('NotificationDeepLinkHandler.handle — navigate', () {
    test('invokes onNavigate with path and params', () {
      String? capturedPath;
      Map<String, dynamic>? capturedParams;
      NotificationDeepLinkHandler.onNavigate = (path, params) {
        capturedPath = path;
        capturedParams = params;
      };

      NotificationDeepLinkHandler.handle(
        const NotificationPayload(
          path: '/pokemon/pokemon/25',
          params: {'highlight': 'true'},
        ),
      );

      expect(capturedPath, '/pokemon/pokemon/25');
      expect(capturedParams, {'highlight': 'true'});
    });

    test('passes null params when params map is empty', () {
      Map<String, dynamic>? capturedParams = {'unset': true};
      NotificationDeepLinkHandler.onNavigate = (path, params) {
        capturedParams = params;
      };

      NotificationDeepLinkHandler.handle(
        const NotificationPayload(path: '/pokemon'),
      );

      expect(capturedParams, isNull);
    });

    test('does not invoke onNavigate when path is null', () {
      var called = false;
      NotificationDeepLinkHandler.onNavigate = (path, params) => called = true;

      NotificationDeepLinkHandler.handle(const NotificationPayload());

      expect(called, isFalse);
    });
  });

  group('NotificationDeepLinkHandler.handle — other action types', () {
    test('does not invoke onNavigate for openUrl', () {
      var called = false;
      NotificationDeepLinkHandler.onNavigate = (path, params) => called = true;

      NotificationDeepLinkHandler.handle(
        const NotificationPayload(
          actionType: NotificationActionType.openUrl,
          url: 'https://example.com',
        ),
      );

      expect(called, isFalse);
    });

    test('does not invoke onNavigate for dismiss', () {
      var called = false;
      NotificationDeepLinkHandler.onNavigate = (path, params) => called = true;

      NotificationDeepLinkHandler.handle(
        const NotificationPayload(actionType: NotificationActionType.dismiss),
      );

      expect(called, isFalse);
    });

    test('does not invoke onNavigate for approval', () {
      var called = false;
      NotificationDeepLinkHandler.onNavigate = (path, params) => called = true;

      NotificationDeepLinkHandler.handle(
        const NotificationPayload(
          actionType: NotificationActionType.approval,
          approvalId: 'abc-123',
        ),
      );

      expect(called, isFalse);
    });
  });
}
