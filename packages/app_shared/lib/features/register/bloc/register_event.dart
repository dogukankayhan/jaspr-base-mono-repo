import 'package:equatable/equatable.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterFirstNameChanged extends RegisterEvent {
  final String firstName;
  const RegisterFirstNameChanged(this.firstName);

  @override
  List<Object?> get props => [firstName];
}

class RegisterLastNameChanged extends RegisterEvent {
  final String lastName;
  const RegisterLastNameChanged(this.lastName);

  @override
  List<Object?> get props => [lastName];
}

class RegisterEmailChanged extends RegisterEvent {
  final String email;
  const RegisterEmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;
  const RegisterPasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}
