import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification_payload.dart';

extension RemoteMessageExt on RemoteMessage {
  NotificationPayload toPayload() => NotificationPayload.fromMap(
    title: notification?.title,
    body: notification?.body,
    data: data,
  );
}
