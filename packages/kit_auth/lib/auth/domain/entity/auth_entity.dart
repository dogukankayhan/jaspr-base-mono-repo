import 'package:equatable/equatable.dart';

import '../enum/social_auth_provider.dart';

class AuthTokens {
  final String accessToken;
  final String? refreshToken;
  const AuthTokens({required this.accessToken, this.refreshToken});
}

class LoginRequest extends Equatable {
  final String email;
  final String password;

  /// Attached when the caller can supply one so the backend can start
  /// sending push notifications right after sign-in — omitted otherwise.
  final String? fcmToken;

  const LoginRequest({
    required this.email,
    required this.password,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [email, password, fcmToken];
}

class RegisterRequest extends Equatable {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? fcmToken;

  const RegisterRequest({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, fcmToken];
}

class SocialSignInRequest extends Equatable {
  final SocialAuthProvider provider;
  final String idToken;
  final String? fcmToken;

  const SocialSignInRequest({
    required this.provider,
    required this.idToken,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [provider, idToken, fcmToken];
}
