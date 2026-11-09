# Base BLoC Architecture

Base Architecture structure developed using the Flutter Bloc package, specific to the **flutter_base_kit** project.

## 📁 File Structure

```
lib/core/base_bloc/
├── base_state.dart              # Base state classes
├── base_cubit.dart              # Base cubit class
├── base_bloc_view.dart          # Base view widget
├── active_cubit_helper.dart     # Active key helper functions
├── example_usage.dart           # Example usage
└── README.md                    # This file
```

## 🎯 Features

### BaseCubit
- ✅ **Lifecycle Management**: `onInit`, `onReady`, `close`
- ✅ **Auth Integration**: `AuthManager` instance accessed dynamically
- ✅ **API Integration**: `ApiManager` (obtained from GetIt)
- ✅ **Result Pattern**: Built-in support for `Result<T, ApiError>`
- ✅ **Safe Emit**: Prevents crash-on-emit errors when a Cubit is closed
- ✅ **Context Access**: Accessible BuildContext

### BaseBlocView
- ✅ **Active Key System**: Key-based cubit management with GetIt
- ✅ **Lifecycle Callbacks**: `onInit`, `onReady`, `onDispose` callbacks
- ✅ **Post-Frame Support**: Optional post-frame callback execution
- ✅ **Auto Cleanup**: Cubit is automatically disposed of when the view closes

### BaseState
- ✅ **Equatable**: Built-in support for performance optimizations
- ✅ **Common Properties**: `isLoading`, `isValid`, `errorMessage` properties
- ✅ **Type Safety**: Compile-time type checking

---

## 🚀 Installation

### 1. Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.0  # Already exists in the project
```

### 2. Add Files

```bash
# Copy the base_bloc folder under lib/core/
cp -r base_bloc/ lib/core/
```

### 3. Project Structure

```
lib/
  core/
    base_bloc/              ← NEW
      base_state.dart
      base_cubit.dart
      base_bloc_view.dart
      active_cubit_helper.dart
      example_usage.dart
      README.md
    managers/
      auth_manager/
    networking/
      core/
        di/
          service_locator.dart  # GetIt setup
```

---

## 📚 Usage

### Simple Example

#### 1. Create State

```dart
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';

class CounterState extends BaseState {
  final int count;

