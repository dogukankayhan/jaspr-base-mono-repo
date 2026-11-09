import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_kit_firebase/notification/handlers/notification_background_handler.dart';
import 'package:flutter_kit_firebase/notification/notification_manager.dart';

/// Firebase package initialization function.
/// [options] provided from app layer based on environment.
Future<void> setupFirebase({required FirebaseOptions options}) async {
  try {
    await Firebase.initializeApp(options: options);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

/// Initializes the notification service. Called in Splash screen.
Future<void> setupNotifications() =>
    NotificationManager.instance.init().catchError((e) {
      debugPrint('[NotificationManager] init error: $e');
    });
