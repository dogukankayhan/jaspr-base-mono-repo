import 'package:flutter_kit_auth/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:flutter_kit_auth/auth/domain/entity/password_reset_entity.dart';
import 'package:flutter_kit_auth/auth/domain/enum/social_auth_provider.dart';
import 'package:flutter_kit_network/core/network/api/api_manager_interface.dart';
import 'package:flutter_kit_network/core/network/api/api_response.dart';
import 'package:flutter_kit_network/core/network/error/api_error.dart';
import 'package:flutter_kit_network/core/network/error/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _kTokensJson = {'accessToken': 'access', 'refreshToken': 'refresh'};
final _kProfileJson = {
  'id': '1',
  'email': 'test@test.com',
  'firstName': 'John',
  'lastName': 'Doe',
};
final _kApiError = ApiError(statusCode: 401, message: 'unauthorized');

ApiResponse<Map<String, dynamic>> _response(Map<String, dynamic> data) =>
    ApiResponse(data: data);

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateMocks([ApiManager])
void main() {
  late MockApiManager mockApi;
  late AuthRepositoryImpl repo;

  setUp(() {
    mockApi = MockApiManager();
    repo = AuthRepositoryImpl(mockApi);
  });

  // ─── login ─────────────────────────────────────────────────────────────────

  group('login', () {
    test('returns Ok(AuthTokens) and posts to LoginEndpoint.path', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => _response(_kTokensJson));

      final result = await repo.login(
        const LoginRequest(email: 'test@test.com', password: 'pw'),
      );

      result.when(
        ok: (tokens) {
          expect(tokens.accessToken, 'access');
          expect(tokens.refreshToken, 'refresh');
        },
        err: (_) => fail('expected ok'),
      );
      final captured = verify(
        mockApi.post<Map<String, dynamic>>(
          path: captureAnyNamed('path'),
          body: captureAnyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).captured;
      expect(captured[0], '/auth/login');
      expect(captured[1], {'email': 'test@test.com', 'password': 'pw'});
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenThrow(ApiException(_kApiError));

      final result = await repo.login(
        const LoginRequest(email: 'x@y.com', password: 'pw'),
      );

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });
  });

  // ─── register ──────────────────────────────────────────────────────────────

  group('register', () {
    test('forwards all fields via RegisterEndpoint.body', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => _response(_kTokensJson));

      await repo.register(
        const RegisterRequest(
          email: 'new@test.com',
          password: 'pw',
          firstName: 'John',
          lastName: 'Doe',
        ),
      );

      final captured = verify(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: captureAnyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).captured;
      expect(captured.single, {
        'email': 'new@test.com',
        'password': 'pw',
        'firstName': 'John',
        'lastName': 'Doe',
      });
    });
  });

  // ─── me ────────────────────────────────────────────────────────────────────

  group('me', () {
    test('returns Ok(Profile) mapped from the response', () async {
      when(
        mockApi.get<Map<String, dynamic>>(
          path: anyNamed('path'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => _response(_kProfileJson));

      final result = await repo.me();

      result.when(
        ok: (profile) {
          expect(profile.id, '1');
          expect(profile.fullName, 'John Doe');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.get<Map<String, dynamic>>(
          path: anyNamed('path'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenThrow(ApiException(_kApiError));

      final result = await repo.me();

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });
  });

  // ─── logout ────────────────────────────────────────────────────────────────

  group('logout', () {
    test('returns Ok(null) on success', () async {
      when(
        mockApi.post(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => _response(const {}));

      final result = await repo.logout();

      expect(result.isOk, true);
    });

    test('returns Err on ApiException', () async {
      when(
        mockApi.post(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenThrow(ApiException(_kApiError));

      final result = await repo.logout();

      expect(result.isErr, true);
    });
  });

  // ─── socialSignIn ──────────────────────────────────────────────────────────

  group('socialSignIn', () {
    test('picks the path from the provider', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => _response(_kTokensJson));

      await repo.socialSignIn(
        const SocialSignInRequest(
          provider: SocialAuthProvider.apple,
          idToken: 'apple-token',
        ),
      );

      final path =
          verify(
                mockApi.post<Map<String, dynamic>>(
                  path: captureAnyNamed('path'),
                  body: anyNamed('body'),
                  cancelToken: anyNamed('cancelToken'),
                ),
              ).captured.single
              as String;
      expect(path, '/auth/apple');
    });
  });

  // ─── guestSignIn ───────────────────────────────────────────────────────────

  group('guestSignIn', () {
    test('returns Ok(AuthTokens) on success', () async {
      when(
        mockApi.post<Map<String, dynamic>>(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => _response(_kTokensJson));

      final result = await repo.guestSignIn();

      result.when(
        ok: (tokens) => expect(tokens.accessToken, 'access'),
        err: (_) => fail('expected ok'),
      );
    });
  });

  // ─── password reset ────────────────────────────────────────────────────────

  group('password reset', () {
    test('startPasswordReset posts email only', () async {
      when(
        mockApi.post(
          path: anyNamed('path'),
          body: anyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) async => _response(const {}));

      final result = await repo.startPasswordReset(
        const PasswordResetStartRequest(email: 'a@b.com'),
      );

      expect(result.isOk, true);
      final captured = verify(
        mockApi.post(
          path: anyNamed('path'),
          body: captureAnyNamed('body'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).captured;
      expect(captured.single, {'email': 'a@b.com'});
    });
  });
}
