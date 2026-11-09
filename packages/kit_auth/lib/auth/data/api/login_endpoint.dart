import '../dto/login_request_dto.dart';

abstract final class LoginEndpoint {
  static const path = '/auth/login';

  static Map<String, dynamic> body(LoginRequestDto dto) => {
    'email': dto.email,
    'password': dto.password,
    'fcmToken': ?dto.fcmToken,
  };
}
