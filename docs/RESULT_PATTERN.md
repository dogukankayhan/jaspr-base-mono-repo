# Result\<T, E\> Pattern — Quick-Start

## What is it, Why is it here?

`Result<T, E>` (from `flutter_kit_network`) represents any asynchronous operation that can result in either success or failure.

**The problem with the standard try/catch approach in Flutter:**
```dart
// try/catch: compiler CANNOT verify if you handled both states
try {
  final data = await repo.fetch();
  // ...
} catch (e) {
  // error handling — easy to forget
}
```

**With Result:**
```dart
// when() is exhaustive — both branches are mandatory, verified by the compiler
final result = await repo.fetch();
result.when(
  ok: (data) => /* success path */,
  err: (error) => /* error path */,
);
```

---

## Three Fundamental Methods

### `.when(ok:, err:)`
Handles both states. Most common usage:
```dart
result.when(
  ok: (value) => doSomethingWith(value),
  err: (error) => handleError(error),
);
```

### `.isOk` and `.isErr`
Boolean check:
```dart
if (result.isOk) {
  // safely proceed
}
```

### Direct access to value (use with care)
```dart
// Only after isOk check:
final value = (result as Ok<T, E>).value;
```

---

## Correct Usage in BLoC

```dart
Future<void> _onLoad(
  DashboardLoadRequested event,
  Emitter<DashboardState> emit,
) async {
  emit(state.copyWith(isLoading: true, errorMessage: null));

  final result = await _getDashboard();

  result.when(
    ok: (summary) => emit(
      state.copyWith(summary: summary, isLoading: false),
    ),
    err: (error) => emit(
      state.copyWith(errorMessage: error.message, isLoading: false),
    ),
  );
}
```

**Critical:** `isLoading: false` must be set in both branches. If forgotten, the screen will get stuck on the loading animation.

---

## Common Mistakes

### Mistake 1: Forgetting to emit in the err branch
```dart
// WRONG — isLoading never becomes false
result.when(
  ok: (data) => emit(state.copyWith(data: data, isLoading: false)),
  err: (_) {},  // ← BUG
);

// CORRECT
result.when(
  ok: (data) => emit(state.copyWith(data: data, isLoading: false)),
  err: (e) => emit(state.copyWith(errorMessage: e.message, isLoading: false)),
);
```

### Mistake 2: Wrapping try/catch inside a UseCase
```dart
// WRONG — Result already wraps errors, double wrapping
@override
Future<Result<DashboardSummary, ApiError>> call() async {
  try {
    return await _repository.getDashboard();
  } catch (e) {
    return Err(ApiError(message: e.toString())); // ← WRONG
  }
}

// CORRECT — propagate directly
@override
Future<Result<DashboardSummary, ApiError>> call() =>
    _repository.getDashboard();
```

### Mistake 3: Doing a null check
```dart
// WRONG
if (result.value != null) { ... }

// CORRECT
result.when(ok: (v) { ... }, err: (e) { ... });
```

---

## ApiError Fields

```dart
class ApiError {
  final int? statusCode;  // HTTP status (401, 404, 500...) — can be null (network error)
  final String message;   // User-friendly message
}
```

When `statusCode` is null, it usually indicates a timeout, DNS, or SSL error.

---

## Propagation from Repository to UseCase

`ApiManager` itself never returns a `Result` — it returns `ApiResponse<T>` on success and **throws** `ApiException` on failure. The `Result` is born in the repository, which wraps the call in try/catch:

```
ApiManager.get<DashboardDto>() → ApiResponse<DashboardDto>  (throws ApiException on failure)
RepositoryImpl.getDashboard()  → Result<DashboardSummary, ApiError>  (dto.toDomain() on success,
                                  catch (ApiException e) → Err(e.error) on failure)
UseCase.call()                 → Result<DashboardSummary, ApiError>  (return repo directly)
Bloc._onLoad()                 → updates state, does not return anything
```

Every layer after the Repository passes the `Result` along without rewrapping it — only the BLoC layer converts it to state. See `PokemonRepositoryImpl`/`UserRepositoryImpl` for the real `try`/`on ApiException catch` pattern.

---

## Creating Ok and Err

```dart
// Success
return const Ok(dashboardSummary);

// Error
return const Err(ApiError(statusCode: 404, message: 'Not found'));

// Dummy value in tests (for Mockito)
provideDummy<Result<DashboardSummary, ApiError>>(
  const Ok(DashboardSummary(...)),
);
```