  const CounterState({
    required this.count,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  CounterState copyWith({
    int? count,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [count, ...super.props];
}
```

#### 2. Create Cubit

```dart
import 'package:flutter_base_kit/core/base_bloc/base_cubit.dart';

class CounterCubit extends BaseCubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0));

  @override
  void onInit() {
    super.onInit();
    print('Counter initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // API calls go here
  }

  void increment() {
    safeEmit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    safeEmit(state.copyWith(count: state.count - 1));
  }
}
```

#### 3. Create View

```dart
import 'package:flutter_base_kit/core/base_bloc/base_bloc_view.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<CounterCubit, CounterState>(
      create: () => CounterCubit(),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Counter')),
          body: Center(
            child: Text(
              '${state.count}',
              style: const TextStyle(fontSize: 48),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => context.read<CounterCubit>().increment(),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                onPressed: () => context.read<CounterCubit>().decrement(),
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🔥 Using AuthManager and ApiManager

### AuthManager (from GetIt)

```dart
class LoginCubit extends BaseCubit<LoginState> {
  Future<void> login(String email, String password) async {
    safeEmit(state.copyWith(isLoading: true));
    
    // AuthManager instance via DI
    final result = await authManager.login(email, password);
    
    result.when(
      ok: (_) {
        // Login successful
        safeEmit(state.copyWith(isLoading: false));
      },
      err: (error) {
        // Login failed
        safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ));
      },
    );
  }
}
```

### ApiManager (GetIt)

```dart
class UserCubit extends BaseCubit<UserState> {
  Future<void> loadUser() async {
    safeEmit(state.copyWith(isLoading: true));
    
    try {
      // ApiManager comes from GetIt
      final response = await apiManager.get<UserDto>(
        path: '/users/me',
        fromJson: (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      
      safeEmit(state.copyWith(
        user: response.data,
        isLoading: false,
      ));
    } catch (e) {
      safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load user: $e',
      ));
    }
  }
}
```

---

## 🎓 Advanced Features

### 1. Active Key System

To distinguish when multiple screens of the same type are open in the navigation stack:

```dart
// Screen 1
BaseBlocView<DetailCubit, DetailState>(
  create: () => DetailCubit('item-123'),
  activeKey: 'detail-123',
  builder: (context, state) => DetailUI(),
)

// Screen 2
BaseBlocView<DetailCubit, DetailState>(
  create: () => DetailCubit('item-456'),
  activeKey: 'detail-456',
  builder: (context, state) => DetailUI(),
)

// Access from elsewhere
import 'package:flutter_base_kit/core/base_bloc/active_cubit_helper.dart';

final cubit = getActiveOrNull<DetailCubit>(key: 'detail-123');
cubit?.doSomething();
```

### 2. Lifecycle Callbacks

```dart
BaseBlocView<MyCubit, MyState>(
  create: () => MyCubit(),
  onInit: (cubit) {
    print('View initialized');
  },
  onReady: (cubit) {
    print('View ready, making API calls');
    cubit.loadData();
  },
  onDispose: (cubit) {
    print('View disposing');
  },
  builder: (context, state) => MyUI(),
)
```

### 3. Post-Frame Control

```dart
BaseBlocView<MyCubit, MyState>(
  create: () => MyCubit(),
  usePostFrame: false, // onReady is called immediately
  builder: (context, state) => MyUI(),
)
```

### 4. Error Handling with Result Pattern

```dart
class DataCubit extends BaseCubit<DataState> {
  Future<void> loadData() async {
    safeEmit(state.copyWith(isLoading: true));
    
    try {
      final response = await apiManager.get<DataDto>(
        path: '/data',
        fromJson: (json) => DataDto.fromJson(json as Map<String, dynamic>),
      );
      
      safeEmit(state.copyWith(
        data: response.data,
        isLoading: false,
      ));
    } on ApiException catch (e) {
      safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: e.error.message,
      ));
    } catch (e) {
      safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error: $e',
      ));
    }
  }
}
```

---

## 🔄 Integration with the Existing Structure

### GetIt Setup

The project already uses GetIt (`service_locator.dart`):

```dart
// lib/core/networking/core/di/service_locator.dart
final getIt = GetIt.instance;

Future<void> setupDI({...}) async {
  // ApiManager is registered
  getIt.registerLazySingleton<ApiManager>(...);
}
```

BaseCubit accesses these DI services:

```dart
abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  // Get ApiManager from GetIt
  ApiManager get apiManager => getIt<ApiManager>();
  
  // AuthManager from GetIt
  AuthManager get authManager => getIt<AuthManager>();
}
```

---

## 📖 Best Practices

### 1. State Naming

```dart
// ✅ Good
class UserState extends BaseState { ... }
class ProductListState extends BaseState { ... }

// ❌ Bad
class UserData extends BaseState { ... }
```

### 2. copyWith Pattern

```dart
// ✅ Good - Override for each field
UserState copyWith({
  User? user,
  bool? isLoading,
  String? errorMessage,
}) {
  return UserState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
```

### 3. API Calls

```dart
// ✅ Good - inside onReady
@override
void onReady() {
  super.onReady();
  loadInitialData();
}

// ❌ Bad - inside onInit
@override
void onInit() {
  super.onInit();
  loadInitialData(); // Widget not rendered yet!
}
```

### 4. Error Handling

```dart
// ✅ Good - Use Result pattern
result.when(
  ok: (data) => handleSuccess(data),
  err: (error) => handleError(error),
);

// ❌ Bad - Throw catch without proper handling
try {
  await riskyOperation();
} catch (e) {
  print(e); // Just logging is not enough
}
```

---

## 🐛 Common Issues

### Issue 1: "Bad state: Cannot emit new states after calling close"

**Solution**: Use `safeEmit`

```dart
// ✅ Good
void updateData() {
  safeEmit(state.copyWith(data: newData));
}

// ❌ Bad
void updateData() {
  emit(state.copyWith(data: newData));
}
```

### Issue 2: State is not updating

**Solution**: Check Equatable props

```dart
// ✅ Good
@override
List<Object?> get props => [user, posts, ...super.props];

// ❌ Bad
@override
List<Object?> get props => super.props;
```

### Issue 3: GetIt registration error

**Solution**: Make sure `setupDI` is called

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  await setupDI(baseUrl: 'https://api.example.com');
  
  // Initialize AuthManager
  await setupAuth(...);
  
  runApp(MyApp());
}
```

---

## 📊 Project Structure Example

```
lib/
  features/
    auth/
      login/
        cubit/
          login_cubit.dart
          login_state.dart
        view/
          login_screen.dart
    home/
      cubit/
        home_cubit.dart
        home_state.dart
      view/
        home_screen.dart
  core/
    base_bloc/          ← Base structure
    managers/
      auth_manager/     ← Singleton AuthManager
    networking/
      core/
        di/
          service_locator.dart  ← GetIt setup
        network/
          api/
            api_manager.dart    ← ApiManager
```

---

## 🔗 Related Files

- `packages/flutter_kit_auth/lib/auth/manager/auth_manager.dart` - AuthManager
- `packages/flutter_kit_network/lib/core/di/service_locator.dart` - GetIt setup
- `packages/flutter_kit_network/lib/core/network/api/api_manager.dart` - ApiManager implementation
- `packages/flutter_kit_network/lib/core/utils/result.dart` - Result<T, E> pattern

---

## 📖 More Information

- [Flutter Bloc Documentation](https://bloclibrary.dev/)
- [Equatable Package](https://pub.dev/packages/equatable)
- [GetIt - Service Locator](https://pub.dev/packages/get_it)

---

## ✨ Summary

This base_bloc package:
- ✅ Fully compatible with the current `flutter_base_kit` project
- ✅ Uses GetIt dependency injection
- ✅ Supports AuthManager registrations
- ✅ Works with Result<T, ApiError> pattern
- ✅ Handles multiple instances with the active key system
- ✅ Provides lifecycle management (onInit, onReady, close)
- ✅ Implements type-safe state management
- ✅ Offers a test-friendly architecture

See `example_usage.dart` for detailed examples! 🚀
