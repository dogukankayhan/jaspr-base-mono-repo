import '../network/api/api_response.dart';

extension ApiResponseExtension<T> on ApiResponse<T> {
  /// Check if response is successful
  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Check if response is client error (4xx)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  /// Check if response is server error (5xx)
  bool get isServerError =>
      statusCode != null && statusCode! >= 500 && statusCode! < 600;

  /// Get header value
  String? header(String key) => headers?[key];

  /// Map response data to another type
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    return ApiResponse<R>(
      data: mapper(data),
      statusCode: statusCode,
      headers: headers,
      requestUri: requestUri,
      raw: raw,
    );
  }
}
