class ApiResponse<T> {
  final T data;
  final int? statusCode;
  final Map<String, String>? headers;
  final String? requestUri;
  final dynamic raw;

  ApiResponse({
    required this.data,
    this.statusCode,
    this.headers,
    this.requestUri,
    this.raw,
  });
}
