import '../dto/password_reset_request_dto.dart';

abstract final class PasswordResetStartEndpoint {
  static const path = '/auth/password-reset/start';

  static Map<String, dynamic> body(PasswordResetStartRequestDto dto) => {
    'email': dto.email,
  };
}

abstract final class PasswordResetVerifyEndpoint {
  static const path = '/auth/password-reset/verify';

  static Map<String, dynamic> body(PasswordResetVerifyRequestDto dto) => {
    'email': dto.email,
    'code': dto.code,
  };
}

abstract final class PasswordResetCompleteEndpoint {
  static const path = '/auth/password-reset/complete';

  static Map<String, dynamic> body(PasswordResetCompleteRequestDto dto) => {
    'email': dto.email,
    'code': dto.code,
    'newPassword': dto.newPassword,
  };
}
