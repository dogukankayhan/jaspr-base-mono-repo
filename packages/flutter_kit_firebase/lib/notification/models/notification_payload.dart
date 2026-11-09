import 'dart:convert';

enum NotificationActionType { navigate, openUrl, dismiss, approval }

abstract final class NotificationActionId {
  static const String approve = 'action_approve';
  static const String reject = 'action_reject';
}

class NotificationPayload {
  final String? title;
  final String? body;
  final String? path;
  final int? tabIndex;
  final Map<String, dynamic> params;
  final String? imageUrl;
  final NotificationActionType actionType;
  final String? url;
  final String? approvalId;

  const NotificationPayload({
    this.title,
    this.body,
    this.path,
    this.tabIndex,
    this.params = const {},
    this.imageUrl,
    this.actionType = NotificationActionType.navigate,
    this.url,
    this.approvalId,
  });

  factory NotificationPayload.fromMap({
    String? title,
    String? body,
    required Map<String, dynamic> data,
  }) {
    Map<String, dynamic> params = {};
    final rawParams = data['params'];
    if (rawParams is String && rawParams.isNotEmpty) {
      try {
        params = jsonDecode(rawParams) as Map<String, dynamic>;
      } catch (_) {}
    }

    return NotificationPayload(
      title: title,
      body: body,
      path: data['path'] as String?,
      tabIndex: int.tryParse(data['tab'] as String? ?? ''),
      params: params,
      imageUrl: data['image_url'] as String?,
      actionType: _parseActionType(data['action_type'] as String?),
      url: data['url'] as String?,
      approvalId: data['approval_id'] as String?,
    );
  }

  static NotificationActionType _parseActionType(String? value) {
    return switch (value) {
      'open_url' => NotificationActionType.openUrl,
      'dismiss' => NotificationActionType.dismiss,
      'approval' => NotificationActionType.approval,
      _ => NotificationActionType.navigate,
    };
  }

  bool get hasDeepLink =>
      path != null ||
      tabIndex != null ||
      actionType == NotificationActionType.openUrl;
}
