# CLAUDE.md — Flutter Base Kit Monorepo Guide

This file is prepared for AI assistants and new developers to understand the project codebase quickly.

---

## AI Coding Rules — Screen & API Wiring Recipe

When asked to build a screen or connect it to an API, follow these rules in order without asking — no clarification needed unless a field name is genuinely ambiguous.

### Rule 1 — New screen: decide Bloc vs Cubit first, then build on BaseBlocView

| Use | When |
|---|---|
| `BaseCubit` | No discrete events: load-and-show, toggles, tab/selection state, simple forms |
| `BaseBloc` | Discrete user events, multi-step flows, event transformers/debounce |
| `BaseBloc` + `PaginatedBloc` mixin | Infinite-scroll lists (see Critical Pattern 8) |

Every screen is a `StatelessWidget` wrapping `BaseBlocView` — the view never owns state:

```dart
class XxxScreen extends StatelessWidget {
  const XxxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseBlocView<XxxCubit, XxxState>(
      create: () => XxxCubit(),
      builder: (context, state, cubit) => Scaffold(/* build UI from state */),
    );
  }
}
```

See Critical Pattern 3 for the exact lifecycle (`create()` → `onReady()` → `close()`) and Critical Pattern 4 for `safeEmit`. Every `Result.when` err branch must also clear `isLoading` — see Critical Pattern 2.

**Where things go:** the bloc/cubit (+ state/event) is platform-neutral and lives in `packages/app_shared/lib/features/<feature>/{bloc|cubit}/`. Only the view is per-platform: the Flutter screen in `apps/mobile/lib/features/<feature>/view/` (`BaseBlocView` from `flutter_kit_core`), the Jaspr page in `apps/web/lib/features/<feature>/view/` (`BaseBlocView` from `jaspr_kit_core` — same API, see "Web (Jaspr)" below). `melos run gen:feature` scaffolds all of it.

### Rule 2 — Screen-private widgets: `view/widgets/` with part / part of

See Critical Pattern 9 below.

### Rule 3 — Endpoint wiring chain

"Connect screen X to API Y" always creates this chain, in this order. Steps 1–6 and 8 live in **`packages/app_shared/lib/`** (pure Dart, shared by mobile and web — never import Flutter, Jaspr or `dart:io`/`dart:isolate` there); only step 7 is per-app:

1. `service/api/<feature>_api.dart` — endpoint classes (Rule 4)
2. `domain/entity/<feature>_entity.dart` — request + response entities (pure Dart, no JSON)
3. `data/dto/<feature>_dto.dart` — `XxxRequestDto.fromEntity()` + `XxxResponseDto.fromJson()`/`toDomain()`
4. `domain/repository/<feature>_repository.dart` — abstract interface, returns `Result<Entity, ApiError>`
5. `data/repository/<feature>_repository_impl.dart` — `ApiManager` calls directly, no separate datasource layer; `on ApiException catch (e) => Err(e.error)`. Heavy mapping off the UI thread → `runInBackground()` from `kit_core` (never `Isolate.run` — it breaks the web build)
6. `domain/usecase/<verb>_<feature>_usecase.dart` — passes the Result through, no try/catch
7. `apps/mobile/lib/core/di/modules/` **and** `apps/web/lib/core/di/modules/` — register the **repository only** (see DI rules below); use cases are **not** registered
8. `features/<feature>/{bloc|cubit}/` — use cases are built **here**, inline in a `.create` factory from the registered repository. Import `package:bloc/bloc.dart` (not `flutter_bloc`) and `getIt` from `package:kit_network/core/di/locator.dart`

When a repository needs platform storage (prefs, secure storage…), put an abstract datasource in `app_shared/lib/data/datasource/` and one implementation per app — see `FavoritesLocalDataSource` → `SharedPrefsFavoritesDataSource` (mobile) / `BrowserFavoritesDataSource` (web).

Data must flow through the layers in this exact shape:

