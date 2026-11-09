# Migration Guide: Base BLoC Integration for flutter_base_kit

This guide explains how to integrate the Base BLoC architecture into the `flutter_base_kit` project.

## 📋 Prerequisites

### 1. Check Dependencies

Your `pubspec.yaml` file must contain:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3         # ADD
  equatable: ^2.0.5             # ADD
  get_it: ^7.6.0                # ALREADY EXISTS
  connectivity_plus: ^5.0.0     # ALREADY EXISTS
  dio: ^5.4.0                   # ALREADY EXISTS
```

### 2. Check Project Structure

Your project should have the following structure:

```
lib/
  core/
    managers/
      auth_manager/
        auth/
          manager/
            auth_manager.dart    # ✅ Exists
    networking/
      core/
        di/
          service_locator.dart   # ✅ Exists
        network/
          api/
            api_manager.dart     # ✅ Exists
```

---

## 🚀 Installation Steps

### Step 1: Add Base BLoC Files

```bash
# Copy the base_bloc folder under lib/core/
cp -r base_bloc/ your_project/lib/core/
```

Result structure:

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
    networking/
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Verify Main.dart

Ensure that GetIt and AuthManager are initialized in your `main.dart` file:

```dart
import 'package:flutter_base_kit/core/networking/core/di/service_locator.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/manager/auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Setup Dependency Injection
  await setupDI(
    baseUrl: 'https://your-api.com',
    tokenProvider: () async {
      // Token provider logic
      return null;
    },
  );
  
  // 2. Initialize AuthManager
  await setupAuth(
    getIt: getIt,
    apiManager: getIt<ApiManager>(),
    tokenStore: getIt<TokenStore>(),
  );
  
  runApp(const MyApp());
}
```

---

## 📝 Create Your First Feature

### Example: Login Screen

#### 1. Create State

`lib/features/auth/login/cubit/login_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';

class LoginState extends BaseState {
  final String email;
  final String password;
  final bool isPasswordVisible;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isPasswordVisible,
        ...super.props,
      ];
}
```

#### 2. Create Cubit

`lib/features/auth/login/cubit/login_cubit.dart`:

```dart
import 'package:flutter_base_kit/core/base_bloc/base_cubit.dart';
import 'package:flutter_base_kit/features/auth/login/cubit/login_state.dart';

