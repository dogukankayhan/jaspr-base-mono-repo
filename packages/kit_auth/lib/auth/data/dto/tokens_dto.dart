import '../../domain/entity/auth_entity.dart';

class TokensDto {
  final String accessToken;
  final String? refreshToken;

  const TokensDto({required this.accessToken, this.refreshToken});

  factory TokensDto.fromJson(Map<String, dynamic> json) => TokensDto(
    accessToken:
        json['accessToken'] as String? ?? json['access_token'] as String? ?? '',
    refreshToken:
        json['refreshToken'] as String? ?? json['refresh_token'] as String?,
  );
}

extension TokensDtoX on TokensDto {
  AuthTokens toDomain() =>
      AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
}