```
Request : Entity ──fromEntity()──▶ RequestDto ──▶ Endpoint.query/body(dto) ──▶ ApiManager
Response: JSON ──fromJson()──▶ ResponseDto ──toDomain()──▶ Entity ──▶ bloc/cubit state property (viewmodel)
```

**DI rules:**

Only **repositories** live in GetIt. A stateless pass-through use case carries no data, so registering it buys nothing — it is built inline instead. The bloc/cubit exposes two constructors:

- **Primary (unnamed) constructor** — pure, never touches `getIt`; takes every use case + repository as a named parameter. This is the **test seam**: tests pass mocks straight in.
- **`.create` named factory** — the only `getIt`-touching spot; resolves the repository **once** and builds each use case inline from it. `BaseBlocView` wires it with `create: XxxCubit.create`.

```dart
class XxxCubit extends BaseCubit<XxxState> {
  // Pure — the constructor tests use:
  XxxCubit({
    required GetXxxUseCase getXxx,
    required XxxRepository repo,
  }) : _getXxx = getXxx,
       _repo = repo,
       super(const XxxState());

  // Production wiring — resolve the repo once, build use cases from it:
  factory XxxCubit.create() {
    final repo = getIt<XxxRepository>();
    return XxxCubit(getXxx: GetXxxUseCase(repo), repo: repo);
  }
}
```

- Never resolve `getIt`/use cases inside a view or widget — wiring lives in `.create`.
- **Stateful repository** (holds a cache, a broadcast stream, session data) → `registerLazySingleton` — the shared instance is the point.
- **Stateless repository** (pure endpoint pass-through, keeps no data) → `registerFactory` — no reason for a permanent instance to sit in memory; a fresh one is created per resolution and garbage-collected afterwards. Resolve it **once** in `.create` (not per use case) so a factory repo isn't rebuilt N times.

```dart
// Holds cache + stream → single shared instance:
getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(...));
// Stateless pass-through → created on demand, released after use:
getIt.registerFactory<UserRepository>(() => UserRepositoryImpl(getIt<ApiManager>()));
// Use cases are NOT registered — they are built inside the bloc/cubit `.create` factory.
```

> Managers that are themselves DI singletons (e.g. `AuthManager`) or non-use-case deps (a callback/function) are still resolved via a `x ?? getIt<X>()` fallback in a single constructor — the `.create` split only pays off for features that own use cases. See `LoginBloc`.

> `kit_auth` is the reference implementation of this whole chain — see `AuthRepositoryImpl` (endpoint calls, no datasource layer) and the `password_reset_*` files (a from-scratch example built to demonstrate the pattern). (`flutter_kit_auth` re-exports it and adds only the Flutter-specific secure storage / social sign-in.)

### Rule 4 — Endpoint file owns path/query/body; parameters are always Request DTOs

One `abstract final class` per endpoint in `packages/app_shared/lib/service/api/<feature>_api.dart`. Path, query map and body map are defined **only here** — never inline in a datasource or repository impl.

Endpoint static methods take the **Request DTO** — never loose primitives (`id`, `name`, `limit`…). This applies to parametrized paths too:

```dart
abstract final class ListXxxEndpoint {
  static const path = '/xxx';
  static Map<String, dynamic> query(ListXxxRequestDto dto) =>
      {'limit': dto.limit, 'offset': dto.offset};
}

abstract final class GetXxxDetailEndpoint {
  static String path(GetXxxDetailRequestDto dto) => '/xxx/${dto.id}';
}

abstract final class UpdateUserProfileEndpoint {
  static const path = '/user/me';
  static Map<String, dynamic> body(UpdateUserProfileRequestDto dto) =>
      {'firstName': dto.firstName, 'lastName': dto.lastName};
}
```

- Use `'key': ?dto.nullableField` (Dart null-aware map element) to skip entries whose value is null.
- Response DTO `fromJson` always parses with `as T? ?? fallback` — never assume the API sends non-null.

> `packages/app_shared/lib/service/api/{pokemon_api,user_api}.dart` predate this rule and still take loose primitives — treat them as legacy, not as a pattern to copy from; new endpoints follow Rule 4 as written above.

### Rule 5 — Navigator owns navigation AND screen-to-screen data

