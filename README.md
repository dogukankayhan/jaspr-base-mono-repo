# Flutter Base Kit — Monorepo

Production-ready Flutter monorepo template. Clean Architecture, BLoC pattern, Firebase, and security infrastructure.

---

## Monorepo Structure

```
flutter_base_kit/
├── pubspec.yaml                  # Workspace root (pub workspaces) + Melos scripts
├── scripts/
│   ├── gen_feature.dart          # Feature scaffold: shared bloc + mobile screen / web page
│   └── check_pure_packages.sh    # Enforces the package boundaries below
├── packages/
│   │  ── pure Dart (shared by mobile + web) ──
│   ├── kit_network/              # Dio ApiManager, interceptors, Result<T,E>, getIt
│   ├── kit_core/                 # BaseBloc, BaseCubit, PaginatedBloc, BaseState, validators
│   ├── kit_auth/                 # AuthManager, AuthBloc, TokenStore contract
│   ├── kit_design_tokens/        # Colors as ARGB ints
│   ├── app_shared/               # Endpoints, entities, DTOs, repositories, use cases, blocs
│   │  ── Flutter adapters ──
│   ├── flutter_kit_core/         # BaseBlocView widget, input formatters, launchers
│   ├── flutter_kit_network/      # connectivity_plus, sqflite cache, setupNetworking()
│   ├── flutter_kit_auth/         # SecureTokenStore, Google/Apple sign-in, setupAuth()
│   ├── flutter_kit_firebase/     # FCM, deep link callback
│   ├── flutter_kit_ui/           # Theme, ThemeCubit (colors from kit_design_tokens)
│   │  ── Jaspr / web adapters ──
│   ├── jaspr_kit_core/           # BaseBlocView component
│   ├── jaspr_kit_network/        # BrowserNetworkInfo
│   ├── jaspr_kit_auth/           # BrowserTokenStore
│   └── jaspr_kit_ui/             # CSS variables + base styles from kit_design_tokens
└── apps/
    ├── mobile/                   # Flutter application (views, navigators, DI, adapters)
    └── web/                      # Jaspr web application (client mode, same blocs)
```

### Package Dependency Graph

```
kit_network ← kit_core ← kit_auth        kit_design_tokens
        ↖________↑__________↑                 ↑        ↑
                app_shared                    │        │
              ↗            ↖                  │        │
 flutter_kit_* → apps/mobile   apps/web ← jaspr_kit_*  │
       └──────────────────────────────────────┴────────┘
```

- `kit_*` and `app_shared` are **pure Dart** — no Flutter, Jaspr, `package:web`, `dart:io` or `dart:isolate`. Business logic (endpoint → bloc) is written once there.
- `flutter_kit_*` re-export their `kit_*` half at the old import paths, so existing mobile imports keep working.
- `melos run check:pure` (also in CI) enforces these boundaries.

> `flutter_kit_firebase` must NOT import `flutter_kit_auth` or any navigation package — circular dependency. Use the callback pattern instead (see Deep Link section).

---

## Quick start (fresh clone)

**Requirements:** Flutter **3.41+** (ships Dart 3.11 — the web packages need Dart ≥ 3.10), Xcode + CocoaPods for iOS, Android Studio / SDK for Android, Chrome for the web.

```bash
# 1. One-time tools (versions matter: jaspr_cli must match the jaspr pin)
dart pub global activate melos
dart pub global activate jaspr_cli 0.23.1
export PATH="$PATH:$HOME/.pub-cache/bin"   # add to ~/.zshrc to keep it

# 2. Install dependencies + generate the i18n strings (required after every fresh clone)
melos bootstrap
melos run gen:i18n
```

### Run

| App | Command | Opens |
|---|---|---|
| **Mobile** (Flutter) | `cd apps/mobile && flutter run --flavor dev -t lib/main_dev.dart` | Simulator / device |
| **Web** (Jaspr, client) | `melos run web:serve` | http://localhost:8080 |
| **Web SSR demo** (Jaspr, server) | `melos run web:ssr:serve` | http://localhost:8080 |

- In **VS Code**, use the Run & Debug configurations (**mobile · dev / staging / prod**) — they already pass the flavor and entrypoint.
- `lib/main.dart` has **no `main()`** (it only holds the shared `mainCommon()`); running it directly fails with *"Could not prepare isolate"*. Always run a `main_<flavor>.dart`.
- The two web servers both use port 8080 — run one at a time.
- **Firebase is optional for local development.** The app runs with the placeholder `FirebaseOptions`; add the real config files (below) only when you need push notifications / analytics.

