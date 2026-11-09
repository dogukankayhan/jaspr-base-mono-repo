import 'package:app_shared/data/repository/user_repository_impl.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';
import 'package:kit_network/core/network/api/api_response.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/network/error/api_exception.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_repository_impl_test.mocks.dart';

final _kProfileJson = <String, dynamic>{
  'firstName': 'John',
  'lastName': 'Doe',
  'email': 'john@doe.com',
};

@GenerateMocks([ApiManager])
void main() {
  late MockApiManager mockApi;
  late UserRepositoryImpl repo;

  setUp(() {
    mockApi = MockApiManager();
    repo = UserRepositoryImpl(mockApi);
  });

  group('getProfile', () {
    test('returns Ok(UserProfile) on success', () async {
      when(
        mockApi.get<Map<String, dynamic>>(path: anyNamed('path')),
      ).thenAnswer((_) async => ApiResponse(data: _kProfileJson));

      final result = await repo.getProfile();

      result.when(
        ok: (profile) {
          expect(profile.firstName, 'John');
          expect(profile.email, 'john@doe.com');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('requests the user profile endpoint', () async {
      when(
        mockApi.get<Map<String, dynamic>>(path: anyNamed('path')),
      ).thenAnswer((_) async => ApiResponse(data: _kProfileJson));

      await repo.getProfile();

      verify(mockApi.get<Map<String, dynamic>>(path: '/user/me')).called(1);
    });

    test('returns Err wrapping ApiError from ApiException', () async {
      when(mockApi.get<Map<String, dynamic>>(path: anyNamed('path'))).thenThrow(
        ApiException(ApiError(statusCode: 401, message: 'unauthorized')),
      );

      final result = await repo.getProfile();

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) {
          expect(e.message, 'unauthorized');
          expect(e.statusCode, 401);
        },
      );
    });

    test('wraps generic exception as Err(ApiError)', () async {
      when(
        mockApi.get<Map<String, dynamic>>(path: anyNamed('path')),
      ).thenThrow(Exception('timeout'));

      final result = await repo.getProfile();

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, contains('timeout')),
      );
    });
  });
}