Every feature has a navigator file owning its `GoRoute` and a `show()` method. When a screen needs data from the caller, that data is a **typed parameter of `show()`** and travels via `extra` (or a path param). Raw `context.push('/route', extra: x)` at call sites is forbidden, as is constructing another feature's screen widget directly.

```dart
final class XxxDetailNavigator {
  static const String path = '/xxx/detail';

  static GoRoute get route => GoRoute(
    path: 'detail',
    builder: (_, state) => XxxDetailScreen(item: state.extra as XxxEntity),
  );

  /// The ONLY way to open this screen — the data contract is explicit and typed.
  static void show(BuildContext context, {required XxxEntity item}) {
    context.go(path, extra: item);
  }
}

// Caller:
XxxDetailNavigator.show(context, item: selected);
```

- The route path string exists in exactly one file: the navigator.
- If the caller already owns the entity, pass the entity — do not pass an id and refetch.
- **Web exception:** in `apps/web` screen data travels as a **path param** (`/pokemon/:id`), never `extra` — a web URL must survive reload/bookmark/share, and `jaspr_router`'s `extra` only carries serializable primitives. The page receives the id; its (shared) bloc loads the entity. Web navigators also expose `link(...)` returning a router `Link` (a real `<a>`) — prefer it over `show()` for plain navigation.

---

## Project Identity

Flutter + Jaspr monorepo: `flutter_base_kit_workspace`
- Orchestrated via **Pub workspaces** + **Melos** (one lockfile for every package)
- 3 flavors: `dev`, `staging`, `prod` (web: `--dart-define=FLAVOR=… --dart-define=BASE_URL=…`)
- Mobile app: `apps/mobile/` (Flutter) · Web app: `apps/web/` (Jaspr, client mode)
- Shared code: `packages/kit_*` + `packages/app_shared` (pure Dart) · platform adapters: `packages/flutter_kit_*`, `packages/jaspr_kit_*`

---

## Package Dependency Graph

Three layers. Every `kit_X` has a Flutter adapter `flutter_kit_X` and (where needed) a web adapter `jaspr_kit_X`:

```
PURE DART (no Flutter, no Jaspr, no package:web, no dart:io/isolate/ffi/ui)
  kit_network        Dio ApiManager, interceptors, Result<T,E>, NetworkInfo contract, getIt
  kit_core           BaseBloc/BaseCubit/PaginatedBloc, BaseState, validators, runInBackground  → kit_network
  kit_auth           AuthManager, AuthBloc, TokenStore contract, setupAuthCore                  → kit_network, kit_core
  kit_design_tokens  colors as ARGB ints (PaletteTokens, BrandTokens)
  app_shared         the app layer: endpoints, entities, DTOs, repositories, use cases, blocs   → kit_*

FLUTTER ADAPTERS                                  JASPR / WEB ADAPTERS
  flutter_kit_network  connectivity_plus, sqflite    jaspr_kit_network  navigator.onLine
  flutter_kit_core     BaseBlocView widget,          jaspr_kit_core     BaseBlocView component
                       input formatters, launchers
  flutter_kit_auth     SecureTokenStore, Google/     jaspr_kit_auth     BrowserTokenStore (Web Storage)
                       Apple sign-in, setupAuth()
  flutter_kit_ui       Flutter theme (Color(token))  jaspr_kit_ui       CSS variables from tokens
  flutter_kit_firebase FCM, deep link callback

APPS
  apps/mobile  → app_shared + flutter_kit_*
  apps/web     → app_shared + jaspr_kit_*
```

`flutter_kit_*` re-export their `kit_*` half at the **old import paths** (e.g. `package:flutter_kit_core/base_bloc/base_bloc.dart` still works), so mobile code did not have to change. New shared code imports `kit_*` directly.

