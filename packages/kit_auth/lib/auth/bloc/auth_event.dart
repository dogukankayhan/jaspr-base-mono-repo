import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
