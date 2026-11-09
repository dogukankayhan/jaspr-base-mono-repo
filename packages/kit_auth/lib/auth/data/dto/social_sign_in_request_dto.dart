import '../../domain/entity/auth_entity.dart';
import '../../domain/enum/social_auth_provider.dart';

class SocialSignInRequestDto {
  final SocialAuthProvider provider;
  final String idToken;
  final String? fcmToken;

  const SocialSignInRequestDto({
    required this.provider,
    required this.idToken,
    this.fcmToken,
  });

  factory SocialSignInRequestDto.fromEntity(SocialSignInRequest e) =>
      SocialSignInRequestDto(
        provider: e.provider,
        idToken: e.idToken,
        fcmToken: e.fcmToken,
      );
}
