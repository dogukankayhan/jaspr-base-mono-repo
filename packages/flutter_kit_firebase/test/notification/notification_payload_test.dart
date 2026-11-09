import 'package:flutter_kit_firebase/notification/models/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationPayload.fromMap', () {
    test('parses path, tabIndex and params from data map', () {
      final payload = NotificationPayload.fromMap(
        title: 'Title',
        body: 'Body',
        data: {
          'path': '/pokemon/pokemon/25',
          'tab': '2',
          'params': '{"highlight":"true"}',
        },
      );

      expect(payload.title, 'Title');
      expect(payload.body, 'Body');
      expect(payload.path, '/pokemon/pokemon/25');
      expect(payload.tabIndex, 2);
      expect(payload.params, {'highlight': 'true'});
      expect(payload.actionType, NotificationActionType.navigate);
    });

    test('defaults to navigate action type when action_type is missing', () {
      final payload = NotificationPayload.fromMap(data: const {});
      expect(payload.actionType, NotificationActionType.navigate);
    });

    test('parses open_url, dismiss and approval action types', () {
      expect(
        NotificationPayload.fromMap(
          data: const {'action_type': 'open_url'},
        ).actionType,
        NotificationActionType.openUrl,
      );
      expect(
        NotificationPayload.fromMap(
          data: const {'action_type': 'dismiss'},
        ).actionType,
        NotificationActionType.dismiss,
      );
      expect(
        NotificationPayload.fromMap(
          data: const {'action_type': 'approval'},
        ).actionType,
        NotificationActionType.approval,
      );
    });

    test('falls back to empty params when params JSON is malformed', () {
      final payload = NotificationPayload.fromMap(
        data: const {'params': 'not-json'},
      );
      expect(payload.params, isEmpty);
    });

    test('leaves tabIndex null when tab is missing or not numeric', () {
      expect(
        NotificationPayload.fromMap(data: const {}).tabIndex,
        isNull,
      );
      expect(
        NotificationPayload.fromMap(data: const {'tab': 'abc'}).tabIndex,
        isNull,
      );
    });
  });

  group('NotificationPayload.hasDeepLink', () {
    test('is true when path is set', () {
      const payload = NotificationPayload(path: '/pokemon');
      expect(payload.hasDeepLink, isTrue);
    });

    test('is true when tabIndex is set', () {
      const payload = NotificationPayload(tabIndex: 1);
      expect(payload.hasDeepLink, isTrue);
    });

    test('is true for openUrl action type', () {
      const payload = NotificationPayload(
        actionType: NotificationActionType.openUrl,
      );
      expect(payload.hasDeepLink, isTrue);
    });

    test('is false when there is no path, tabIndex, or openUrl action', () {
      const payload = NotificationPayload();
      expect(payload.hasDeepLink, isFalse);
    });
  });
}
