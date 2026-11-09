abstract final class UpdateProfileEndpoint {
  static const path = '/auth/me';

  /// The patch is already a partial update map by nature — there is no fixed
  /// request shape to wrap it in, so it travels through unchanged.
  static Map<String, dynamic> body(Map<String, dynamic> patch) => patch;
}
