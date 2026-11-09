import '../../domain/enum/social_auth_provider.dart';
import '../dto/social_sign_in_request_dto.dart';

abstract final class SocialSignInEndpoint {
  /// One path per provider (`/auth/apple`, `/auth/google`) — the provider
  /// picks the path, everything else about the request is identical.
  static String path(SocialSignInRequestDto dto) => '/auth/${dto.provider.key}';

  static Map<String, dynamic> body(SocialSignInRequestDto dto) => {
    'idToken': dto.idToken,
    'fcmToken': ?dto.fcmToken,
  };
}
