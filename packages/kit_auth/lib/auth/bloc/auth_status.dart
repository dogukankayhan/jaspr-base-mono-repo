import '../domain/entity/profile_entity.dart';

sealed class AuthStatus {
  const AuthStatus();
}

class AuthAuthenticated extends AuthStatus {
  final Profile profile;
  const AuthAuthenticated(this.profile);
}

class AuthUnauthenticated extends AuthStatus {
  const AuthUnauthenticated();
}
