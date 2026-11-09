import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_kit_network/core/network/api/api_manager.dart';
import 'package:flutter_kit_network/core/network/client/http_client_interface.dart';
import 'package:flutter_kit_network/core/network/serializer/serializer_interface.dart';
import 'package:flutter_kit_network/core/network/error/api_exception.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'api_manager_test.mocks.dart';

// Annotations for creating mock classes
@GenerateMocks([HttpClient, Serializer, Dio, Response, RequestOptions, Headers])
void main() {
  late DioApiManager apiManager;
  late MockHttpClient mockHttpClient;
  late MockSerializer mockSerializer;
  late MockDio mockDio;

  setUp(() {
    resetMockitoState();
    provideDummy<TestModel>(TestModel(id: 'dummy', name: 'dummy'));
    mockHttpClient = MockHttpClient();
    mockSerializer = MockSerializer();
    mockDio = MockDio();
    when(mockHttpClient.dio).thenReturn(mockDio);
    apiManager = DioApiManager(
      client: mockHttpClient,
      serializer: mockSerializer,
    );
  });

  group('ApiManager GET Tests', () {
    const testPath = '/api/test';
    final testQueryParams = {'page': '1', 'limit': '10'};
    final testHeaders = {'Authorization': 'Bearer token'};
    final testResponseData = {'id': '123', 'name': 'Test'};

    test('should perform GET request successfully', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockHeaders = Headers();
      mockHeaders.map['content-type'] = ['application/json'];

      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: mockHeaders,
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: testQueryParams,
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<Map<String, dynamic>>(
        path: testPath,
        query: testQueryParams,
        headers: testHeaders,
      );

      // Assert
      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
      verify(
        mockDio.request<Object>(
          testPath,
          queryParameters: testQueryParams,
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).called(1);
    });

    test('should handle GET request with fromJson', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // when decode<TestModel> is called, let's actually use fromJson to produce TestModel
      when(mockSerializer.decode<TestModel>(any, any)).thenAnswer((invocation) {
        final source = invocation.positionalArguments[0];
        final fromJson =
            invocation.positionalArguments[1] as FromJson<TestModel>?;
        return fromJson!((source as Map).cast<String, dynamic>());
      });

      // Act
      final result = await apiManager.get<TestModel>(
        path: testPath,
        // ignore: unnecessary_cast
        fromJson: (json) => TestModel.fromJson(json as Map<String, dynamic>),
      );

      // Assert
      expect(result.statusCode, 200);
      expect(result.data, TestModel(id: '123', name: 'Test'));
      verify(mockSerializer.decode<TestModel>(any, any)).called(1);
    });

    test('should handle GET request with extractor', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: {'data': testResponseData},
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<Map<String, dynamic>>(
        path: testPath,
        extractor: (data) =>
            (data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
      );

      // Assert
      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
    });

    test('should throw ApiException on DioException', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: testPath),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: testPath),
        ),
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenThrow(dioException);

      // Act & Assert
      expect(
        () => apiManager.get<Map<String, dynamic>>(path: testPath),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('ApiManager POST Tests', () {
    const testPath = '/api/test';
    final testBody = {'name': 'Test', 'description': 'Test description'};
    final testResponseData = {'id': '123', 'name': 'Test'};

    test('should perform POST request successfully', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 201,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          data: testBody,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.post<Map<String, dynamic>>(
        path: testPath,
        body: testBody,
      );

      // Assert
      expect(result.data, testResponseData);
      expect(result.statusCode, 201);
      verify(
        mockDio.request<Object>(
          testPath,
          data: testBody,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).called(1);
    });

    test('should perform POST request with query parameters', () async {
      // Arrange
      final testQuery = {'include': 'details'};
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 201,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          data: testBody,
          queryParameters: testQuery,
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.post<Map<String, dynamic>>(
        path: testPath,
        body: testBody,
        query: testQuery,
      );

      // Assert
      expect(result.data, testResponseData);
      expect(result.statusCode, 201);
    });
  });

  group('ApiManager PUT Tests', () {
    const testPath = '/api/test/123';
    final testBody = {'name': 'Updated Test'};
    final testResponseData = {'id': '123', 'name': 'Updated Test'};

    test('should perform PUT request successfully', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          data: testBody,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.put<Map<String, dynamic>>(
        path: testPath,
        body: testBody,
      );

      // Assert
      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
    });
  });

  group('ApiManager PATCH Tests', () {
    const testPath = '/api/test/123';
    final testBody = {'name': 'Patched Test'};
    final testResponseData = {'id': '123', 'name': 'Patched Test'};

    test('should perform PATCH request successfully', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          data: testBody,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.patch<Map<String, dynamic>>(
        path: testPath,
        body: testBody,
      );

      // Assert
      expect(result.data, testResponseData);
      expect(result.statusCode, 200);
    });
  });

  group('ApiManager DELETE Tests', () {
    const testPath = '/api/test/123';

    test('should perform DELETE request successfully', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: null,
        statusCode: 204,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          data: anyNamed('data'),
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.delete<void>(path: testPath);

      // Assert
      expect(result.statusCode, 204);
    });

    test('should perform DELETE request with body', () async {
      // Arrange
      final testBody = {'reason': 'No longer needed'};
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockResponse = Response<Object>(
        data: {'message': 'Deleted successfully'},
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          data: testBody,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.delete<Map<String, dynamic>>(
        path: testPath,
        body: testBody,
      );

      // Assert
      expect(result.data, {'message': 'Deleted successfully'});
      expect(result.statusCode, 200);
    });
  });

  group('ApiManager Response Tests', () {
    const testPath = '/api/test';
    final testResponseData = {'id': '123', 'name': 'Test'};

    test('should include headers in response', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);
      final mockHeaders = Headers();
      mockHeaders.map['content-type'] = ['application/json'];
      mockHeaders.map['x-custom-header'] = ['custom-value'];

      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: mockHeaders,
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<Map<String, dynamic>>(path: testPath);

      // Assert
      expect(result.headers, isNotNull);
      expect(result.headers!['content-type'], 'application/json');
      expect(result.headers!['x-custom-header'], 'custom-value');
    });

    test('should include request URI in response', () async {
      // Arrange
      const testPath = '/api/test';
      const baseUrl = 'https://pokeapi.co/api/v2';
      final expectedUri = Uri.parse('$baseUrl$testPath');

      final mockRequestOptions = RequestOptions(
        path: testPath,
        baseUrl: baseUrl,
      );

      final mockResponse = Response<Object>(
        data: {'id': '123', 'name': 'Test'},
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<Map<String, dynamic>>(path: testPath);

      // Assert
      expect(result.requestUri, expectedUri.toString());
    });

    test('should include raw data in response', () async {
      // Arrange
      final mockRequestOptions = RequestOptions(path: testPath);

      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await apiManager.get<Map<String, dynamic>>(path: testPath);

      // Assert
      expect(result.raw, testResponseData);
    });
  });

  group('ApiManager CancelToken Tests', () {
    const testPath = '/api/test';
    final testResponseData = {'id': '123', 'name': 'Test'};

    test('should pass cancel token to request', () async {
      // Arrange
      final cancelToken = CancelToken();
      final mockRequestOptions = RequestOptions(path: testPath);

      final mockResponse = Response<Object>(
        data: testResponseData,
        statusCode: 200,
        requestOptions: mockRequestOptions,
        headers: Headers(),
      );

      when(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: cancelToken,
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await apiManager.get<Map<String, dynamic>>(
        path: testPath,
        cancelToken: cancelToken,
      );

      // Assert
      verify(
        mockDio.request<Object>(
          testPath,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
          cancelToken: cancelToken,
        ),
      ).called(1);
    });
  });
}

// Helper model class for testing
class TestModel {
  final String id;
  final String name;

  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(id: json['id'] as String, name: json['name'] as String);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
