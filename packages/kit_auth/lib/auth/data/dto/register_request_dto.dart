import '../../domain/entity/auth_entity.dart';

class RegisterRequestDto {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? fcmToken;

  const RegisterRequestDto({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.fcmToken,
  });

  factory RegisterRequestDto.fromEntity(RegisterRequest e) =>
      RegisterRequestDto(
        email: e.email,
        password: e.password,
        firstName: e.firstName,
        lastName: e.lastName,
        fcmToken: e.fcmToken,
      );
}
