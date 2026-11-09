# Architecture Guide

## Layer Diagram

```
┌─────────────────────────────────────────────────────┐
│                   Presentation                      │
│  Screen ← BlocBuilder ← Bloc/Cubit                  │
│  BaseBlocView: creation, lifecycle, loading overlay  │
├─────────────────────────────────────────────────────┤
│                     Domain                          │
│  UseCase → Repository (interface) → Entity          │
│  Pure Dart: platform-independent business logic     │
├─────────────────────────────────────────────────────┤
│                      Data                           │
│  RepositoryImpl → ApiManager → DTO                  │
│  fromJson / toDomain transformations happen here    │
├─────────────────────────────────────────────────────┤
│                    Network                          │
│  ApiManager → Dio + 8 Interceptors                  │
│  Result<T, E> wraps all responses                   │
└─────────────────────────────────────────────────────┘
```

Dependency direction: Presentation → Domain → Data → Network. There is no dependency in the opposite direction.

The Repository calls `ApiManager` directly (see `PokemonRepositoryImpl`, `UserRepositoryImpl`) — a separate `DataSource` is optional, only added for local storage or a source that must be swapped independently of the repository (see `FavoritesLocalDataSource`).

---

## Dashboard Feature — Full Data Flow

All layers using a concrete example:

```
1. BaseBlocView.initState() → DashboardBloc is created

2. (post-frame) DashboardBloc.onReady()
   └── add(DashboardLoadRequested())

3. DashboardBloc._onLoad(event, emit)
   └── emit(state.copyWith(isLoading: true))
   └── GetDashboardUseCase.call()

4. GetDashboardUseCase.call()
   └── DashboardRepository.getDashboard()  ← interface

5. DashboardRepositoryImpl.getDashboard()
   └── try { ApiManager.get<DashboardDto>(path: DashboardEndpoint.path,
             fromJson: DashboardDto.fromJson) } — no separate DataSource layer

6. ApiManager (Dio + interceptor chain)
   AuthInterceptor         → Adds Bearer token
   ConnectivityInterceptor → Error if offline
   RetryInterceptor        → Exponential backoff on 5xx (3 retries)
   CacheInterceptor        → Caches GET responses to SQLite
   RefreshTokenInterceptor → Refreshes token on 401
   RateLimiterInterceptor  → Rate limit per endpoint
   LoggingInterceptor      → HTTP log
   CertPinningInterceptor  → SSL certificate pinning verification
   On failure: throws ApiException(ApiError) — ApiManager never returns a Result

7. Back in DashboardRepositoryImpl.getDashboard()
   └── on success: dto.toDomain() → DashboardSummary, returns Ok(summary)
   └── on ApiException catch (e): returns Err(e.error)

8. Result<DashboardSummary, ApiError> propagates up unchanged through
   UseCase.call() → DashboardBloc._onLoad

9. DashboardBloc._onLoad
   result.when(
     ok: (s) => emit(state.copyWith(summary: s, isLoading: false)),
     err: (e) => emit(state.copyWith(errorMessage: e.message, isLoading: false)),
   )

10. DashboardScreen: BlocBuilder receives the new state, UI updates
    isLoading: true  → BaseBlocView shows LoadingOverlay
    errorMessage set → AppErrorBanner is shown
    summary set      → Stat cards are rendered
```

---

## Navigation Architecture — Navigator Pattern

```
AppNavigator (singleton)
├── LoginNavigator      → GoRoute('/login')
├── RegisterNavigator   → GoRoute('/register')
├── ShellNavigator      → StatefulShellRoute (bottom nav)
│   ├── DashboardNavigator  → GoRoute('/dashboard')
│   ├── AppointmentsNavigator
│   ├── CustomersNavigator
│   └── MoreNavigator
└── HomeNavigator       → GoRoute('/home', '/home/showcase')
```

Each Navigator:
- Holds its own path constant: `static const path = '/dashboard'`
- `show(BuildContext context)` static method: `context.go(path)`
- `route` getter: `GoRoute(path: path, builder: (_, __) => Screen())`

**Auth Guard:** `AppNavigator.redirect(isLoggedIn, path)` performs auth check for login/register pages. GoRouter's `redirect:` callback invokes this method.

**Navigation Facade:** `NavigationFacade` is a low-level helper (`push`, `pop`, `replace`). It is not used directly from feature screens — each feature uses its own navigator.

---

## Package Isolation Rules

```
flutter_kit_core     → cannot depend on any flutter_kit_* package
flutter_kit_network  → cannot depend on any flutter_kit_* package
flutter_kit_ui       → cannot depend on any flutter_kit_* package
flutter_kit_firebase → cannot depend on any flutter_kit_* package
flutter_kit_auth     → can depend on flutter_kit_network + flutter_kit_core
apps/mobile          → can depend on all of them
```

`flutter_kit_firebase` is forbidden to depend on GoRouter or `flutter_kit_auth` (creates a circular dependency). Solution: callback pattern (`NotificationDeepLinkHandler.onNavigate`).

---

## BaseState.isLoading → LoadingOverlay Flow

```
DashboardBloc.emit(state.copyWith(isLoading: true))
  └── BlocBuilder detects state change
      └── BaseBlocView._shouldShowLoading(state) → true
          └── LoadingOverlay is shown (flutter_kit_ui)

DashboardBloc.emit(state.copyWith(isLoading: false))
  └── LoadingOverlay is hidden
```

`BaseBlocView` automatically monitors `isLoading` — feature screens do not need to manage the loading overlay manually.

---

## DI: Factory vs Singleton Decisions

| Type | Registration | Reason |
|-----|-------|-------|
| `ApiManager` | `lazySingleton` | Interceptor chain is established once and lives for the lifetime of the application |
| `TokenStore` | `lazySingleton` | SecureStorage wrapper, not stateful |
| `AuthManager` | `lazySingleton` | Auth state must be the single source of truth |
| `AuthBloc` | `singleton` | Listens to the entire app auth state, used by the navigation guard |
| Feature BLoC/Cubit | No registration in GetIt | `BaseBlocView.create` factory creates it, closes it on dispose |

Feature BLoCs are not registered in GetIt — `BaseBlocView` manages their lifecycle. `getIt<DashboardBloc>()` does not and should not work.

---

## Interceptor Chain Order

Dio interceptors run in the order they are added to the list (request: first to last, response: last to first):

```
Request direction (first → last):
  1. CertificatePinningInterceptor  ← SSL verification
  2. ConnectivityInterceptor        ← Offline check
  3. RateLimiterInterceptor         ← Throttle
  4. AuthInterceptor                ← Add Bearer token
  5. CacheInterceptor               ← Return from cache (GET)
  6. LoggingInterceptor             ← Request log
  7. RetryInterceptor               ← Retry after error
  8. RefreshTokenInterceptor        ← 401 → Refresh token → Retry
```

---

## Localization

`slang_flutter` is used. Translation files: `apps/mobile/lib/core/localization/i18n/*.i18n.json`.
Generated file: `strings.g.dart` in the same folder (not committed, generated by `dart run slang`).

```dart
// Usage
Text(context.t.login.title)
Text(context.t.errors.networkError)
```

Avoid using hard-coded strings — every UI text must come through `strings.g.dart`.
