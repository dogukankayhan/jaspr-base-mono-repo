import 'package:dio/dio.dart';
import 'api_error.dart';
import 'error_messages.dart';

/// Enhanced error mapper with i18n support
class ErrorMapper {
  /// Map Dio exception to API error
  static ApiError fromDio(DioException e, {String locale = 'en_US'}) {
    final messages = ErrorMessages(locale: locale);
    final status = e.response?.statusCode;
    String message = e.message ?? 'Unknown error';
    String? code;
    String? key;

    // Try to parse server error body
    final data = e.response?.data;
    final hasServerMessage =
        data is Map<String, dynamic> &&
        (data['message']?.toString().isNotEmpty ?? false);
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? message;
      code = data['code']?.toString();
      key = data['key']?.toString();
    }

    // Map Dio exception types to localized messages
    switch (e.type) {
      case DioExceptionType.cancel:
        message = messages.requestCancelled;
        code = 'REQUEST_CANCELLED';
        break;

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        message = messages.connectionTimeout;
        code = 'TIMEOUT';
        break;

      case DioExceptionType.connectionError:
        message = messages.networkError;
        code = 'CONNECTION_ERROR';
        break;

      case DioExceptionType.badResponse:
        if (status != null && !hasServerMessage) {
          message = _getLocalizedMessageForStatus(status, messages) ?? message;
        }
        break;

      case DioExceptionType.badCertificate:
        message = 'Bad certificate'; // Could add to i18n
        code = 'BAD_CERTIFICATE';
        break;

      case DioExceptionType.unknown:
        if (e.error != null && e.error.toString().contains('SocketException')) {
          message = messages.noInternetConnection;
          code = 'NO_INTERNET';
        }
        break;
    }

    return ApiError(
      statusCode: status,
      message: message,
      code: code,
      key: key,
      raw: e.response?.data,
      retryAfter: _retryAfter(e.response),
    );
  }

  /// `Retry-After` in its delay-seconds form. The HTTP-date form is allowed by
  /// the spec but needs a trusted clock to be worth anything, and a rate limit
  /// answered against a skewed device clock would wait for the wrong length —
  /// better to report nothing and let the caller pick its own backoff.
  static Duration? _retryAfter(Response<dynamic>? response) {
    final raw = response?.headers.value('retry-after')?.trim();
    if (raw == null || raw.isEmpty) return null;
    final seconds = int.tryParse(raw);
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }

  /// Get localized message for HTTP status code
  static String? _getLocalizedMessageForStatus(
    int status,
    ErrorMessages messages,
  ) {
    return switch (status) {
      400 => messages.badRequest,
      401 => messages.unauthorized,
      403 => messages.forbidden,
      404 => messages.notFound,
      405 => messages.methodNotAllowed,
      408 => messages.requestTimeout,
      409 => messages.conflict,
      429 => messages.rateLimitExceeded,
      500 => messages.internalServerError,
      503 => messages.serviceUnavailable,
      _ => null,
    };
  }

  /// Map generic exception to API error
  static ApiError fromException(Exception e, {String locale = 'en_US'}) {
    return ApiError(
      statusCode: null,
      message: e.toString(),
      code: 'UNKNOWN_ERROR',
    );
  }
}