**Rules** (enforced by `melos run check:pure`, also in CI):
- `kit_*` / `app_shared` never import Flutter, Jaspr, `package:web`, or `dart:io` / `dart:isolate` / `dart:ffi` / `dart:ui`. A VM-only implementation goes in a `*_io.dart` / `*_isolate.dart` file chosen by a conditional export (see `kit_core/lib/utils/background/run_in_background.dart`). One stray `dart:isolate` import makes dart2js **silently skip** the whole web entrypoint.
- `jaspr_kit_*` / `apps/web` never import Flutter; `flutter_kit_*` / `apps/mobile` never import Jaspr.
- `flutter_kit_firebase` → `flutter_kit_auth` dependency is forbidden (circular). Resolved via the deep link routing callback pattern (see below).

---

## Critical Pattern 1: Navigator

Each feature has a `<feature>_navigator.dart` file. This file:
- Contains the `GoRoute` definition
- Exposes the navigation API via a static `show()` method, typed to whatever data the screen needs (see Rule 5)
- Is registered in `AppNavigator.instance`

```dart
// Usage — to open a feature:
DashboardNavigator.show(context);

// Never call context.go('/dashboard') directly, and never push another
// feature's screen with raw context.push(path, extra: x) —
// the path string and the data contract must live only in the navigator.
```

`AppNavigator` (singleton): collects all navigators and provides the route list to GoRouter. The `redirect()` method manages the auth guard.

---

## Critical Pattern 2: Result\<T, E\>

From the `flutter_kit_network` package. All async operations return a `Result` instead of throwing exceptions.

```dart
// Correct usage
final result = await getDashboardUseCase();
result.when(
  ok: (summary) => emit(state.copyWith(summary: summary, isLoading: false)),
  err: (error) => emit(state.copyWith(errorMessage: error.message, isLoading: false)),
);

// Common mistake: forgetting to emit in the err branch — the state hangs
result.when(
  ok: (data) => emit(state.copyWith(data: data)),
  err: (_) {},  // ← BUG: isLoading never becomes false
);
```

`ApiError` fields: `statusCode` (nullable int), `message` (String).

Use cases propagate the Result directly — do not wrap them in try/catch:
```dart
@override
Future<Result<DashboardSummary, ApiError>> call() =>
    _repository.getDashboard(); // pass the repository result as is
```

---

## Critical Pattern 3: BaseBloc + BaseBlocView Lifecycle

```
BaseBlocView.initState()
  └── bloc = create()          ← created from the factory
      └── BaseBloc constructor → on<Event> registrations are made

BaseBlocView: post-frame callback
  └── bloc.onReady()           ← initial data loading goes here
      e.g.: add(DashboardLoadRequested())

BaseBlocView.dispose()
  └── bloc.close()             ← stream is cleared
```

`BaseBlocView` both creates the bloc and manages its lifecycle.  
Do not invoke the `Bloc()` constructor inside a widget — always use `BaseBlocView`.

---

## Critical Pattern 4: safeEmit

The `safeEmit(state)` method of `BaseCubit` prevents the `emit()` call from crashing in async callbacks after the cubit is closed.

```dart
// Use safeEmit instead of emit inside a Cubit:
void doSomething() async {
  final result = await someApi();
  safeEmit(state.copyWith(data: result)); // quietly ignores if the cubit is closed
}
```

---

## Critical Pattern 5: DI Module Order

This order is **mandatory** inside `Injection.init()`:

```
1. setupNetworkModule   → FlutterSecureStorage, TokenStore, ApiManager
2. setupAuthModule      → AuthRepository, AuthManager, AuthBloc
                          (requires ApiManager and TokenStore)
3. setupNavigationModule → GoRouter, AppNavigator
                           (requires AuthBloc)
```

If the order is changed, `Object not registered` error is thrown.

See Rule 3's DI rules above for when a repository is a `registerLazySingleton` vs a `registerFactory` — that choice applies inside every module, not just auth.

---

## Critical Pattern 6: Callback-Based Deep Link

`flutter_kit_firebase` **does not import** GoRouter — doing so would cause a `firebase → navigation → auth → firebase` cycle.

Solution: The `NotificationDeepLinkHandler.onNavigate` static callback is set by the app layer at startup:

