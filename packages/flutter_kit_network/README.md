# flutter_kit_network

Networking layer for flutter_base_kit monorepo. Built on Dio with a full interceptor stack, offline queue, persistent cache, and analytics.

## Features

- `ApiManager` interface — clean abstraction over HTTP
- Full interceptor stack (auth, refresh, retry, cache, rate-limiter, connectivity, logging)
- `Result<T, ApiError>` pattern for type-safe error handling
- Offline request queue — queued requests replayed when connectivity returns
- Persistent GET cache via SQLite
- Request queue with priority support
- Upload / download helpers

## Setup

Call `setupNetworkingWithApiConfig()` once at app startup:

```dart
await setupNetworkingWithApiConfig(
  config: ApiConfig(
    baseUrl: 'https://api.example.com',
    enableLogging: true,
  ),
  tokenProvider: () => tokenStore.readAccess(),
  refreshTokenProvider: () => tokenStore.readRefresh(),
  refreshTokenFunction: (refreshToken) async {
    // return new access token or null
  },
  onTokenRefreshed: (accessToken, refreshToken) {
    // persist the new tokens
  },
);
```

Or use `setupNetworking()` with `EnvironmentConfig` for the full feature set including offline queue and analytics.

## Token Flow

```
Every request
  → AuthInterceptor reads access token from tokenProvider
  → Authorization: Bearer <token>

On 401
  → RefreshTokenInterceptor calls refreshTokenFunction
  → Parallel requests wait for the same refresh (waiter pattern)
  → Request retried with new token
  → If refresh fails → session cleared
```

## ApiManager Usage

```dart
final api = getIt<ApiManager>();

// GET
final response = await api.get<Map<String, dynamic>>(path: '/users/me');

// POST
final response = await api.post<Map<String, dynamic>>(
  path: '/items',
  body: {'name': 'Widget'},
);

// Upload
await api.upload(
  path: '/upload',
  filePath: file.path,
  onSendProgress: (sent, total) => print('$sent/$total'),
);

// Download
await api.download(
  path: '/file.pdf',
  savePath: '/local/file.pdf',
  onReceiveProgress: (received, total) => print('$received/$total'),
);
```

## Result Pattern

```dart
response.when(
  ok: (data) {
    final model = MyModel.fromJson(data);
    // success
  },
  err: (error) {
    print(error.message);       // user-facing message
    print(error.statusCode);    // HTTP code (nullable)
    print(error.type);          // ApiErrorType enum
  },
);
```

## Interceptors

| Interceptor | Trigger | Behaviour |
|---|---|---|
| `ConnectivityInterceptor` | Every request | Rejects immediately if offline |
| `AuthInterceptor` | Every request | Adds Bearer token from `tokenProvider` |
| `RateLimiterInterceptor` | Every request | Throttles requests per endpoint |
| `CacheInterceptor` | GET requests | Returns cached response if fresh |
| `RetryInterceptor` | Network errors | Retries with exponential back-off |
| `RefreshTokenInterceptor` | 401 responses | Refreshes token, replays request |
| `LoggingInterceptor` | Every request | Logs request/response details |

## Dependencies

- `dio`
- `connectivity_plus`
- `shared_preferences`
- `sqflite` + `path`
- `get_it`
