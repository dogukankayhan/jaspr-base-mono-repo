import 'package:kit_core/base_bloc/base_state.dart';

const _omit = Object();

class RegisterState extends BaseState {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? firstNameError;
  final String? lastNameError;
  final String? emailError;
  final String? passwordError;
  final bool isSuccess;

  const RegisterState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.firstNameError,
    this.lastNameError,
    this.emailError,
    this.passwordError,
    this.isSuccess = false,
    super.isLoading,
    super.errorMessage,
  });

  RegisterState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    Object? firstNameError = _omit,
    Object? lastNameError = _omit,
    Object? emailError = _omit,
    Object? passwordError = _omit,
    bool? isSuccess,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RegisterState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      firstNameError: identical(firstNameError, _omit)
          ? this.firstNameError
          : firstNameError as String?,
      lastNameError: identical(lastNameError, _omit)
          ? this.lastNameError
          : lastNameError as String?,
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
    firstName,
    lastName,
    email,
    password,
    firstNameError,
    lastNameError,
    emailError,
    passwordError,
    isSuccess,
  ];
}