### Verify

```bash
melos run check:pure   # package boundaries
melos analyze
melos run test:unit
```

### iOS: `pod install` fails?

If CocoaPods reports *"None of your spec sources contain a spec satisfying `Firebase/CoreOnly`"* or *"CDN: trunk URL couldn't be downloaded"*, the local spec cache is corrupted (an interrupted download leaves empty spec folders). Run `pod repo remove trunk && pod install --repo-update` in `apps/mobile/ios`.

---

## App Structure

```
apps/mobile/lib/
├── core/
│   ├── config/             # AppEnvironment, AppConfig (native channel)
│   ├── data/               # Platform datasources (business data layer lives in packages/app_shared)
│   ├── deeplink/           # DeepLinkManager
│   ├── di/                 # Injection.init() — all DI registrations
│   ├── firebase/           # FirebaseOptions per flavor (dev/staging/prod)
│   ├── initialize/         # Initialize — startup orchestrator
│   ├── localization/       # slang_flutter i18n files
│   ├── managers/
│   │   ├── device_info_manager/
│   │   └── navigation_manager/ # AppNavigator, GoRouter, auth guard
│   ├── network/            # App-level network config
│   ├── security/           # Jailbreak / root detection
│   ├── splash/             # SplashScreen, SplashNavigator
│   └── webview/            # WebView management (bloc, navigator, interceptors, JS bridge)
└── features/
    ├── login/
    ├── register/
    ├── shell/
    ├── components/                      # AppTextField/etc. showcase — see "Adding a New Feature"
    ├── profile/
    ├── explore/
    ├── favorites/
    ├── planner/
    ├── style/
    ├── style_quiz/
    ├── wardrobe/
    ├── outfit_try_on/
    ├── pokemon_home/
    ├── pokemon_detail/
    ├── pokemon_compare/
    ├── pokemon_evolution_simulator/
    └── pokemon_favorites/
```

---

## Flavors

| Flavor | Entry Point | Firebase |
|--------|-------------|----------|
| dev | `lib/main_dev.dart` | `firebase_options_dev.dart` |
| staging | `lib/main_staging.dart` | `firebase_options_staging.dart` |
| prod | `lib/main_prod.dart` | `firebase_options_prod.dart` |

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod -t lib/main_prod.dart
```

`AppConfig` reads `baseUrl`, `appName`, and `googleServerClientId` from the native layer (`strings.xml` / `Info.plist`):

```dart
AppConfig.instance.baseUrl
AppConfig.instance.isProd
AppConfig.instance.environment  // AppEnvironment enum
```

### Build-time Secrets

Sensitive values (API keys, tokens) are passed via `--dart-define` at build time, never hardcoded.

#### Firebase

To enable Firebase, each flavor needs its own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from the Firebase console (not required to run the app locally — see Quick start). These files are gitignored and must be added manually:

1. Create three Firebase projects (or one with multiple apps): `dev`, `staging`, `prod`
2. Download the config files for each and place them:

```
android/app/src/dev/google-services.json
android/app/src/staging/google-services.json
android/app/src/prod/google-services.json

ios/config/dev/GoogleService-Info.plist
ios/config/staging/GoogleService-Info.plist
ios/config/prod/GoogleService-Info.plist
```

3. Regenerate the Dart options files:

```bash
# Run once per Firebase project
flutterfire configure --project=my-project-dev \
  --out=apps/mobile/lib/core/firebase/firebase_options_dev.dart

flutterfire configure --project=my-project-staging \
  --out=apps/mobile/lib/core/firebase/firebase_options_staging.dart

flutterfire configure --project=my-project-prod \
  --out=apps/mobile/lib/core/firebase/firebase_options_prod.dart
```

The correct `FirebaseOptions` file is selected automatically at startup based on the active flavor.

---

## Startup Flow

```
main_dev.dart
    └── mainCommon(AppEnvironment.dev)
            ├── Initialize.prepare(env)
            │       ├── _initBinding()           ← preserve splash
            │       ├── _initOrientation()
            │       ├── AppConfig.init(env)       ← read native config
            │       ├── _initFirebase(env)        ← calls setupFirebase()
            │       ├── _initDI(env)              ← Injection.init(apiConfig:)
            │       └── _initLocaleAndTheme()
            └── runApp(...)

