import '../../domain/entity/password_reset_entity.dart';

class PasswordResetStartRequestDto {
  final String email;
  const PasswordResetStartRequestDto({required this.email});

  factory PasswordResetStartRequestDto.fromEntity(
    PasswordResetStartRequest e,
  ) => PasswordResetStartRequestDto(email: e.email);
}

class PasswordResetVerifyRequestDto {
  final String email;
  final String code;
  const PasswordResetVerifyRequestDto({
    required this.email,
    required this.code,
  });

  factory PasswordResetVerifyRequestDto.fromEntity(
    PasswordResetVerifyRequest e,
  ) => PasswordResetVerifyRequestDto(email: e.email, code: e.code);
}

class PasswordResetCompleteRequestDto {
  final String email;
  final String code;
  final String newPassword;
  const PasswordResetCompleteRequestDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  factory PasswordResetCompleteRequestDto.fromEntity(
    PasswordResetCompleteRequest e,
  ) => PasswordResetCompleteRequestDto(
    email: e.email,
    code: e.code,
    newPassword: e.newPassword,
  );
}
