import '../dto/register_request_dto.dart';

abstract final class RegisterEndpoint {
  static const path = '/auth/register';

  static Map<String, dynamic> body(RegisterRequestDto dto) => {
    'email': dto.email,
    'password': dto.password,
    'firstName': ?dto.firstName,
    'lastName': ?dto.lastName,
    'fcmToken': ?dto.fcmToken,
  };
}
