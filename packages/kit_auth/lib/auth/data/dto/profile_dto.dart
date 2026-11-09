import '../../domain/entity/profile_entity.dart';

class ProfileDto {
  final String id;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final int coinCount;
  final String? about;

  ProfileDto({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.coinCount = 0,
    this.about,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) => ProfileDto(
    id: (json['id'] ?? json['_id'] ?? json['userId']).toString(),
    email: json['email']?.toString(),
    firstName: json['firstName']?.toString(),
    lastName: json['lastName']?.toString(),
    avatarUrl: json['avatar']?.toString() ?? json['avatarUrl']?.toString(),
    coinCount: switch (json['coinCount']) {
      final int v => v,
      final String v => int.tryParse(v) ?? 0,
      _ => 0,
    },
    about: json['about']?.toString(),
  );
}

extension ProfileDtoX on ProfileDto {
  Profile toDomain() => Profile(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    avatarUrl: avatarUrl,
    coinCount: coinCount,
    about: about,
  );
}