```dart
// Inside main_*.dart, after GoRouter is initialized:
NotificationDeepLinkHandler.onNavigate = (path, params) {
  router.go(path, extra: params);
};
```

The same shape resolves `flutter_kit_auth`'s need for a push token without depending on `flutter_kit_firebase`: `setupAuth()` takes an optional `FcmTokenProvider? fcmTokenProvider` callback (`Future<String?> Function()`), wired from the app layer once Firebase is initialized. Left unset, `AuthManager` simply omits the token from login/register/social-sign-in requests.

---

## Critical Pattern 7: ActiveCubitHelper

If the same screen type is open **more than once** in the navigation stack (e.g., two different user profile pages), `activeKey` is used to distinguish the cubit in GetIt.

```dart
// Pass a unique key when opening the screen:
BaseBlocView<ProfileCubit, ProfileState>(
  activeKey: userId,
  create: () => ProfileCubit(userId: userId),
  ...
)

// To access it from another widget:
final cubit = getActive<ProfileCubit>(key: userId);
```

If no key is provided, `_default_ProfileCubit` is used — a single instance of that type is assumed.

---

## Critical Pattern 8: PaginatedBloc

The `PaginatedBloc` mixin is used for infinite-scroll lists. The subclass only implements `fetchPage()` and `paginatedState()`, and the pagination logic is managed by the mixin.

```dart
// Plain BaseBloc is sufficient:
class DashboardBloc extends BaseBloc<DashboardEvent, DashboardState> { ... }

// Add mixin for lists requiring pagination:
class AppointmentBloc extends BaseBloc<AppointmentEvent, AppointmentState>
    with PaginatedBloc<Appointment, AppointmentEvent, AppointmentState> {

  @override
  Future<(List<Appointment>, bool, int)> fetchPage(int offset, int size) =>
      _useCase(offset: offset, size: size);

  @override
  AppointmentState paginatedState({...}) => state.copyWith(...);
}
```

---

## Critical Pattern 9: Screen-Specific Widgets (`part of`)

A widget used by **exactly one** screen lives next to it in a `widgets/` folder and joins the screen's library via `part`/`part of`, instead of being a separately imported file. Classes stay **private** (`_Xxx`) — nothing outside the screen's library can reach them. This avoids re-importing the same entities/utils in every tab/section file and makes the "only this screen uses it" relationship explicit.

```
features/<feature>/view/<feature>_screen.dart       ← part 'widgets/stat_card.dart';
features/<feature>/view/widgets/stat_card.dart       ← part of '../<feature>_screen.dart';
```

```dart
// feature_screen.dart — the library file: all imports live here
import 'package:flutter/material.dart';
// ...other imports needed by the screen AND its parts

part 'widgets/feature_about_tab.dart';
part 'widgets/feature_stats_tab.dart';

class FeatureScreen extends StatelessWidget { ... }
```

```dart
// widgets/feature_about_tab.dart — no imports of its own
part of '../feature_screen.dart';

class _FeatureAboutTab extends StatelessWidget { ... } // only this screen can see it
```

See `pokemon_detail/view/pokemon_detail_screen.dart` (+ `view/widgets/*_tab.dart`) and `pokemon_compare/view/compare_screen.dart` (+ `widgets/pokemon_stat_chart.dart`).

Only components reused across features belong in `core/components/` as public widgets. **If a widget is used by more than one screen** (e.g. `PokemonCard`, used by both `pokemon_home` and `pokemon_favorites`), it must stay a normal standalone file that gets `import`-ed — never make a widget `part of` a screen it isn't exclusive to.

---

## Test Pattern Summary

```dart
@GenerateMocks([AuthManager, SomeUseCase])
void main() {
  late MockAuthManager mockAuthManager;
  late LoginBloc loginBloc;

  setUp(() {
    // Prevents Mockito generic type warnings:
    provideDummy<Result<AuthTokens, ApiError>>(
      Ok(AuthTokens(accessToken: '', refreshToken: null)),
    );
    mockAuthManager = MockAuthManager();
    loginBloc = LoginBloc(authManager: mockAuthManager);
  });

  tearDown(() async => loginBloc.close());

  group('LoginSubmitted — success', () {
    test('emits isLoading then isSuccess', () async {
      when(mockAuthManager.login(any, any))
          .thenAnswer((_) async => Ok(AuthTokens(...)));
      // ...
    });
  });
}
```

