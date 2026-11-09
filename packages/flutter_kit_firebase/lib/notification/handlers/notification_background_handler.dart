import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_channel.dart';
import '../extensions/remote_message_ext.dart';

/// Catches FCM messages when application is in background or closed.
/// This function runs in a separate Dart isolate — cannot access UI.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final payload = message.toPayload();

  // Show local notification only for data-only messages (no notification area)
  if (message.notification == null) {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await plugin.show(
      id: message.hashCode,
      title: payload.title ?? 'base project',
      body: payload.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          AppNotificationChannel.general.id,
          AppNotificationChannel.general.name,
          channelDescription: AppNotificationChannel.general.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
