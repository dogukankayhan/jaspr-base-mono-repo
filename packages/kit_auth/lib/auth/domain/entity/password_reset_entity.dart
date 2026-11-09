import 'package:equatable/equatable.dart';

/// Generic start/verify/complete password-reset flow — a worked example of
/// the Rule 3 endpoint-wiring chain (see CLAUDE.md) that a consuming app can
/// extend with its own fields rather than one it's expected to use as-is.
class PasswordResetStartRequest extends Equatable {
  final String email;
  const PasswordResetStartRequest({required this.email});

  @override
  List<Object?> get props => [email];
}

class PasswordResetVerifyRequest extends Equatable {
  final String email;
  final String code;
  const PasswordResetVerifyRequest({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class PasswordResetCompleteRequest extends Equatable {
  final String email;
  final String code;
  final String newPassword;
  const PasswordResetCompleteRequest({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, code, newPassword];
}
