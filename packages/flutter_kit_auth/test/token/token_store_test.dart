import 'package:flutter_kit_auth/auth/domain/entity/auth_entity.dart';
import 'package:flutter_kit_auth/auth/token/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'token_store_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FlutterSecureStorage>()])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureTokenStore store;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    store = SecureTokenStore(storage: mockStorage);
  });

  // ─── read ──────────────────────────────────────────────────────────────────

  group('read', () {
    test('returns AuthTokens when access and refresh tokens exist', () async {
      when(
        mockStorage.read(key: 'access_token'),
      ).thenAnswer((_) async => 'abc');
      when(
        mockStorage.read(key: 'refresh_token'),
      ).thenAnswer((_) async => 'xyz');

      final tokens = await store.read();

      expect(tokens, isNotNull);
      expect(tokens!.accessToken, 'abc');
      expect(tokens.refreshToken, 'xyz');
    });

    test(
      'returns AuthTokens with null refresh when refresh is not stored',
      () async {
        when(
          mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => 'abc');
        when(
          mockStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => null);

        final tokens = await store.read();

        expect(tokens!.accessToken, 'abc');
        expect(tokens.refreshToken, isNull);
      },
    );

    test('returns null when access token is null', () async {
      when(mockStorage.read(key: 'access_token')).thenAnswer((_) async => null);

      final tokens = await store.read();

      expect(tokens, isNull);
    });

    test('returns null when access token is empty string', () async {
      when(mockStorage.read(key: 'access_token')).thenAnswer((_) async => '');

      final tokens = await store.read();

      expect(tokens, isNull);
    });
  });

  // ─── write ─────────────────────────────────────────────────────────────────

  group('write', () {
    test('writes both access and refresh tokens', () async {
      const tokens = AuthTokens(accessToken: 'abc', refreshToken: 'xyz');

      await store.write(tokens);

      verify(mockStorage.write(key: 'access_token', value: 'abc')).called(1);
      verify(mockStorage.write(key: 'refresh_token', value: 'xyz')).called(1);
    });

    test('writes only access token when refresh is null', () async {
      const tokens = AuthTokens(accessToken: 'abc', refreshToken: null);

      await store.write(tokens);

      verify(mockStorage.write(key: 'access_token', value: 'abc')).called(1);
      verifyNever(
        mockStorage.write(key: 'refresh_token', value: anyNamed('value')),
      );
    });
  });

  // ─── clear ─────────────────────────────────────────────────────────────────

  group('clear', () {
    test('deletes both access and refresh keys', () async {
      await store.clear();

      verify(mockStorage.delete(key: 'access_token')).called(1);
      verify(mockStorage.delete(key: 'refresh_token')).called(1);
    });
  });

  // ─── readAccess ────────────────────────────────────────────────────────────

  group('readAccess', () {
    test('returns access token string from storage', () async {
      when(
        mockStorage.read(key: 'access_token'),
      ).thenAnswer((_) async => 'token123');

      final result = await store.readAccess();

      expect(result, 'token123');
    });

    test('returns null when access token is not stored', () async {
      when(mockStorage.read(key: 'access_token')).thenAnswer((_) async => null);

      final result = await store.readAccess();

      expect(result, isNull);
    });
  });

  // ─── readRefresh ───────────────────────────────────────────────────────────

  group('readRefresh', () {
    test('returns refresh token string from storage', () async {
      when(
        mockStorage.read(key: 'refresh_token'),
      ).thenAnswer((_) async => 'refresh123');

      final result = await store.readRefresh();

      expect(result, 'refresh123');
    });

    test('returns null when refresh token is not stored', () async {
      when(
        mockStorage.read(key: 'refresh_token'),
      ).thenAnswer((_) async => null);

      final result = await store.readRefresh();

      expect(result, isNull);
    });
  });
}
