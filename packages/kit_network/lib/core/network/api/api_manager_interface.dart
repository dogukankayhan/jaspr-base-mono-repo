import 'package:dio/dio.dart';
import '../serializer/serializer_interface.dart';
import 'api_response.dart';

/// Main API Manager interface with smart parsing capabilities
///
/// This interface provides type-safe HTTP methods with automatic
/// list parsing, wrapper detection, and pagination support.
///
/// Example usage:
/// ```dart
/// // Single model
/// final user = await api.get<User>(
///   path: 'users/123',
///   fromJson: User.fromJson,
/// );
/// ```
///
/// **For list responses, use [sendRequest] instead of [get], e.g.
/// `sendRequest<User, List<User>>(...)`.** [get]'s single type parameter
/// can't carry the list's element type separately from the list type
/// itself, so `get<List<T>>()` cannot reify a properly-typed list at
/// runtime — it throws a clear [ApiException] pointing back here rather
/// than parsing successfully. Only `get<List<dynamic>>()` (no `fromJson`)
/// is actually safe through this method.
abstract class ApiManager {
  /// GET request with smart parsing
  ///
  // ignore: unintended_html_in_doc_comment
  /// - [T]: Return type for a single model. **Do not use `List<Model>`
  ///   here** — see the class-level doc for why; use [sendRequest] for
  ///   list responses instead.
  /// - [path]: API endpoint path
  /// - [query]: Query parameters
  /// - [headers]: Additional headers
  /// - [cancelToken]: Cancellation token
  /// - [fromJson]: JSON decoder function for the MODEL (not list!)
  /// - [listWrapperKey]: unused unless you deliberately call this with a
  ///   `List<...>` type param and accept the resulting [ApiException]
  /// - [extractor]: Custom data extraction (overrides fromJson)
  /// - [priority]: Request priority (default: normal)
  Future<ApiResponse<T>> get<T>({
    required String path,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
    String? listWrapperKey,
    T Function(Object?)? extractor,
    RequestPriority priority = RequestPriority.normal,
  });

  /// POST request with smart parsing
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
  });

  /// PUT request with smart parsing
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
  });

  /// PATCH request with smart parsing
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
  });

  /// DELETE request with smart parsing
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
  });

  /// Unified type-safe request for both list and single responses.
  ///
  /// Set [R] to `List<T>` for list responses, or to `T` for single-object
  /// responses — the manager infers which path to take at runtime via [fromJson].
  ///
  /// ```dart
  /// // list
  /// sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
  ///   'pokemon',
  ///   fromJson: PokemonBriefDto.fromJson,
  ///   method: RequestMethod.get,
  ///   listWrapperKey: 'results',
  /// );
  ///
  /// // single
  /// sendRequest<PokemonSpeciesDto, PokemonSpeciesDto>(
  ///   'pokemon-species/1',
  ///   fromJson: PokemonSpeciesDto.fromJson,
  ///   method: RequestMethod.get,
  /// );
  /// ```
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
  });

  /// Upload file with progress tracking
  Future<ApiResponse<T>> upload<T>({
    required String path,
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? fields,
    Map<String, String>? headers,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    FromJson<dynamic>? fromJson,
  });

  /// Download file with progress tracking
  Future<String> download({
    required String path,
    required String savePath,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  });

  /// GET request returning raw response bytes (e.g. an authenticated image
  /// endpoint) instead of parsing the body as JSON.
  Future<List<int>> getBytes({
    required String path,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  });

  /// Evicts cached GET response(s) whose composed cache key contains [path]
  /// — call after a mutating request (create/update/delete) makes a
  /// previously-cached GET stale. No-op if caching is disabled or nothing
  /// matches.
  void invalidateCache(String path);
}

/// Request priority levels for queue management
enum RequestPriority {
  low(0),
  normal(1),
  high(2),
  critical(3);

  final int value;
  const RequestPriority(this.value);
}

/// HTTP method for [ApiManager.sendRequest]
enum RequestMethod {
  get,
  post,
  put,
  patch,
  delete;

  String get httpValue => name.toUpperCase();
}
