import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_payload.dart';

/// This function runs when action button is clicked while App is in background/closed.
/// Runs in a separate Dart isolate — cannot access DI, BuildContext, or UI.
/// Only stateless operations like HTTP requests or SharedPreferences can be performed.
@pragma('vm:entry-point')
void notificationActionBackgroundHandler(NotificationResponse response) {
  final actionId = response.actionId;
  final approvalId = response.payload; // we write approvalId to payload

  if (approvalId == null || actionId == null) return;

  switch (actionId) {
    case NotificationActionId.approve:
      debugPrint('[Notification] Background APPROVE: $approvalId');
    // TODO: backend'e HTTP POST /approvals/$approvalId/approve
    case NotificationActionId.reject:
      debugPrint('[Notification] Background REJECT: $approvalId');
    // TODO: backend'e HTTP POST /approvals/$approvalId/reject
  }
}

/// Called when action button is clicked while App is open.
/// DI and navigator can be used.
typedef ApprovalCallback =
    Future<void> Function(String approvalId, bool isApproved);