Where tests live: bloc / use case / repository tests sit next to the code in `packages/app_shared/test/` and use **`package:test`** (`dart test`, no Flutter binding needed — never call `TestWidgetsFlutterBinding` there). Widget tests stay in `apps/mobile/test/` (`flutter_test`); Jaspr component tests use `jaspr_test` (`testComponents`, see `jaspr_kit_core/test/base_bloc_view_test.dart`).

To generate mock files (every package that depends on mockito):
```bash
melos run gen:mocks
```

---

## File Naming Conventions

| File | Name |
|-------|-----|
`app_shared/` = `packages/app_shared/lib/`.

| File | Name |
|-------|-----|
| Bloc | `app_shared/features/feature/bloc/feature_bloc.dart` |
| Event | `app_shared/features/feature/bloc/feature_event.dart` |
| State | `app_shared/features/feature/bloc/feature_state.dart` |
| Screen (mobile) | `apps/mobile/lib/features/feature/view/feature_screen.dart` |
| Page (web) | `apps/web/lib/features/feature/view/feature_page.dart` |
| Screen-only widget (single consumer) | `widgets/feature_thing.dart`, `part of '../feature_screen.dart'` (or `_page.dart`) |
| Navigator | `apps/{mobile,web}/lib/features/feature/feature_navigator.dart` |
| Endpoint | `app_shared/service/api/feature_api.dart` (Rule 4) |
| Entity | `app_shared/domain/entity/feature_entity.dart` (request + response) |
| DTO | `app_shared/data/dto/feature_dto.dart` |
| Repository (interface) | `app_shared/domain/repository/feature_repository.dart` |
| Repository (impl) | `app_shared/data/repository/feature_repository_impl.dart` |
| Platform datasource (contract) | `app_shared/data/datasource/feature_local_datasource.dart` (impl per app) |
| Use case | `app_shared/domain/usecase/verb_feature_usecase.dart` |
| Test | `packages/app_shared/test/features/feature/feature_bloc_test.dart` |
| Mocks | `feature_bloc_test.mocks.dart` (auto-generated) |

---

## Melos Commands

```bash
melos bootstrap          # Install dependencies (first setup or pubspec changes)
melos run gen:i18n       # Generate strings*.g.dart (REQUIRED after a fresh checkout)
melos run gen:feature    # Scaffold a feature: shared bloc/cubit + mobile screen and/or web page
melos run gen:mocks      # Regenerate Mockito mocks
melos analyze            # Run lint checks in all packages
melos run check:pure     # Verify package boundaries (see Package Dependency Graph)
melos test               # All tests — test:flutter (flutter test) + test:dart (dart test)
melos run test:unit      # Same, excluding integration-tagged tests (CI)
melos format             # Format code
melos format:check       # Check formatting (used in CI, does not modify files)
melos run web:serve      # Jaspr dev server with hot reload — http://localhost:8080
melos run web:build      # Production web build → apps/web/build/jaspr
```

`web:*` needs the Jaspr CLI once per machine, **at the same version as the `jaspr` pin**: `dart pub global activate jaspr_cli 0.23.1`.

The slang output (`lib/core/localization/i18n/strings*.g.dart`) is **not tracked in git** — its generated header carries a build timestamp and string count, so every merge conflicted on it. A fresh checkout does not compile until `gen:i18n` has run; CI runs it right after `melos bootstrap`. Edit the `.i18n.json` files, never the `.g.dart` output.

---

## DO NOT List

