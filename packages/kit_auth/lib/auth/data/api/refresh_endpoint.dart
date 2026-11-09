import '../dto/refresh_request_dto.dart';

abstract final class RefreshEndpoint {
  static const path = '/auth/refresh';

  static Map<String, dynamic> body(RefreshRequestDto dto) => {
    'refreshToken': dto.refreshToken,
  };
}
