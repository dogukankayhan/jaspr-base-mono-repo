import 'package:bloc/bloc.dart';
import 'package:kit_auth/auth/manager/auth_manager.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_core/utils/validator/validator.dart';
import 'package:kit_network/core/di/locator.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends BaseBloc<LoginEvent, LoginState> {
  final AuthManager _authManager;

  static final _emailValidator = FieldValidator<String>([
    Validators.required(message: 'Lütfen e-posta girin'),
    Validators.email(message: 'Geçersiz e-posta formatı'),
  ]);

  static final _passwordValidator = FieldValidator<String>([
    Validators.required(message: 'Lütfen şifre girin'),
    Validators.minLength(6, message: 'Şifre en az 6 karakter olmalıdır'),
  ]);

  LoginBloc({AuthManager? authManager})
    : _authManager = authManager ?? getIt<AuthManager>(),
      super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginDemoFillRequested>(_onDemoFillRequested);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(email: event.email, emailError: null, errorMessage: null),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        password: event.password,
        passwordError: null,
        errorMessage: null,
      ),
    );
  }

  void _onDemoFillRequested(
    LoginDemoFillRequested event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(
        email: 'john.doe@example.com',
        password: 'password123',
        emailError: null,
        passwordError: null,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final emailError = _emailValidator.validate(state.email);
    final passwordError = _passwordValidator.validate(state.password);

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(emailError: emailError, passwordError: passwordError),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _authManager.login(
        state.email.trim(),
        state.password,
      );
      result.when(
        ok: (_) => emit(state.copyWith(isLoading: false, isSuccess: true)),
        err: (error) =>
            emit(state.copyWith(isLoading: false, errorMessage: error.message)),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
