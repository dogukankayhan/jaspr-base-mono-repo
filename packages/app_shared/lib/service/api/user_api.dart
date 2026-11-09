abstract final class GetUserProfileEndpoint {
  static const path = '/user/me';
}

abstract final class UpdateUserProfileEndpoint {
  static const path = '/user/me';
  static Map<String, dynamic> body({
    required String firstName,
    required String lastName,
  }) => {'firstName': firstName, 'lastName': lastName};
}