class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit() : super(const LoginState());

  @override
  void onInit() {
    super.onInit();
    // Initialization logic
  }

  @override
  void onReady() {
    super.onReady();
    // Code that will run after widget is rendered
  }

  void setEmail(String value) {
    safeEmit(state.copyWith(email: value));
    _validateForm();
  }

  void setPassword(String value) {
    safeEmit(state.copyWith(password: value));
    _validateForm();
  }

  void togglePasswordVisibility() {
    safeEmit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }

  void _validateForm() {
    final isValid = state.email.isNotEmpty && 
                    state.password.length >= 6;
    safeEmit(state.copyWith(isValid: isValid));
  }

  Future<void> login() async {
    if (!state.isValid) return;

    safeEmit(state.copyWith(isLoading: true));

    // Login using AuthManager
    final result = await authManager.login(
      state.email,
      state.password,
    );

    result.when(
      ok: (_) {
        // Login successful
        safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: null,
        ));
        // Navigate to home
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

#### 3. Create View

`lib/features/auth/login/view/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base_kit/core/base_bloc/base_bloc_view.dart';
import 'package:flutter_base_kit/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_base_kit/features/auth/login/cubit/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<LoginCubit, LoginState>(
      create: () => LoginCubit(),
      builder: (context, state, cubit) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error message
                if (state.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),

                // Email field
                TextField(
                  onChanged: context.read<LoginCubit>().setEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  onChanged: context.read<LoginCubit>().setPassword,
                  obscureText: !state.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: context
                          .read<LoginCubit>()
                          .togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isValid && !state.isLoading
                        ? () => context.read<LoginCubit>().login()
                        : null,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 🎯 Important Points

### 1. Using AuthManager

AuthManager is available in BaseCubit via DI:

```dart
class MyCubit extends BaseCubit<MyState> {
  Future<void> doSomething() async {
    // Use authManager directly
    final result = await authManager.login(email, password);
    
    result.when(
      ok: (_) => handleSuccess(),
      err: (error) => handleError(error),
    );
  }
}
```

### 2. Using ApiManager

ApiManager is automatically resolved from GetIt in BaseCubit:

```dart
class UserCubit extends BaseCubit<UserState> {
  Future<void> loadUser() async {
    // apiManager is ready
    final response = await apiManager.get<UserDto>(
      path: '/users/me',
      fromJson: (json) => UserDto.fromJson(json as Map<String, dynamic>),
    );
    
    safeEmit(state.copyWith(user: response.data));
  }
}
```

### 3. Result Pattern

The project uses the `Result<T, ApiError>` pattern:

```dart
final result = await authManager.login(email, password);

// Handle with when
result.when(
  ok: (data) {
    // Success
  },
  err: (error) {
    // Error
    print(error.message);
  },
);
```

### 4. Safe Emit

Always use `safeEmit` in async operations:

```dart
Future<void> loadData() async {
  safeEmit(state.copyWith(isLoading: true));
  
  try {
    final data = await fetchData();
    safeEmit(state.copyWith(data: data, isLoading: false));
  } catch (e) {
    safeEmit(state.copyWith(errorMessage: '$e', isLoading: false));
  }
}
```

---

## 🧪 Writing Tests

Writing Bloc tests is very simple:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginCubit', () {
    late LoginCubit cubit;

    setUp(() {
      cubit = LoginCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const LoginState());
    });

    blocTest<LoginCubit, LoginState>(
      'setEmail updates email in state',
      build: () => cubit,
      act: (cubit) => cubit.setEmail('test@example.com'),
      expect: () => [
        const LoginState(email: 'test@example.com'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'login sets loading to true then false',
      build: () => cubit,
      seed: () => const LoginState(
        email: 'test@example.com',
        password: 'password123',
        isValid: true,
      ),
      act: (cubit) => cubit.login(),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });
}
```

Additional dependency for tests:

```yaml
dev_dependencies:
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
```

---

## 📊 Suggested Feature Structure

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
          widgets/
            login_form.dart
            login_button.dart
      register/
        cubit/
          register_cubit.dart
          register_state.dart
        view/
          register_screen.dart
    home/
      cubit/
        home_cubit.dart
        home_state.dart
      view/
        home_screen.dart
```

---

## ✅ Checklist

When adding a new feature:

- [ ] State class created
- [ ] State has copyWith method
- [ ] Equatable props correctly defined in State
- [ ] Cubit class inherits from BaseCubit
- [ ] onInit and onReady implemented
- [ ] safeEmit is used
- [ ] Result pattern correctly used
- [ ] View uses BaseBlocView
- [ ] Error handling completed
- [ ] Test written

---

## 🐛 Troubleshooting

### Problem: "type 'ApiManager' is not registered"

**Solution**: Make sure `setupDI` is called

```dart
void main() async {
  await setupDI(baseUrl: 'https://api.example.com');
  runApp(MyApp());
}
```

### Problem: "AuthManager.instance was called on null"

**Solution**: Make sure AuthManager setup is completed

```dart
void main() async {
  await setupDI(...);
  await setupAuth(...);
  runApp(MyApp());
}
```

### Problem: State is not updating

**Solution**: Check Equatable props

```dart
@override
List<Object?> get props => [
  // Add ALL fields
  email,
  password,
  ...super.props,
];
```

---

## 📚 Resources

- **Internal**:
  - `lib/core/base_bloc/README.md` - Detailed documentation
  - `lib/core/base_bloc/example_usage.dart` - Example code
  
- **External**:
  - [Flutter Bloc Docs](https://bloclibrary.dev/)
  - [Equatable Package](https://pub.dev/packages/equatable)
  - [Bloc Testing](https://pub.dev/packages/bloc_test)

---

## 🎉 Conclusion

The Base BLoC architecture is now integrated into your project!

**Next steps:**
1. Create your first feature (e.g. Login)
2. Write tests
3. Add other features

Best of luck! 🚀
