# flutter_kit_auth

Authentication layer for flutter_base_kit monorepo. Provides `AuthManager`, `AuthBloc`, social sign-in use cases, and secure token storage.

## Features

- Email/password login and registration
- Apple Sign-In and Google Sign-In
- Guest sign-in
- Automatic token persistence via `flutter_secure_storage`
- `AuthBloc` for reactive auth state
- Full Clean Architecture: entity → DTO → repository → use case → manager

## Setup

Call `setupAuth()` once during DI initialisation:

```dart
await setupAuth(
  getIt: getIt,
  apiManager: getIt<ApiManager>(),
  tokenStore: getIt<TokenStore>(),
);
```

This registers `AuthRemoteDataSource`, `AuthRepository`, `AuthManager`, and `AuthBloc` in getIt.

## AuthManager

```dart
final auth = getIt<AuthManager>();

// State
auth.isLoggedIn    // bool
auth.profile       // Profile? — id, email, firstName, lastName, avatarUrl
auth.tokens        // AuthTokens? — accessToken, refreshToken
auth.isBusy        // bool — true while a request is in-flight

// Email / password
await auth.login(email, password);
await auth.register(email: email, password: password);
await auth.logout();

// Social
await auth.signInWithApple(idToken);
await auth.signInWithGoogle(idToken);
await auth.signInAsGuest();

// Profile
await auth.fetchMe();
await auth.updateProfile({'firstName': 'Ali'});

// Token
await auth.refreshIfNeeded();
await auth.saveTokens(tokens);
```

All methods return `Result<void, ApiError>`:

```dart
final result = await auth.login(email, password);
result.when(
  ok: (_) => context.go('/home'),
  err: (error) => showSnackbar(error.message),
);
```

On startup, persisted tokens are loaded and a `/me` request is made automatically. No manual restore call needed.

## AuthBloc

`AuthBloc` listens to `AuthManager` via `ChangeNotifier` and keeps the auth state reactive across the app:

```dart
// Access
final bloc = getIt<AuthBloc>();
bloc.state.isAuthenticated  // bool
bloc.state.profile          // Profile?

// Events
bloc.add(const AuthStatusChanged());     // internal — emitted by AuthManager
bloc.add(const AuthLogoutRequested());   // trigger logout from UI
```

Typical usage in a router guard:

```dart
redirect: (context, state) {
  final isAuthenticated = getIt<AuthBloc>().state.isAuthenticated;
  return isAuthenticated ? null : '/login';
},
```

## Token Store

Tokens are stored encrypted. `SecureTokenStore` is the default implementation:

```dart
final store = SecureTokenStore();
await store.write(AuthTokens(accessToken: '...', refreshToken: '...'));
final tokens = await store.read();
await store.clear();
```

Implement `TokenStore` to use a custom storage backend.

## API Endpoints Expected

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/auth/login` | Email login → `TokensDto` |
| POST | `/auth/register` | Registration → `TokensDto` |
| POST | `/auth/refresh` | Token refresh → `TokensDto` |
| GET | `/auth/me` | Current user profile → `ProfileDto` |
| PATCH | `/auth/me` | Update profile → `ProfileDto` |
| POST | `/auth/logout` | Logout |
| POST | `/auth/apple` | Apple Sign-In → `TokensDto` |
| POST | `/auth/google` | Google Sign-In → `TokensDto` |
| POST | `/auth/guest` | Guest sign-in → `TokensDto` |

Token response fields accepted: `accessToken` or `access_token`, `refreshToken` or `refresh_token`.

## Dependencies

- `flutter_kit_network`
- `flutter_kit_core`
- `flutter_bloc`
- `equatable`
- `dio`
- `flutter_secure_storage`
- `google_sign_in`
- `sign_in_with_apple`