| Forbidden | Reason |
|-------|-------|
| Calling `context.go('/dashboard')` directly | Path string spreads — use `DashboardNavigator.show(context)` |
| Passing screen data with raw `context.push(path, extra: x)` | The navigator's `show()` is the typed data contract (Rule 5) |
| Constructing `Bloc()` inside a widget | `BaseBlocView` manages the lifecycle — always use it |
| Adding `ApiManager` or `AuthManager` as field to `BaseBloc` | Breaks package isolation — inject use case instead |
| Resolving `getIt`/use cases inside a view or widget | Wiring lives in the bloc/cubit `.create` factory (Rule 3) |
| Registering a use case in GetIt | Stateless pass-through — build it inline in `.create` from the repo (Rule 3) |
| Registering a stateless repository as `lazySingleton` | No state to share — `registerFactory`, created per use (Rule 3) |
| Building query/body maps inline in datasource/repo impl | The endpoint class owns the request shape (Rule 4) |
| Endpoint methods taking primitives (`id`, `name`, `limit`) | Always a Request DTO — `Endpoint.query(XxxRequestDto)` (Rule 4) |
| Hardcoding path strings in repository impl | Untestable and cannot change by environment — add default param to constructor |
| Importing `auth` or `router` inside `firebase` package | Circular dependency — use callback pattern |
| Calling `emit()` directly in async callbacks | Crash after cubit is closed — use `safeEmit()` |
| Making a widget `part of` a screen it isn't exclusive to | Breaks reuse — widgets used by 2+ screens must stay standalone, `import`-ed files |
| Importing Flutter, Jaspr, `package:web`, `flutter_bloc` or `dart:io`/`dart:isolate` in `kit_*` / `app_shared` | Breaks the web (or mobile) build — use `package:bloc`, `kitPrint`, `runInBackground`, or a contract + per-app adapter |
| Putting UI objects (`ScrollController`, `TextEditingController`, `BuildContext`) in a bloc/cubit | Ties the bloc to Flutter so it can't be shared — the view owns them (a private `StatefulWidget`/`StatefulComponent` inside the screen) and sends events; for "reset scroll on new results" expose a counter in state (see `PokemonHomeState.resultsVersion`) |
| Writing a bloc/use case/repository in `apps/mobile` or `apps/web` | Business logic is written once in `app_shared`; apps only hold views, navigators, DI and platform adapters |
| Passing web screen data through router `extra` | Lost on reload / not shareable — use a path param (Rule 5, web exception) |
| Bumping one `jaspr*` version alone | `jaspr`, `jaspr_builder`, `jaspr_test`, `jaspr_router` and `jaspr_cli` are pinned together — see "Web (Jaspr)" |

---

## Web (Jaspr)

`apps/web` is a **client-mode** Jaspr app (SPA: real HTML/CSS DOM, compiled with dart2js). It consumes exactly the same `app_shared` blocs as mobile — only the view layer, navigators, DI and browser adapters are web-specific. Reference features: `features/pokemon_home/` (pagination + search + filter, shared `PokemonHomeBloc`) and `features/pokemon_detail/` (shared `DetailBloc`).

```
apps/web/
  web/index.html                    <base href="/"> — required for deep links like /pokemon/25
  lib/main.client.dart              Injection.init(WebEnvironment.config) → runApp(App())
  lib/app.dart                      Router + @css global styles
  lib/core/config/web_environment.dart   flavors via --dart-define (FLAVOR, BASE_URL)
  lib/core/di/                      same module order as mobile: network → auth → feature repos
  lib/core/navigation/app_navigator.dart  collects every feature navigator's route
  lib/core/data/datasource/         browser implementations of app_shared datasource contracts
  lib/features/<feature>/
    <feature>_navigator.dart        Route + show() + link()   (Rule 5, path params)
    view/<feature>_page.dart        StatelessComponent wrapping BaseBlocView
    view/widgets/*.dart             part of the page (Pattern 9)
```

**Page recipe** — mirrors Rule 1:

```dart
class XxxPage extends StatelessComponent {
  const XxxPage({required this.id, super.key});
  final int id;

  @override
  Component build(BuildContext context) {
    return BaseBlocView<XxxBloc, XxxState>(          // package:jaspr_kit_core
      create: XxxBloc.create,                          // from app_shared
      onReady: (bloc) => bloc.add(XxxLoad(id)),
      builder: (context, state, bloc) => section([...]),
    );
  }

  @css
  static List<StyleRule> get styles => [...];         // collected into main.css
}
```

