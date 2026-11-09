import 'api_error.dart';
import 'error_messages.dart';

/// Enhanced API Exception with i18n support
class ApiException implements Exception {
  final ApiError error;
  final String? locale;
  final ErrorMessages? _errorMessages;

  ApiException(this.error, {this.locale})
    : _errorMessages = locale != null ? ErrorMessages(locale: locale) : null;

  /// Create parse exception
  factory ApiException.parse(String message, {String? locale}) {
    return ApiException(
      ApiError(statusCode: null, message: message, code: 'PARSE_ERROR'),
      locale: locale,
    );
  }

  /// Create network exception
  factory ApiException.network(String message, {String? locale}) {
    return ApiException(
      ApiError(statusCode: null, message: message, code: 'NETWORK_ERROR'),
      locale: locale,
    );
  }

  /// Create timeout exception
  factory ApiException.timeout({String? locale}) {
    final messages = ErrorMessages(locale: locale ?? 'en_US');
    return ApiException(
      ApiError(
        statusCode: 408,
        message: messages.connectionTimeout,
        code: 'TIMEOUT',
      ),
      locale: locale,
    );
  }

  /// Create unauthorized exception
  factory ApiException.unauthorized({String? locale}) {
    final messages = ErrorMessages(locale: locale ?? 'en_US');
    return ApiException(
      ApiError(
        statusCode: 401,
        message: messages.unauthorized,
        code: 'UNAUTHORIZED',
      ),
      locale: locale,
    );
  }

  /// Create not found exception
  factory ApiException.notFound({String? locale}) {
    final messages = ErrorMessages(locale: locale ?? 'en_US');
    return ApiException(
      ApiError(statusCode: 404, message: messages.notFound, code: 'NOT_FOUND'),
      locale: locale,
    );
  }

  /// Create rate limit exception
  factory ApiException.rateLimit({String? locale, Duration? retryAfter}) {
    final messages = ErrorMessages(locale: locale ?? 'en_US');
    return ApiException(
      ApiError(
        statusCode: 429,
        message: messages.rateLimitExceeded,
        code: 'RATE_LIMIT',
        raw: retryAfter != null ? {'retry_after': retryAfter.inSeconds} : null,
      ),
      locale: locale,
    );
  }

  /// Get localized message
  String get localizedMessage {
    if (_errorMessages == null) return error.message;

    final messages = _errorMessages;

    // Map status codes to localized messages
    switch (error.statusCode) {
      case 400:
        return messages.badRequest;
      case 401:
        return messages.unauthorized;
      case 403:
        return messages.forbidden;
      case 404:
        return messages.notFound;
      case 405:
        return messages.methodNotAllowed;
      case 408:
        return messages.requestTimeout;
      case 409:
        return messages.conflict;
      case 429:
        return messages.rateLimitExceeded;
      case 500:
        return messages.internalServerError;
      case 503:
        return messages.serviceUnavailable;
      default:
        if (error.code == 'PARSE_ERROR') {
          return messages.parseError;
        } else if (error.code == 'NETWORK_ERROR') {
          return messages.networkError;
        }
        return error.message;
    }
  }

  /// Check if error is retryable
  bool get isRetryable {
    return error.statusCode == null || // Network errors
        error.statusCode! >= 500 || // Server errors
        error.statusCode == 408 || // Timeout
        error.statusCode == 429; // Rate limit
  }

  /// Check if error is authentication related
  bool get isAuthError {
    return error.statusCode == 401 || error.statusCode == 403;
  }

  /// Check if error is client error (4xx)
  bool get isClientError {
    return error.statusCode != null &&
        error.statusCode! >= 400 &&
        error.statusCode! < 500;
  }

  /// Check if error is server error (5xx)
  bool get isServerError {
    return error.statusCode != null && error.statusCode! >= 500;
  }

  /// Get retry after duration for rate limit errors
  Duration? get retryAfter {
    if (error.code != 'RATE_LIMIT') return null;

    final raw = error.raw;
    if (raw is Map && raw.containsKey('retry_after')) {
      final seconds = raw['retry_after'];
      return Duration(seconds: seconds is int ? seconds : 0);
    }

    return null;
  }

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: ');

    if (error.statusCode != null) {
      buffer.write('[${error.statusCode}] ');
    }

    if (error.code != null) {
      buffer.write('[${error.code}] ');
    }

    buffer.write(localizedMessage);

    return buffer.toString();
  }

  /// Convert to JSON for logging
  Map<String, dynamic> toJson() => {
    'statusCode': error.statusCode,
    'message': localizedMessage,
    'originalMessage': error.message,
    'code': error.code,
    'key': error.key,
    'isRetryable': isRetryable,
    'isAuthError': isAuthError,
    'raw': error.raw,
  };
}
