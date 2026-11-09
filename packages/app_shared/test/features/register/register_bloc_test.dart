import 'package:app_shared/features/register/bloc/register_bloc.dart';
import 'package:app_shared/features/register/bloc/register_event.dart';
import 'package:app_shared/features/register/bloc/register_state.dart';
import 'package:kit_auth/auth/manager/auth_manager.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_bloc_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthManager>()])
void main() {
  late MockAuthManager mockAuthManager;
  late RegisterBloc registerBloc;

  setUp(() {
    provideDummy<Result<void, ApiError>>(const Ok(null));
    mockAuthManager = MockAuthManager();
    registerBloc = RegisterBloc(authManager: mockAuthManager);
  });

  tearDown(() async {
    await registerBloc.close();
  });

  group('RegisterBloc initial state', () {
    test('has empty all fields', () {
      expect(registerBloc.state.firstName, '');
      expect(registerBloc.state.lastName, '');
      expect(registerBloc.state.email, '');
      expect(registerBloc.state.password, '');
    });

    test('has no errors, not loading, not success', () {
      expect(registerBloc.state.firstNameError, isNull);
      expect(registerBloc.state.lastNameError, isNull);
      expect(registerBloc.state.emailError, isNull);
      expect(registerBloc.state.passwordError, isNull);
      expect(registerBloc.state.isLoading, false);
      expect(registerBloc.state.isSuccess, false);
    });
  });

  group('Field changes', () {
    test(
      'RegisterFirstNameChanged emits new firstName and clears error',
      () async {
        registerBloc.add(const RegisterFirstNameChanged('Ali'));
        await Future.delayed(Duration.zero);
        expect(registerBloc.state.firstName, 'Ali');
        expect(registerBloc.state.firstNameError, isNull);
      },
    );

    test(
      'RegisterLastNameChanged emits new lastName and clears error',
      () async {
        registerBloc.add(const RegisterLastNameChanged('Veli'));
        await Future.delayed(Duration.zero);
        expect(registerBloc.state.lastName, 'Veli');
        expect(registerBloc.state.lastNameError, isNull);
      },
    );

    test('RegisterEmailChanged emits new email and clears error', () async {
      registerBloc.add(const RegisterEmailChanged('ali@example.com'));
      await Future.delayed(Duration.zero);
      expect(registerBloc.state.email, 'ali@example.com');
      expect(registerBloc.state.emailError, isNull);
    });

    test(
      'RegisterPasswordChanged emits new password and clears error',
      () async {
        registerBloc.add(const RegisterPasswordChanged('secret123'));
        await Future.delayed(Duration.zero);
        expect(registerBloc.state.password, 'secret123');
        expect(registerBloc.state.passwordError, isNull);
      },
    );
  });

  group('RegisterSubmitted — validation', () {
    test('empty firstName emits firstNameError', () async {
      _fillValidFields(registerBloc, firstName: '');
      await Future.delayed(Duration.zero);

      registerBloc.add(const RegisterSubmitted());
      await Future.delayed(Duration.zero);

      expect(registerBloc.state.firstNameError, isNotNull);
      verifyNever(
        mockAuthManager.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
        ),
      );
    });

    test('empty lastName emits lastNameError', () async {
      _fillValidFields(registerBloc, lastName: '');
      await Future.delayed(Duration.zero);

      registerBloc.add(const RegisterSubmitted());
      await Future.delayed(Duration.zero);

      expect(registerBloc.state.lastNameError, isNotNull);
    });

    test('invalid email emits emailError', () async {
      _fillValidFields(registerBloc, email: 'not-an-email');
      await Future.delayed(Duration.zero);

      registerBloc.add(const RegisterSubmitted());
      await Future.delayed(Duration.zero);

      expect(registerBloc.state.emailError, isNotNull);
    });

    test('short password emits passwordError', () async {
      _fillValidFields(registerBloc, password: 'abc');
      await Future.delayed(Duration.zero);

      registerBloc.add(const RegisterSubmitted());
      await Future.delayed(Duration.zero);

      expect(registerBloc.state.passwordError, isNotNull);
    });
  });

  group('RegisterSubmitted — success', () {
    test('calls authManager.register with correct trimmed values', () async {
      when(
        mockAuthManager.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
        ),
      ).thenAnswer((_) async => const Ok(null));

      _fillValidFields(registerBloc);
      await Future.delayed(Duration.zero);

      registerBloc.add(const RegisterSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      verify(
        mockAuthManager.register(
          email: 'ali@example.com',
          password: 'password123',
          firstName: 'Ali',
          lastName: 'Veli',
        ),
      ).called(1);
    });

    test('emits isSuccess: true on successful registration', () async {
      when(
        mockAuthManager.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
        ),
      ).thenAnswer((_) async => const Ok(null));

      _fillValidFields(registerBloc);
      await Future.delayed(Duration.zero);

      registerBloc.add(const RegisterSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(registerBloc.state.isSuccess, true);
      expect(registerBloc.state.isLoading, false);
    });
  });

  group('RegisterSubmitted — error', () {
    test('emits errorMessage on register failure', () async {
      when(
        mockAuthManager.register(
          email: anyNamed('email'),
          password: anyNamed('password'),
          firstName: anyNamed('firstName'),
          lastName: anyNamed('lastName'),
        ),
      ).thenAnswer(
        (_) async => Err(ApiError(message: 'Bu e-posta zaten kullanılıyor')),
      );

      _fillValidFields(registerBloc);
      await Future.delayed(Duration.zero);

      registerBloc.add(const RegisterSubmitted());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(registerBloc.state.errorMessage, 'Bu e-posta zaten kullanılıyor');
      expect(registerBloc.state.isLoading, false);
      expect(registerBloc.state.isSuccess, false);
    });
  });

  group('RegisterState', () {
    test('copyWith updates firstName without affecting other fields', () {
      const state = RegisterState(firstName: 'Old', isSuccess: true);
      final updated = state.copyWith(firstName: 'New');
      expect(updated.firstName, 'New');
      expect(updated.isSuccess, true);
    });

    test('copyWith with null firstNameError clears the error', () {
      const state = RegisterState(firstNameError: 'Hata');
      final updated = state.copyWith(firstNameError: null);
      expect(updated.firstNameError, isNull);
    });
  });
}

void _fillValidFields(
  RegisterBloc bloc, {
  String firstName = 'Ali',
  String lastName = 'Veli',
  String email = 'ali@example.com',
  String password = 'password123',
}) {
  bloc
    ..add(RegisterFirstNameChanged(firstName))
    ..add(RegisterLastNameChanged(lastName))
    ..add(RegisterEmailChanged(email))
    ..add(RegisterPasswordChanged(password));
}
