@Tags(['integration'])
library;

import 'package:dio/dio.dart';
import 'package:flutter_kit_network/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'local_test_server.dart';

// Local echo server mirrors httpbin's /anything — reflects request headers back.
// Tests that the Authorization header is actually present in the outgoing HTTP request.

void main() {
  group('AuthInterceptor — integration (local echo server)', () {
    late LocalTestServer server;

    setUp(() async {
      server = await LocalTestServer.start(handler: echoHeaders);
    });

    tearDown(() => server.close());

    test(
      'attaches Authorization: Bearer header to real outgoing request',
      () async {
        const token = 'integration-test-token-abc123';
        final dio = Dio(BaseOptions(baseUrl: server.baseUrl))
          ..interceptors.add(
            AuthInterceptor(authTokenProvider: () async => token),
          );

        final res = await dio.get<Map<String, dynamic>>('/');
        final headers = res.data!['headers'] as Map<String, dynamic>;

        expect(
          headers['authorization'] ?? headers['Authorization'],
          'Bearer $token',
        );
      },
    );

    test(
      'does not attach Authorization header when provider returns null',
      () async {
        final dio = Dio(BaseOptions(baseUrl: server.baseUrl))
          ..interceptors.add(
            AuthInterceptor(authTokenProvider: () async => null),
          );

        final res = await dio.get<Map<String, dynamic>>('/');
        final headers = res.data!['headers'] as Map<String, dynamic>;
        final keys = headers.keys.map((k) => k.toLowerCase()).toSet();

        expect(keys.contains('authorization'), false);
      },
    );

    test(
      'does not attach Authorization header when provider returns empty string',
      () async {
        final dio = Dio(BaseOptions(baseUrl: server.baseUrl))
          ..interceptors.add(
            AuthInterceptor(authTokenProvider: () async => ''),
          );

        final res = await dio.get<Map<String, dynamic>>('/');
        final headers = res.data!['headers'] as Map<String, dynamic>;
        final keys = headers.keys.map((k) => k.toLowerCase()).toSet();

        expect(keys.contains('authorization'), false);
      },
    );

    test(
      'token is sent correctly on POST request',
      () async {
        const token = 'post-request-token-xyz';
        final dio = Dio(BaseOptions(baseUrl: server.baseUrl))
          ..interceptors.add(
            AuthInterceptor(authTokenProvider: () async => token),
          );

        final res = await dio.post<Map<String, dynamic>>(
          '/',
          data: {'key': 'value'},
        );
        final headers = res.data!['headers'] as Map<String, dynamic>;

        expect(
          headers['authorization'] ?? headers['Authorization'],
          'Bearer $token',
        );
        expect(res.data!['method'], 'POST');
      },
    );
  });
}
