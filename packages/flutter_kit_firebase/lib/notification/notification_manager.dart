import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'extensions/remote_message_ext.dart';
import 'handlers/notification_action_handler.dart';
import 'handlers/notification_deep_link_handler.dart';
import 'models/notification_channel.dart';
import 'models/notification_payload.dart';

const _approvalCategoryId = 'approval_category';

class NotificationManager {
  NotificationManager._();
  static final NotificationManager instance = NotificationManager._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _fcm = FirebaseMessaging.instance;

  bool _initialized = false;

  /// Notification received in terminated state — cannot navigate until splash screen is completed.
  NotificationPayload? _pendingPayload;

  /// Callback to be called when action button is pressed while App is open.
  /// NotificationManager.instance.onApprovalAction = (id, approved) => ...
  ApprovalCallback? onApprovalAction;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    await Future.wait([
      _setupLocalNotifications(),
      _setupChannels(),
      _requestPermission(),
    ]);

    _listenForeground();
    _listenBackgroundTap();
    await _checkInitialMessage();
    _listenTokenRefresh();

    _initialized = true;
  }

  // ── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  // ── Local Notifications kurulumu ──────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
          notificationCategories: [
            DarwinNotificationCategory(
              _approvalCategoryId,
              actions: [
                DarwinNotificationAction.plain(
                  NotificationActionId.approve,
                  'Onayla',
                ),
                DarwinNotificationAction.plain(
                  NotificationActionId.reject,
                  'Reddet',
                  options: {DarwinNotificationActionOption.destructive},
                ),
              ],
            ),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          notificationActionBackgroundHandler,
    );
  }

  Future<void> _setupChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;

    for (final channel in AppNotificationChannel.values) {
      await android.createNotificationChannel(channel.androidChannel);
    }
  }

  // ── FCM listeners ──────────────────────────────────────────────────────────

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) async {
      final payload = message.toPayload();
      _trackReceived(payload);
      await _showLocalNotification(message);
    });
  }

  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload = message.toPayload();
      _trackOpened(payload);
      NotificationDeepLinkHandler.handle(payload);
    });
  }

  Future<void> _checkInitialMessage() async {
    final message = await _fcm.getInitialMessage();
    if (message != null) {
      _pendingPayload = message.toPayload();
    }
  }

  /// Called from SplashScreen after splash is complete.
  void consumePendingPayload() {
    final payload = _pendingPayload;
    if (payload == null) return;
    _pendingPayload = null;
    _trackOpened(payload);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationDeepLinkHandler.handle(payload);
    });
  }

  // ── Token ─────────────────────────────────────────────────────────────────

  Future<String?> getToken() => _fcm.getToken();

  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen((token) {
      debugPrint('[FCM] Token refreshed: $token');
      // TODO: Send the new token to the backend
    });
  }

  Future<void> deleteToken() => _fcm.deleteToken();

  // ── Local notification display ─────────────────────────────────────────────

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final payload = message.toPayload();
    final isApproval = payload.actionType == NotificationActionType.approval;
    final channel = _channelFor(payload);
    final imageUrl = payload.imageUrl;

    final androidDetails = imageUrl != null
        ? await _buildImageAndroidDetails(imageUrl, channel, isApproval)
        : _buildAndroidDetails(channel, isApproval);

    final iosDetails = imageUrl != null
        ? await _buildImageIosDetails(imageUrl, isApproval)
        : _buildIosDetails(isApproval);

    await _plugin.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      // we write approvalId to payload — to be used by action handler
      payload: isApproval ? payload.approvalId : payload.path,
    );
  }

  AndroidNotificationDetails _buildAndroidDetails(
    AppNotificationChannel channel,
    bool isApproval,
  ) {
    return AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
      actions: isApproval ? _androidApprovalActions() : null,
    );
  }

  Future<AndroidNotificationDetails> _buildImageAndroidDetails(
    String imageUrl,
    AppNotificationChannel channel,
    bool isApproval,
  ) async {
    try {
      final bytes = await _downloadImage(imageUrl);
      final bitmap = ByteArrayAndroidBitmap(bytes);
      return AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        styleInformation: BigPictureStyleInformation(
          bitmap,
          hideExpandedLargeIcon: true,
        ),
        largeIcon: bitmap,
        actions: isApproval ? _androidApprovalActions() : null,
      );
    } catch (_) {
      return _buildAndroidDetails(channel, isApproval);
    }
  }

  Future<DarwinNotificationDetails> _buildImageIosDetails(
    String imageUrl,
    bool isApproval,
  ) async {
    try {
      final bytes = await _downloadImage(imageUrl);
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/notification_img.jpg')
        ..writeAsBytesSync(bytes);
      return DarwinNotificationDetails(
        attachments: [DarwinNotificationAttachment(file.path)],
        categoryIdentifier: isApproval ? _approvalCategoryId : null,
      );
    } catch (_) {
      return _buildIosDetails(isApproval);
    }
  }

  DarwinNotificationDetails _buildIosDetails(bool isApproval) {
    return DarwinNotificationDetails(
      categoryIdentifier: isApproval ? _approvalCategoryId : null,
    );
  }

  List<AndroidNotificationAction> _androidApprovalActions() => [
    const AndroidNotificationAction(
      NotificationActionId.approve,
      'Onayla',
      showsUserInterface: false,
      cancelNotification: true,
    ),
    const AndroidNotificationAction(
      NotificationActionId.reject,
      'Reddet',
      showsUserInterface: false,
      cancelNotification: true,
    ),
  ];

  Future<Uint8List> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Image download failed');
    return response.bodyBytes;
  }

  // ── Notification response (foreground + tap) ──────────────────────────────

  void _onNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final rawPayload = response.payload;

    // Action button pressed (Approve / Reject)
    if (actionId != null && rawPayload != null) {
      final isApproved = actionId == NotificationActionId.approve;
      debugPrint(
        '[Notification] Foreground ${isApproved ? "APPROVE" : "REJECT"}: $rawPayload',
      );
      onApprovalAction?.call(rawPayload, isApproved);
      return;
    }

    // Normal notification clicked — deep link
    if (rawPayload == null) return;
    final payload = NotificationPayload.fromMap(data: {'path': rawPayload});
    _trackOpened(payload);
    NotificationDeepLinkHandler.handle(payload);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  AppNotificationChannel _channelFor(NotificationPayload payload) {
    if (payload.imageUrl != null) return AppNotificationChannel.promotional;
    if (payload.path == null) return AppNotificationChannel.critical;
    return AppNotificationChannel.general;
  }

  void _trackReceived(NotificationPayload payload) {
    FirebaseAnalytics.instance.logEvent(
      name: 'notification_received',
      parameters: {'path': payload.path ?? 'unknown'},
    );
  }

  void _trackOpened(NotificationPayload payload) {
    FirebaseAnalytics.instance.logEvent(
      name: 'notification_opened',
      parameters: {
        'path': payload.path ?? 'unknown',
        'action_type': payload.actionType.name,
      },
    );
  }
}