- **Lifecycle:** `jaspr_kit_core`'s `BaseBlocView` = Critical Pattern 3 (create → publishActive → onInit; post-frame onReady; dispose → unpublish → close). `onReady` runs only in the browser (`kIsWeb`) so server/static rendering never triggers data loads.
- **Avoid `Component.fragment` as the root of anything that gets removed on navigation** (a page, a `StatefulComponent`'s build). jaspr 0.23.1 asserts while detaching it ("Non-empty attached fragments must have a valid last child reference"); in `jaspr serve` (debug) that aborts the rebuild — URL changes on browser Back, old page stays. Release builds hide it (asserts off), so always check navigation under `web:serve`. Use a wrapper element with `display: contents` instead, as `BaseBlocView` does.
- **Same route, different params** (detail → detail along the evolution chain): give the page a `ValueKey` per param in the navigator **and** a per-param `activeKey`, otherwise the old bloc is reused / the new one gets unpublished.
- **Styles:** `@css static` getters on public components (jaspr_builder cannot reach private `_Xxx` classes — spread their styles into the page's getter). Colors come from `kit_design_tokens` as CSS variables (`var(--kit-primary)`, `var(--kit-gray-50)`, `KitColors.*`) via `jaspr_kit_ui` — never hard-code hex.
- **Browser adapters:** `BrowserTokenStore` (jaspr_kit_auth — Web Storage is XSS-readable; for production keep the refresh token in an `HttpOnly` cookie), `BrowserNetworkInfo` (jaspr_kit_network). Anything importing `package:web` cannot run in VM tests — keep it out of components you test with `jaspr_test`.
- **SSR experiment:** `apps/web_ssr_demo` (`melos run web:ssr:serve`) renders home + detail on the server: `AsyncStatelessComponent` pages fetch with the shared use cases, `@client` islands hydrate with the server's data (`HomeSeed` @encoder/@decoder → `PokemonHomeBloc.create(initialState:)`, no refetch). Server DI registers only public, user-neutral singletons. Not wired into apps/web yet.
- **SSR caveat:** if you ever switch to `server` mode, one process serves every user — GetIt singletons (`AuthManager`, cached repositories) would be shared across requests. Keep auth/bloc state in `@client` components only.
- **Version pins:** `jaspr`/`jaspr_builder`/`jaspr_test` = 0.23.1 and `jaspr_router` = 0.8.2, because the workspace has a single lockfile and the Flutter SDK pins `meta`, which caps `analyzer` (jaspr_builder ≥ 0.23.2 needs analyzer 12 → meta ≥ 1.18); jaspr_router ≥ 0.8.3 needs jaspr ≥ 0.23.2. When Flutter moves to `meta ≥ 1.18`, bump all of them (and `jaspr_cli`) together.
- **Paginated lists** (reference: `features/pokemon_home/`, same `PokemonHomeBloc` as mobile): put `InfiniteScrollTrigger` (jaspr_kit_core, IntersectionObserver) after the last item with `watch: state.items.length` and `onVisible: → LoadMore` — no scroll listeners. Render your own skeleton / "loading more" / retry rows and pass `showLoadingOverlay: false` to `BaseBlocView`. `PaginatedBloc` already discards stale pages and never drops a reload, so views may fire `LoadMore` freely.
- **List state belongs in the URL:** search/filter go to query params (`/?q=…`, `/?type=…`) via the navigator's `syncUrl()` (`Router.replace`, deferred to a post-frame callback — never mid-build), and the route passes them back into the page's `Started` event. That gives reload, sharing and Back-from-detail for free.
- **Browser APIs in components** go through `package:universal_web` (VM stubs) instead of `package:web`, so the component still compiles under `jaspr_test`; guard calls with `kIsWeb`.
- **Not shared yet:** i18n (slang strings live in apps/mobile; move the `.i18n.json` files into a shared package using `slang` without `slang_flutter` when the web needs them).
