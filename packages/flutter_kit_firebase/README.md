# flutter_kit_firebase

Firebase integration layer for flutter_base_kit monorepo. Covers Firebase initialisation, Crashlytics error capture, FCM push notifications, and local notification channels.

## Features

- `setupFirebase()` — one-call Firebase + Crashlytics initialisation
- `setupNotifications()` — FCM + local notification channel setup
- `NotificationManager` — FCM token, foreground/background message handling
- `NotificationDeepLinkHandler` — router-free deep linking via callback
- Background message handler registration
- Notification channel system (general, promotional, critical)

## Setup

### 1. Initialise Firebase

Call during app startup (before `runApp`):

```dart
await setupFirebase(
  options: DefaultFirebaseOptions.currentPlatform, // per-flavor FirebaseOptions
);
```

This initialises Firebase, registers the FCM background handler, and wires Crashlytics as the global Flutter error handler.

### 2. Initialise Notifications

Call during the splash screen:

```dart
await setupNotifications();
```

### 3. Wire Deep Links

Set the navigation callback once at startup so the package stays router-free:

```dart
NotificationDeepLinkHandler.onNavigate = (path, params) {
  getIt<GoRouter>().go(path, extra: params);
};
```

## NotificationManager

```dart
final nm = NotificationManager.instance;

// Get FCM token
final token = await nm.getToken();

// Handle approval action notifications
nm.onApprovalAction = (approvalId, isApproved) async {
  if (isApproved) await myService.approve(approvalId);
  else await myService.reject(approvalId);
};
```

## Notification Channels

| Channel | Purpose |
|---|---|
| `general` | Standard notifications |
| `promotional` | Campaign / image notifications |
| `critical` | Security / urgent notifications |

## FCM Payload Fields

| Field | Type | Description |
|---|---|---|
| `path` | String | Route path (`/home`, `/store`) |
| `tab` | String | Tab index (e.g. `"2"`) |
| `action_type` | String | `navigate`, `open_url`, `dismiss`, `approval` |
| `image_url` | String | Notification image URL |
| `url` | String | URL to open |
| `params` | JSON String | Extra route parameters |
| `approval_id` | String | ID for approval-type notifications |

## Deep Link Handler

When a notification is tapped, `NotificationDeepLinkHandler.handle(payload)` is called automatically. Navigation is performed via the `onNavigate` callback — the package has no direct dependency on any router.

```dart
// Customise navigation behaviour
NotificationDeepLinkHandler.onNavigate = (path, params) {
  // use any navigation mechanism
  Navigator.of(context).pushNamed(path, arguments: params);
};
```

## Dependencies

- `firebase_core`
- `firebase_analytics`
- `firebase_crashlytics`
- `firebase_messaging`
- `flutter_local_notifications`
- `http`