SplashScreen (shown)
    └── Initialize.run()
            ├── setupNotifications()
            └── route to ShellNavigator.dashboardPath
```

---

## Dependency Injection

GetIt is used. All registrations live in `apps/mobile/lib/core/di/injection.dart`.

Module registration order is **mandatory**:

```
1. setupNetworkModule   → FlutterSecureStorage, TokenStore, ApiManager
2. setupAuthModule      → AuthRepository, AuthManager, AuthBloc
                          (requires ApiManager and TokenStore)
3. setupNavigationModule → GoRouter, AppNavigator
                           (requires AuthBloc)
```

Changing this order causes `Object not registered` at runtime.

```dart
// Access from anywhere
final authManager = getIt<AuthManager>();
final router = getIt<GoRouter>();
```

---

## Networking — flutter_kit_network

Built on `DioClient`. All requests go through the `ApiManager` interface.

### Interceptors

| Interceptor | Responsibility |
|---|---|
| `AuthInterceptor` | Attaches `Authorization: Bearer <token>` to every request |
| `RefreshTokenInterceptor` | Refreshes the token on 401 and retries the request; falls back to the original error after a 30s timeout if the wait never resolves |
| `ConnectivityInterceptor` | Throws an error when there is no internet |
| `RetryInterceptor` | Retries up to 3x on network errors; waits for connectivity to return, capped at 15s |
| `CacheInterceptor` | Caches GET responses — **disabled by default** (`ApiConfig.enableCache`); the cache has no invalidation contract of its own, so opt in per-app and call `ApiManager.invalidateCache(path)` after a mutating request |
| `RateLimiterInterceptor` | Flood protection per endpoint |
| `CertificatePinningInterceptor` | Validates server certificate SHA-256 fingerprint (pass primary + backup) |
| `LoggingInterceptor` | Logs requests/responses in non-prod environments |

`AnalyticsManager` (pluggable request-lifecycle telemetry — start/success/failure/error + custom events) sits alongside the interceptor chain rather than inside it; `ConsoleAnalyticsProvider` is wired in dev builds by default. `ApiManager.getBytes()` fetches raw bytes (e.g. an authenticated image) instead of parsing JSON.

### Token Flow

`AuthInterceptor` → `TokenStore.readAccess()` → `Authorization: Bearer <token>`

On 401 → `RefreshTokenInterceptor` → `/auth/refresh` → token saved → request retried.

The refresh call itself goes through a **second, interceptor-free `ApiManager`** (registered as `getIt<ApiManager>(instanceName: 'refreshApiManager')`), never the main one — routing it back through the same `RefreshTokenInterceptor` would re-enter its lock and hang if the refresh token is itself invalid.

### Result Pattern

Every async operation returns `Result<T, ApiError>`. Never throws, never uses try/catch at the call site:

```dart
result.when(
  ok: (data) => emit(state.copyWith(isLoading: false, items: data)),
  err: (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
);
```

Common mistake — forgetting to emit in the `err` branch leaves `isLoading: true` forever:

```dart
result.when(
  ok: (data) => emit(state.copyWith(data: data)),
  err: (_) {},  // BUG: isLoading never becomes false
);
```

---

## Auth — flutter_kit_auth

`AuthManager` handles token storage, session state, and all auth operations. Created via `AuthManager.create()` and registered in GetIt — no static singleton.

```dart
final auth = getIt<AuthManager>();

auth.isLoggedIn    // bool
auth.profile       // Profile?
auth.tokens        // AuthTokens?
```

### Methods

```dart
await auth.login(email, password);
await auth.register(email: email, password: password);
await auth.logout();
await auth.signInWithSocial(SocialAuthProvider.apple, idToken);
await auth.signInWithSocial(SocialAuthProvider.google, idToken);
await auth.signInAsGuest();
await auth.fetchMe();
await auth.updateProfile({'firstName': 'Ali'});

// Generic password-reset skeleton (see CLAUDE.md Rule 3) — extend with
// your own fields rather than using as-is:
await auth.startPasswordReset(email);
await auth.verifyPasswordReset(email: email, code: code);
await auth.completePasswordReset(email: email, code: code, newPassword: newPassword);
```

`SocialAuthService` (in `flutter_kit_auth`) wraps `google_sign_in`/`sign_in_with_apple` and returns a platform-agnostic `SocialCredential` — pass its `idToken` straight into `signInWithSocial`. It's only registered in GetIt when `setupAuth(googleServerClientId: ...)` is given a client ID.

All methods return `Result<T, ApiError>`:

```dart
final result = await auth.login(email, password);
result.when(
  ok: (_) => HomeNavigator.show(context),
  err: (e) => showSnackbar(e.message),
);
```

### AuthBloc

Listens to `AuthManager` and keeps auth state reactive:

```dart
authBloc.state.isAuthenticated
authBloc.state.profile
authBloc.add(const AuthLogoutRequested());
```

---

## BLoC Architecture — flutter_kit_core

### Base Classes

```
BaseBloc<E, S extends BaseState>
    └── onReady()    → post-frame callback, use for initial data load
    └── onInit()     → called when bloc is created

BaseCubit<S extends BaseState>
    └── safeEmit()   → skips emit if cubit is already closed (prevents crash in async callbacks)

BaseState
    └── isLoading    → shows LoadingOverlay automatically
    └── isValid      → for form validation
    └── errorMessage → error state
```

Always use `safeEmit()` instead of `emit()` inside async callbacks in a Cubit:

```dart
void doSomething() async {
  final result = await someApi();
  safeEmit(state.copyWith(data: result)); // no-op if cubit was closed while awaiting
}
```

### Screen Definition

Always use `BaseBlocView` — never construct a `Bloc()` directly inside a widget:

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseBlocView<MyBloc, MyState>(
      create: () => MyBloc(getIt<MyRepository>()),
      builder: (context, state, bloc) {
        return Scaffold(
          body: ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (_, i) => ListTile(title: Text(state.items[i].title)),
          ),
        );
      },
    );
  }
}
```

### Bloc Definition

```dart
class MyBloc extends BaseBloc<MyEvent, MyState> {
  final MyRepository _repo;

  MyBloc(this._repo) : super(const MyState()) {
    on<MyFetched>(_onFetched);
  }

  @override
  void onReady() => add(const MyFetched());

  Future<void> _onFetched(MyFetched event, Emitter<MyState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.getItems();
    result.when(
      ok: (items) => emit(state.copyWith(isLoading: false, items: items)),
      err: (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
    );
  }
}
```

### PaginatedBloc

Infinite-scroll lists use `PaginatedBloc` mixin. Only `fetchPage()` and `paginatedState()` need to be implemented:

```dart
class MyListBloc extends BaseBloc<MyListEvent, MyListState>
    with PaginatedBloc<MyItem, MyListEvent, MyListState> {

  MyListBloc() : super(const MyListState()) {
    on<MyListStarted>((e, emit) => handleLoadInitial(emit));
    on<MyListLoadMore>((e, emit) => handleLoadMore(emit));
  }

  @override
  Future<(List<MyItem>, bool, int)> fetchPage(int offset, int size) async {
    final items = await _repo.getPage(offset: offset, size: size);
    return (items, items.length >= size, offset + items.length);
  }

  @override
  MyListState paginatedState({required List<MyItem> items, required bool hasMore,
      required int offset, required bool isLoading, String? errorMessage}) =>
      state.copyWith(items: items, hasMore: hasMore, offset: offset,
          isLoading: isLoading, errorMessage: errorMessage);
}
```

### ActiveCubitHelper

When the same screen type can be open more than once in the navigation stack (e.g., two different user profiles), use `activeKey` to distinguish instances in GetIt:

```dart
BaseBlocView<ProfileCubit, ProfileState>(
  activeKey: userId,
  create: () => ProfileCubit(userId: userId),
  ...
)

// Access from another widget
final cubit = getActive<ProfileCubit>(key: userId);
```

Without a key, `_default_ProfileCubit` is used — assumes a single instance of that type.

---

## Navigation — Navigator Pattern

GoRouter is used. Every feature owns a navigator file that is the single source of truth for its route path.

```dart
// feature_navigator.dart
class DashboardNavigator {
  static const path = '/dashboard';

  static GoRoute route() => GoRoute(
    path: path,
    builder: (context, state) => const DashboardScreen(),
  );

  static void show(BuildContext context) => context.go(path);
}
```

All navigators are registered with `AppNavigator`, which assembles the `GoRouter` and manages the auth redirect guard.

**Rule: never call `context.go('/some-path')` directly. Always use the navigator:**

```dart
// Correct
DashboardNavigator.show(context);

// Wrong — path strings must live only in the navigator
context.go('/dashboard');
```

---

## Firebase — flutter_kit_firebase

```
apps/mobile/lib/core/firebase/
├── firebase_options_dev.dart
├── firebase_options_staging.dart
└── firebase_options_prod.dart
```

`setupFirebase(options:)` is called automatically in `Initialize._initFirebase(env)`.

```bash
# Connect a new Firebase project
flutterfire configure --project=my-project-dev \
  --out=apps/mobile/lib/core/firebase/firebase_options_dev.dart
```

### Notifications

`setupNotifications()` is called during the splash screen (`Initialize.run()`).

```dart
final token = await NotificationManager.instance.getToken();
```

### Deep Link — Callback Pattern

`flutter_kit_firebase` does **not** import GoRouter or any auth package. Importing them would create a `firebase → navigation → auth → firebase` cycle. Instead, a static callback is set at app startup:

```dart
// In main_*.dart, after GoRouter is created
NotificationDeepLinkHandler.onNavigate = (path, params) {
  getIt<GoRouter>().go(path, extra: params);
};
```

---

## Theme — flutter_kit_ui

```dart
context.read<ThemeCubit>().setLight();
context.read<ThemeCubit>().setDark();
context.read<ThemeCubit>().setSystem();

context.appColors.background   // AppColors is a ThemeExtension — read via context, not statically
context.appColors.textColor
AppTheme.light                 // ThemeData, static — pass to MaterialApp.theme
AppTheme.dark
```

Theme is managed by `ThemeCubit` and persisted to `SharedPreferences`.

---

## Localization

`slang_flutter` is used. Translation files:

```
apps/mobile/lib/core/localization/i18n/
├── en.i18n.json
└── tr.i18n.json
```

```dart
Text(context.translations.someKey)
LocaleSettings.setLocale(AppLocale.tr);
```

After adding a new key, regenerate from the workspace root:

```bash
melos run gen:i18n
```

The generated output (`strings*.g.dart`) is **not tracked in git** — its header carries a build timestamp, so every merge conflicted on it. A fresh checkout does not compile until this has run once; edit the `.i18n.json` files, never the `.g.dart` output.

---

## Validator — flutter_kit_core

```dart
final emailValidator = FieldValidator<String>([
  Validators.required(),
  Validators.email(),
  Validators.maxLength(100),
]);

final error = emailValidator.validate(state.email); // first error or null

final result = emailValidator.validateAll(state.email);
result.isValid;  // bool
result.errors;   // List<String>
```

`FormValidator` tracks multiple fields:

```dart
FormValidator get _form => FormValidator({
  'email':    () => emailValidator.validate(state.email),
  'password': () => passwordValidator.validate(state.password),
});

bool canSubmit = _form.isValid;
String? emailError = _form.errorFor('email');
```

**Available rules:** `required`, `email`, `minLength`, `maxLength`, `min`, `max`, `range`, `pattern`, `equals`, `custom`, `phone`, `iban`, `date`, `url`

---

## Phone Numbers — flutter_kit_core

`CountryPhones` (in `flutter_kit_core/utils/phone/`) holds dial code, national-number mask and mobile-prefix data for 231 countries, defaulting to Türkiye:

```dart
final country = CountryPhones.defaultCountry;   // Türkiye
CountryPhones.byIso('US');
CountryPhones.parse('+905551234567');           // (CountryPhone, nationalDigits) or null
country.toE164('5551234567');                   // '+905551234567'
```

`MaskedPhoneInputFormatter(pattern:, trunkPrefix:)` formats a field as the user types, and `Validators.phone(country:)` validates against the same country's digit count and mobile prefixes. `apps/mobile`'s `AppTextField` wires both together — pass `type: InputType.phone`, `country: state.country`, and `onCountryTap:` to open `CountryPickerSheet.show(context, selected: ...)`, a searchable bottom-sheet picker over all 231 countries. See `features/components/` for a full working example.

---

## Adding a New Feature

### 1. Generate the scaffold

```bash
dart run scripts/gen_feature.dart
```

The interactive script asks for a feature name, whether it's a `Bloc` (event-driven) or `Cubit` (method-driven), whether it needs pagination, and where the screen is routed (standalone / nested in the shell / a shell tab). It then generates the presentation layer and registers the route automatically. **It does not generate entities, use cases, repositories, or DTOs** — those are shared, live under `apps/mobile/lib/core/`, and are written by hand (see step 4).

### 2. Folder structure (generated)

```
apps/mobile/lib/features/my_feature/
├── bloc/                          # or cubit/, depending on your choice
│   ├── my_feature_bloc.dart
│   ├── my_feature_event.dart
│   └── my_feature_state.dart
├── view/
│   └── my_feature_screen.dart
└── my_feature_navigator.dart      # GoRoute definition + show() method
```

This mirrors the existing features — compare `features/login/` (Bloc) or `features/shell/` (Cubit). The `_navigator.dart` file lives at the feature root, not inside `view/`.

### 3. Register with DI

```dart
// In injection.dart
getIt.registerLazySingleton<MyRepository>(
  () => MyRepositoryImpl(getIt<ApiManager>()),
);
```

### 4. Register the route

For **standalone** and **nested** features, the generator already wires `MyFeatureNavigator.route` into `AppNavigator` / `ShellNavigator` for you. For a **tab** route, add it manually to the relevant `StatefulShellBranch` in `ShellNavigator`:

```dart
// route is a getter, not a method
MyFeatureNavigator.route,
```

Navigation is always done through the navigator:

```dart
MyFeatureNavigator.show(context);
```

### 5. Screen-specific widgets (`part of`)

If your screen splits into sub-widgets (tabs, sections) that **only that screen uses**, put them in a `widgets/` folder next to it and join them to the screen's library with `part`/`part of`, instead of separate importable files:

```
apps/mobile/lib/features/my_feature/view/
├── my_feature_screen.dart   # part 'widgets/my_feature_tab.dart';
└── widgets/
    └── my_feature_tab.dart  # part of '../my_feature_screen.dart';
```

All imports live in the screen file — the `part of` files declare no imports of their own. See `features/pokemon_detail/view/` (four tabs) or `features/pokemon_compare/view/` + `widgets/pokemon_stat_chart.dart` for real examples.

**This only applies when the widget has a single consumer.** A widget used by more than one screen (e.g. `PokemonCard`, shared by `pokemon_home` and `pokemon_favorites`) must stay a normal standalone file that gets `import`-ed.

---

## Testing

Tests live alongside each package and the app:

```
apps/mobile/test/          # BLoC, use case, repository tests for the app
packages/flutter_kit_auth/test/
packages/flutter_kit_core/test/
packages/flutter_kit_network/test/
```

### Run all tests

```bash
melos test
```

### Run a single package

```bash
cd packages/flutter_kit_auth
flutter test
```

### Regenerate mocks

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

### Test pattern

```dart
@GenerateMocks([MyRepository])
void main() {
  late MockMyRepository mockRepo;
  late MyBloc bloc;

  setUp(() {
    provideDummy<Result<MyEntity, ApiError>>(Ok(MyEntity()));
    mockRepo = MockMyRepository();
    bloc = MyBloc(mockRepo);
  });

  tearDown(() async => bloc.close());

  test('emits loaded state on success', () async {
    when(mockRepo.getItems()).thenAnswer((_) async => Ok([MyEntity()]));

    bloc.add(const MyFetched());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<MyState>().having((s) => s.isLoading, 'loading', true),
        isA<MyState>().having((s) => s.items.length, 'items', 1),
      ]),
    );
  });
}
```

Use `@GenerateNiceMocks([MockSpec<ConcreteClass>()])` for concrete classes (e.g., `FlutterSecureStorage`). Use `provideDummy<Result<T,E>>(Ok(...))` whenever a mock returns a generic `Result` type.

---

## Melos Commands

```bash
melos bootstrap       # Install dependencies (first setup or after pubspec changes)
melos run gen:i18n    # Generate strings*.g.dart (REQUIRED after a fresh checkout)
melos analyze         # Lint all packages
melos test            # Run all tests
melos format          # Format code
melos format:check    # Format check (CI — does not write files)
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC / Cubit state management |
| `get_it` | Dependency injection |
| `go_router` | Navigation |
| `dio` | HTTP client |
| `firebase_core/messaging/analytics/crashlytics` | Firebase |
| `flutter_local_notifications` | Local notifications |
| `google_sign_in` + `sign_in_with_apple` | Social auth |
| `flutter_secure_storage` | Encrypted token storage |
| `shared_preferences` | Lightweight local storage |
| `sqflite` | Local SQLite database |
| `slang_flutter` | Localization |
| `equatable` | Value equality |
| `connectivity_plus` | Network status |
| `app_links` | Deep linking |
| `flutter_native_splash` | Native splash screen |
| `flutter_screenutil` | Responsive sizing |
| `cached_network_image` | Image caching |
| `melos` | Monorepo management |
