# apps/mobile

Flutter mobile application for the FlutterBaseKit application. Consumes all `flutter_kit_*` packages.

## Overview

```
apps/mobile/lib/
├── core/
│   ├── components/    ← App-wide UI components (AppButton, AppTextField, AppCard…)
│   ├── config/        ← AppEnvironment (baseUrl is obtained from the native side)
│   ├── data/          ← Repository implementations, DTOs, remote datasources
│   ├── di/            ← GetIt modules (NetworkModule, AuthModule, NavigationModule)
│   ├── domain/        ← Entities, repository interfaces, use cases
│   └── managers/      ← AppNavigator, AppRouter, DeepLinkManager
├── features/
│   ├── login/
│   ├── register/
│   ├── dashboard/
│   ├── home/
│   └── shell/
└── main.dart / main_dev.dart / main_staging.dart / main_prod.dart
```

---

## Running with Flavors

| Flavor | Command |
|--------|-------|
| Development | `flutter run --flavor dev -t lib/main_dev.dart` |
| Staging | `flutter run --flavor staging -t lib/main_staging.dart` |
| Production | `flutter run --flavor prod -t lib/main_prod.dart` |

In VS Code, dev, staging, and prod configurations are available in the **Run & Debug** panel (`.vscode/launch.json`).

---

## Entry Points

Each flavor has its own `main_*.dart` file:

```dart
// main_dev.dart
void main() => Initialize.prepare(AppEnvironment.dev);
```

`Initialize.prepare(env)`:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `ScreenUtil` is initialized (design size: 390×844)
3. `setupFirebase(options: firebaseOptions)` is executed
4. `Injection.init(apiConfig: AppConfig.apiConfig)` — DI modules are configured sequentially
5. `runApp(FlutterBaseKitApp())` is called

---

## DI Module Order

Within `Injection.init()`, modules must run in **this exact order**:

```
1. setupNetworkModule(getIt, apiConfig: apiConfig)
   → FlutterSecureStorage, TokenStore, ApiManager are registered

2. setupAuthModule(getIt)
   → AuthRemoteDataSource, AuthRepository, AuthManager, AuthBloc are registered
   → Requires ApiManager and TokenStore (dependent on step 1)

3. setupNavigationModule(getIt)
   → GoRouter, AuthRouterNotifier are registered
   → Requires AuthBloc (dependent on step 2)
```

If the order is violated, GetIt will throw an `Object not registered` error at runtime.

---

## Feature Directory Structure

Each feature includes the following files:

```
features/<name>/
├── bloc/
│   ├── <name>_bloc.dart          # extends BaseBloc<Event, State>
│   ├── <name>_event.dart         # Sealed class events
│   └── <name>_state.dart         # extends BaseState, copyWith
├── view/
│   └── <name>_screen.dart        # UI layer
└── <name>_navigator.dart       # GoRoute + show() method
```

The `<name>_navigator.dart` file registers the route to `AppNavigator`. All navigation flows through these coordinators.

---

## Running Tests

```bash
# All workspace tests (from the project root)
melos test

# Only mobile app tests
cd apps/mobile && flutter test
```

Test files are located under `apps/mobile/test/` using a feature mirroring structure:
```
test/
├── features/
│   ├── login/login_bloc_test.dart
│   ├── dashboard/dashboard_bloc_test.dart
│   └── shell/shell_cubit_test.dart
└── core/
    ├── domain/get_dashboard_usecase_test.dart
    └── data/dashboard_repository_impl_test.dart
```

---

## Local Development Without Firebase

Firebase config files (`.plist`, `.json`) are not committed to the repository. If the team does not have a Firebase project or if only UI development is being performed, bypasses can be configured in two places:

**1. Initialize Dart flag** — `apps/mobile/lib/core/initialize/initialize.dart`:
```dart
static const bool _firebaseEnabled = false; // Bypass Firebase initialization and notifications
```

**2. iOS build script** — `apps/mobile/ios/copy_google_services.sh`:
- If `GoogleService-Info.plist` is not found, it returns `exit 0` (prints a warning but doesn't break the build).
- When the actual plist is added, this behavior resolves automatically.

When activating Firebase:
1. Set `_firebaseEnabled` to `true`.
2. Place the correct `GoogleService-Info.plist` file under `ios/config/<flavor>/` for each flavor.

---

## CI/CD — Required Secrets

The following secrets must be defined in GitHub Actions:

| Secret | Purpose |
|--------|------|
| `FIREBASE_SERVICE_ACCOUNT` | Service account JSON for Firebase App Distribution |
| `FIREBASE_STAGING_APP_ID` | Firebase App ID for the staging flavor |
| `FIREBASE_PROD_APP_ID` | Firebase App ID for the prod flavor |

Workflows:
- **`ci.yml`** — runs lint, analyze, test on every PR (ubuntu runner)
- **`android-staging.yml`** — staging APK build + Firebase distribution on every PR
- **`android-prod.yml`** — prod APK build + Firebase distribution on `v*` tag push
