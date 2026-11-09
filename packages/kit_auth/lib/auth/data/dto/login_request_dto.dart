import '../../domain/entity/auth_entity.dart';

class LoginRequestDto {
  final String email;
  final String password;
  final String? fcmToken;

  const LoginRequestDto({
    required this.email,
    required this.password,
    this.fcmToken,
  });

  factory LoginRequestDto.fromEntity(LoginRequest e) => LoginRequestDto(
    email: e.email,
    password: e.password,
    fcmToken: e.fcmToken,
  );
}
