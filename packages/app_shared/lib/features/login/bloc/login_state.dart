import 'package:kit_core/base_bloc/base_state.dart';

const _omit = Object();

class LoginState extends BaseState {
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final bool isSuccess;

  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.isSuccess = false,
    super.isLoading,
    super.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    Object? emailError = _omit,
    Object? passwordError = _omit,
    bool? isSuccess,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: identical(emailError, _omit)
          ? this.emailError
          : emailError as String?,
      passwordError: identical(passwordError, _omit)
          ? this.passwordError
          : passwordError as String?,
      isSuccess: isSuccess ?? this.isSuccess,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    email,
    password,
    emailError,
    passwordError,
    isSuccess,
  ];
}
