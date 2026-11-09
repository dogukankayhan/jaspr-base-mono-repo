import 'package:dio/dio.dart';
import 'api_manager_interface.dart';
import '../client/http_client_interface.dart';
import '../error/error_mapper.dart';
import '../error/api_exception.dart';
import '../interceptors/cache_interceptor.dart';
import '../serializer/serializer_interface.dart';
import '../queue/request_queue.dart';
import '../analytics/analytics_manager.dart';
import 'api_response.dart';

/// Enhanced API Manager with smart parsing and advanced features
class DioApiManager implements ApiManager {
  final HttpClient client;
  final Serializer serializer;
  final RequestQueue? requestQueue;
  final AnalyticsManager? analyticsManager;

  DioApiManager({
    required this.client,
    required this.serializer,
    this.requestQueue,
    this.analyticsManager,
  });

  /// Main request handler with smart parsing and analytics
  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    final startTime = DateTime.now();

    try {
      // Track request start
      analyticsManager?.trackRequestStart(path, method);

      // Execute request (with queue if available)
      final response = requestQueue != null
          ? await requestQueue!.enqueue(
              () => _executeRequest(
                method: method,
                path: path,
                body: body,
                query: query,
                headers: headers,
                cancelToken: cancelToken,
              ),
              priority: priority,
            )
          : await _executeRequest(
              method: method,
              path: path,
              body: body,
              query: query,
              headers: headers,
              cancelToken: cancelToken,
            );

      // Parse response data
      final T data = _parseResponseData<T>(
        response.data,
        fromJson: fromJson,
        extractor: extractor,
        listWrapperKey: listWrapperKey,
      );

      final apiResponse = ApiResponse<T>(
        data: data,
        statusCode: response.statusCode,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        requestUri: response.requestOptions.uri.toString(),
        raw: response.data,
      );

      // Track success
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestSuccess(path, method, duration);

      return apiResponse;
    } on DioException catch (e) {
      // Track failure
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestFailure(path, method, duration, e);

      throw ApiException(ErrorMapper.fromDio(e));
    } catch (e) {
      // Track unexpected error
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestError(path, method, duration, e);

      rethrow;
    }
  }

  /// Execute HTTP request
  Future<Response<Object>> _executeRequest({
    required String method,
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    return await client.dio.request<Object>(
      path,
      data: body,
      queryParameters: query,
      options: Options(method: method, headers: headers),
      cancelToken: cancelToken,
    );
  }

  /// Smart response data parser
  ///
  /// Automatically handles:
  /// - Single models
  /// - Lists of models
  /// - Wrapped lists (with auto-detection)
  /// - Custom extraction
  T _parseResponseData<T>(
    Object? responseData, {
    FromJson<dynamic>? fromJson,
    T Function(Object?)? extractor,
    String? listWrapperKey,
  }) {
    // Priority 1: Custom extractor
    if (extractor != null) {
      return extractor(responseData);
    }

    // Priority 2: No parsing needed
    if (fromJson == null) {
      return responseData as T;
    }

    // Priority 3: Smart parsing based on type
    final typeString = T.toString();
    final isListType = typeString.startsWith('List<');

    if (isListType) {
      return _parseListResponse<T>(
        responseData,
        fromJson,
        listWrapperKey: listWrapperKey,
      );
    } else {
      return _parseSingleResponse<T>(responseData, fromJson);
    }
  }

  /// Parse single model response
  T _parseSingleResponse<T>(Object? responseData, FromJson<dynamic> fromJson) {
    if (responseData is! Map<String, dynamic>) {
      throw ApiException.parse(
        'Expected Map<String, dynamic> for single model, got ${responseData.runtimeType}',
      );
    }

    // Cast FromJson<dynamic> to FromJson<T>
    return serializer.decode<T>(responseData, fromJson as FromJson<T>);
  }

  /// Parse list response with smart wrapper detection
  ///
  /// Supports:
  /// - Direct arrays: [item1, item2, ...]
  /// - Wrapped arrays: { results: [item1, item2, ...] }
  /// - Pagination wrappers: { data: [...], meta: {...} }
  T _parseListResponse<T>(
    Object? responseData,
    FromJson<dynamic> fromJson, {
    String? listWrapperKey,
  }) {
    List<dynamic> listData;

    if (responseData is Map<String, dynamic>) {
      // Try explicit wrapper key first
      if (listWrapperKey != null) {
        if (!responseData.containsKey(listWrapperKey)) {
          throw ApiException.parse(
            'Wrapper key "$listWrapperKey" not found in response. '
            'Available keys: ${responseData.keys.join(", ")}',
          );
        }

        final wrapped = responseData[listWrapperKey];
        if (wrapped is! List) {
          throw ApiException.parse(
            'Expected List at key "$listWrapperKey", got ${wrapped.runtimeType}',
          );
        }

        listData = wrapped;
      } else {
        // Auto-detect wrapper key
        final detectedKey = _detectListWrapperKey(responseData);

        if (detectedKey != null) {
          listData = responseData[detectedKey] as List;
        } else {
          throw ApiException.parse(
            'Could not detect list wrapper key in response. '
            'Available keys: ${responseData.keys.join(", ")}. '
            'Please provide listWrapperKey explicitly.',
          );
        }
      }
    } else if (responseData is List) {
      // Direct array response
      listData = responseData;
    } else {
      throw ApiException.parse(
        'Expected List or Map with list wrapper, got ${responseData.runtimeType}',
      );
    }

    // Parse list items – map individually to preserve concrete type
    final parsedList = listData
        .map((e) => fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    // `fromJson` is typed `FromJson<dynamic>`, so `.map().toList()` above
    // always reifies as `List<dynamic>` regardless of what the elements
    // actually are at runtime — Dart can't recover the element type from
    // `T` (e.g. `List<UserDto>`) since generic type arguments aren't
    // destructurable at runtime without codegen/mirrors. `parsedList as T`
    // therefore always throws for any concrete element type. Fail with a
    // clear, actionable message instead of a confusing TypeError, and
    // point callers at `sendRequest<ElementType, List<ElementType>>(...)`,
    // which keeps the element type as its own generic parameter and does
    // not hit this limitation.
    try {
      return parsedList as T;
    } on TypeError {
      throw ApiException.parse(
        'get<$T>() cannot reify a typed list at runtime (only get<List<dynamic>>() '
        'is safe here). Use sendRequest<ElementType, $T>(fromJson: ..., '
        'method: RequestMethod.get) instead for typed list responses.',
      );
    }
  }

  /// Auto-detect common list wrapper keys
  ///
  /// Checks in priority order:
  /// 1. 'data' - Most common in REST APIs
  /// 2. 'results' - Django, PokeAPI style
  /// 3. 'items' - Common alternative
  /// 4. 'list' - Simple naming
  /// 5. 'content' - Spring Boot style
  /// 6. First key that contains a List
  String? _detectListWrapperKey(Map<String, dynamic> map) {
    // Priority keys
    const priorityKeys = ['data', 'results', 'items', 'list', 'content'];

    for (final key in priorityKeys) {
      if (map.containsKey(key) && map[key] is List) {
        return key;
      }
    }

    // Fallback: find any key with List value
    for (final entry in map.entries) {
      if (entry.value is List) {
        return entry.key;
      }
    }

    return null;
  }

  @override
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'GET',
      path: path,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'POST',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'PUT',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'PATCH',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>({
    required String path,
    Object? body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) {
    return _request<T>(
      method: 'DELETE',
      path: path,
      body: body,
      query: query,
      headers: headers,
      cancelToken: cancelToken,
      fromJson: fromJson,
      listWrapperKey: listWrapperKey,
      extractor: extractor,
      priority: priority,
    );
  }

  @override
  Future<ApiResponse<R>> sendRequest<T, R>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    required RequestMethod method,
    Map<String, dynamic>? queryParameters,
    Object? data,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    String? listWrapperKey,
    R Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  }) async {
    final httpMethod = method.httpValue;
    final startTime = DateTime.now();
    try {
      analyticsManager?.trackRequestStart(path, httpMethod);
      final response = requestQueue != null
          ? await requestQueue!.enqueue(
              () => _executeRequest(
                method: httpMethod,
                path: path,
                body: data,
                query: queryParameters,
                headers: headers,
                cancelToken: cancelToken,
              ),
              priority: priority,
            )
          : await _executeRequest(
              method: httpMethod,
              path: path,
              body: data,
              query: queryParameters,
              headers: headers,
              cancelToken: cancelToken,
            );

      final R parsed;
      if (extractor != null) {
        parsed = extractor(response.data);
      } else if (<T>[] is R) {
        parsed =
            _bodyParser<T>(
                  response.data,
                  fromJson,
                  listWrapperKey: listWrapperKey,
                )
                as R;
      } else {
        final raw = _extractMap(response.data);
        parsed = fromJson(raw) as R;
      }

      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestSuccess(path, httpMethod, duration);
      return ApiResponse<R>(
        data: parsed,
        statusCode: response.statusCode,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        requestUri: response.requestOptions.uri.toString(),
        raw: response.data,
      );
    } on DioException catch (e) {
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestFailure(path, httpMethod, duration, e);
      throw ApiException(ErrorMapper.fromDio(e));
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      analyticsManager?.trackRequestError(path, httpMethod, duration, e);
      rethrow;
    }
  }

  List<T> _bodyParser<T>(
    dynamic responseBody,
    T Function(Map<String, dynamic>) fromJson, {
    String? listWrapperKey,
  }) {
    try {
      dynamic raw = responseBody;
      if (raw is Map<String, dynamic>) {
        raw = listWrapperKey != null ? raw[listWrapperKey] : raw['data'] ?? raw;
      }
      if (raw is! List) {
        throw ApiException.parse('Expected List, got ${raw.runtimeType}');
      }
      return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
    } on ApiException {
      rethrow;
    } catch (e, st) {
      throw ApiException.parse('Body parse error: $e\n$st');
    }
  }

  Map<String, dynamic> _extractMap(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      return (responseBody['data'] as Map<String, dynamic>?) ?? responseBody;
    }
    throw ApiException.parse('Expected Map, got ${responseBody.runtimeType}');
  }

  @override
  Future<ApiResponse<T>> upload<T>({
    required String path,
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? fields,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
  }) async {
    // Path parsing instead of dart:io's File, so this compiles for the web
    // too. (MultipartFile.fromFile itself is IO-only; on the web pass bytes.)
    final fileName = filePath.split(RegExp(r'[/\\]')).last;

    final formData = FormData.fromMap({
      fileKey: await MultipartFile.fromFile(filePath, filename: fileName),
      ...?fields,
    });

    try {
      final response = await client.dio.post<Object>(
        path,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      final T data = fromJson != null
          ? serializer.decode<T>(response.data, fromJson as FromJson<T>)
          : response.data as T;

      return ApiResponse<T>(
        data: data,
        statusCode: response.statusCode,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
        requestUri: response.requestOptions.uri.toString(),
        raw: response.data,
      );
    } on DioException catch (e) {
      throw ApiException(ErrorMapper.fromDio(e));
    }
  }

  @override
  Future<String> download({
    required String path,
    required String savePath,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await client.dio.download(
        path,
        savePath,
        queryParameters: query,
        options: Options(headers: headers),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return savePath;
    } on DioException catch (e) {
      throw ApiException(ErrorMapper.fromDio(e));
    }
  }

  @override
  Future<List<int>> getBytes({
    required String path,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await client.dio.get<List<int>>(
        path,
        queryParameters: query,
        options: Options(headers: headers, responseType: ResponseType.bytes),
        cancelToken: cancelToken,
      );
      return response.data ?? const [];
    } on DioException catch (e) {
      throw ApiException(ErrorMapper.fromDio(e));
    }
  }

  @override
  void invalidateCache(String path) {
    for (final interceptor in client.dio.interceptors) {
      if (interceptor is CacheInterceptor) {
        interceptor.removeCacheEntry(path);
      }
    }
  }
}
