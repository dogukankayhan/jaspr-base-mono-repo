import 'package:bloc/bloc.dart';
import 'package:kit_auth/auth/manager/auth_manager.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_core/utils/validator/validator.dart';
import 'package:kit_network/core/di/locator.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends BaseBloc<RegisterEvent, RegisterState> {
  final AuthManager _authManager;

  static final _requiredValidator = FieldValidator<String>([
    Validators.required(message: 'Bu alan zorunludur'),
  ]);

  static final _emailValidator = FieldValidator<String>([
    Validators.required(message: 'Lütfen e-posta girin'),
    Validators.email(message: 'Geçersiz e-posta formatı'),
  ]);

  static final _passwordValidator = FieldValidator<String>([
    Validators.required(message: 'Lütfen şifre girin'),
    Validators.minLength(6, message: 'En az 6 karakter olmalıdır'),
  ]);

  RegisterBloc({AuthManager? authManager})
    : _authManager = authManager ?? getIt<AuthManager>(),
      super(const RegisterState()) {
    on<RegisterFirstNameChanged>(_onFirstNameChanged);
    on<RegisterLastNameChanged>(_onLastNameChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }

  void _onFirstNameChanged(
    RegisterFirstNameChanged event,
    Emitter<RegisterState> emit,
  ) => emit(
    state.copyWith(
      firstName: event.firstName,
      firstNameError: null,
      errorMessage: null,
    ),
  );

  void _onLastNameChanged(
    RegisterLastNameChanged event,
    Emitter<RegisterState> emit,
  ) => emit(
    state.copyWith(
      lastName: event.lastName,
      lastNameError: null,
      errorMessage: null,
    ),
  );

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) => emit(
    state.copyWith(email: event.email, emailError: null, errorMessage: null),
  );

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) => emit(
    state.copyWith(
      password: event.password,
      passwordError: null,
      errorMessage: null,
    ),
  );

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    final firstNameError = _requiredValidator.validate(state.firstName);
    final lastNameError = _requiredValidator.validate(state.lastName);
    final emailError = _emailValidator.validate(state.email);
    final passwordError = _passwordValidator.validate(state.password);

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        passwordError != null) {
      emit(
        state.copyWith(
          firstNameError: firstNameError,
          lastNameError: lastNameError,
          emailError: emailError,
          passwordError: passwordError,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _authManager.register(
        email: state.email.trim(),
        password: state.password,
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
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
