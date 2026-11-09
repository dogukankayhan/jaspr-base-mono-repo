class ApiError {
  final int? statusCode;
  final String message;
  final String? code;
  final String? key; // server-specific error key
  final dynamic raw;

  /// How long the server asked the caller to wait before trying again, read
  /// off the `Retry-After` response header. Null when the header was absent
  /// or unparseable — which is every response that is not a rate limit.
  ///
  /// Only a caller that retries on its own needs this; [message] already
  /// carries what a user would be shown.
  final Duration? retryAfter;

  ApiError({
    this.statusCode,
    required this.message,
    this.code,
    this.key,
    this.raw,
    this.retryAfter,
  });

  @override
  String toString() =>
      'ApiError(statusCode: $statusCode, code: $code, key: $key, message: $message)';
}
