import '../../domain/entity/user_profile.dart';

class UserDto {
  final String firstName;
  final String lastName;
  final String email;

  const UserDto({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    firstName: json['firstName'] as String? ?? '',
    lastName: json['lastName'] as String? ?? '',
    email: json['email'] as String? ?? '',
  );

  UserProfile toDomain() =>
      UserProfile(firstName: firstName, lastName: lastName, email: email);
}
