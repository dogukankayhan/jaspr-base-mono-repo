import 'package:app_shared/features/login/bloc/login_bloc.dart';
import 'package:app_shared/features/login/bloc/login_event.dart';
import 'package:app_shared/features/login/bloc/login_state.dart';
import 'package:kit_auth/auth/manager/auth_manager.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthManager>()])
void main() {
  late MockAuthManager mockAuthManager;
  late LoginBloc loginBloc;

  setUp(() {
    provideDummy<Result<void, ApiError>>(const Ok(null));
    mockAuthManager = MockAuthManager();
    loginBloc = LoginBloc(authManager: mockAuthManager);
  });

  tearDown(() async {
    await loginBloc.close();
  });

  group('LoginBloc initial state', () {
    test('has empty email and password', () {
      expect(loginBloc.state.email, '');
      expect(loginBloc.state.password, '');
    });

    test('has no errors, not loading, not success', () {
      expect(loginBloc.state.emailError, isNull);
      expect(loginBloc.state.passwordError, isNull);
      expect(loginBloc.state.isLoading, false);
      expect(loginBloc.state.isSuccess, false);
    });
  });

  group('LoginEmailChanged', () {
    test('emits state with new email', () async {
      loginBloc.add(const LoginEmailChanged('test@example.com'));
      await Future.delayed(Duration.zero);
      expect(loginBloc.state.email, 'test@example.com');
    });

    test('clears emailError and errorMessage on email change', () async {
      loginBloc.add(const LoginSubmitted());
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginEmailChanged('new@example.com'));
      await Future.delayed(Duration.zero);

      expect(loginBloc.state.emailError, isNull);
      expect(loginBloc.state.errorMessage, isNull);
    });
  });

  group('LoginPasswordChanged', () {
    test('emits state with new password', () async {
      loginBloc.add(const LoginPasswordChanged('secret123'));
      await Future.delayed(Duration.zero);
      expect(loginBloc.state.password, 'secret123');
    });

    test('clears passwordError on password change', () async {
      loginBloc.add(const LoginSubmitted());
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginPasswordChanged('newpass'));
      await Future.delayed(Duration.zero);

      expect(loginBloc.state.passwordError, isNull);
    });
  });

  group('LoginDemoFillRequested', () {
    test('fills demo credentials', () async {
      loginBloc.add(const LoginDemoFillRequested());
      await Future.delayed(Duration.zero);

      expect(loginBloc.state.email, isNotEmpty);
      expect(loginBloc.state.password, isNotEmpty);
    });

    test('clears all errors after demo fill', () async {
      loginBloc.add(const LoginDemoFillRequested());
      await Future.delayed(Duration.zero);

      expect(loginBloc.state.emailError, isNull);
      expect(loginBloc.state.passwordError, isNull);
      expect(loginBloc.state.errorMessage, isNull);
    });
  });

  group('LoginSubmitted — validation', () {
    test(
      'empty email emits emailError, does NOT call authManager.login',
      () async {
        loginBloc.add(const LoginPasswordChanged('password123'));
        await Future.delayed(Duration.zero);

        loginBloc.add(const LoginSubmitted());
        await Future.delayed(Duration.zero);

        expect(loginBloc.state.emailError, isNotNull);
        verifyNever(mockAuthManager.login(any, any));
      },
    );

    test('invalid email format emits emailError', () async {
      loginBloc.add(const LoginEmailChanged('not-an-email'));
      loginBloc.add(const LoginPasswordChanged('password123'));
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginSubmitted());
      await Future.delayed(Duration.zero);

      expect(loginBloc.state.emailError, isNotNull);
    });

    test('empty password emits passwordError', () async {
      loginBloc.add(const LoginEmailChanged('test@example.com'));
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginSubmitted());
      await Future.delayed(Duration.zero);

      expect(loginBloc.state.passwordError, isNotNull);
    });

    test('password shorter than 6 characters emits passwordError', () async {
      loginBloc.add(const LoginEmailChanged('test@example.com'));
      loginBloc.add(const LoginPasswordChanged('abc'));
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginSubmitted());
      await Future.delayed(Duration.zero);

      expect(loginBloc.state.passwordError, isNotNull);
    });
  });

  group('LoginSubmitted — success', () {
    test('calls authManager.login with trimmed email', () async {
      when(
        mockAuthManager.login(any, any),
      ).thenAnswer((_) async => const Ok(null));

      loginBloc.add(const LoginEmailChanged('test@example.com'));
      loginBloc.add(const LoginPasswordChanged('password123'));
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      verify(
        mockAuthManager.login('test@example.com', 'password123'),
      ).called(1);
    });

    test('emits isSuccess: true on successful login', () async {
      when(
        mockAuthManager.login(any, any),
      ).thenAnswer((_) async => const Ok(null));

      loginBloc.add(const LoginEmailChanged('test@example.com'));
      loginBloc.add(const LoginPasswordChanged('password123'));
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(loginBloc.state.isSuccess, true);
      expect(loginBloc.state.isLoading, false);
    });
  });

  group('LoginSubmitted — error', () {
    test('emits errorMessage on login failure', () async {
      when(mockAuthManager.login(any, any)).thenAnswer(
        (_) async => Err(ApiError(message: 'Geçersiz kimlik bilgileri')),
      );

      loginBloc.add(const LoginEmailChanged('test@example.com'));
      loginBloc.add(const LoginPasswordChanged('password123'));
      await Future.delayed(Duration.zero);

      loginBloc.add(const LoginSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(loginBloc.state.errorMessage, 'Geçersiz kimlik bilgileri');
      expect(loginBloc.state.isLoading, false);
      expect(loginBloc.state.isSuccess, false);
    });
  });

  group('LoginState', () {
    test('initial state has correct default values', () {
      const state = LoginState();
      expect(state.email, '');
      expect(state.password, '');
      expect(state.emailError, isNull);
      expect(state.passwordError, isNull);
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
    });

    test('copyWith updates email without affecting other fields', () {
      const state = LoginState(email: 'old@example.com', isSuccess: true);
      final updated = state.copyWith(email: 'new@example.com');
      expect(updated.email, 'new@example.com');
      expect(updated.isSuccess, true);
    });

    test('copyWith with null emailError clears the error', () {
      const state = LoginState(emailError: 'Error');
      final updated = state.copyWith(emailError: null);
      expect(updated.emailError, isNull);
    });
  });
}
