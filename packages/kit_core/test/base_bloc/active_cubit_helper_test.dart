import 'package:kit_core/base_bloc/active_cubit_helper.dart';
import 'package:kit_network/core/di/locator.dart';
import 'package:test/test.dart';

class _CubitA {}

class _CubitB {}

void main() {
  setUp(() async => getIt.reset());

  group('publishActive / getActive', () {
    test('registers and retrieves instance without key', () {
      final a = _CubitA();
      publishActive<_CubitA>(a);
      expect(getActive<_CubitA>(), same(a));
    });

    test('registers and retrieves instance with explicit key', () {
      final a = _CubitA();
      publishActive<_CubitA>(a, key: 'user-42');
      expect(getActive<_CubitA>(key: 'user-42'), same(a));
    });

    test('different keys return different instances', () {
      final a1 = _CubitA();
      final a2 = _CubitA();
      publishActive<_CubitA>(a1, key: 'key1');
      publishActive<_CubitA>(a2, key: 'key2');
      expect(getActive<_CubitA>(key: 'key1'), same(a1));
      expect(getActive<_CubitA>(key: 'key2'), same(a2));
    });

    test('different types are independent', () {
      final a = _CubitA();
      final b = _CubitB();
      publishActive<_CubitA>(a);
      publishActive<_CubitB>(b);
      expect(getActive<_CubitA>(), same(a));
      expect(getActive<_CubitB>(), same(b));
    });
  });

  group('getActiveOrNull', () {
    test('returns null when not registered', () {
      expect(getActiveOrNull<_CubitA>(), isNull);
    });

    test('returns null for unknown key', () {
      publishActive<_CubitA>(_CubitA());
      expect(getActiveOrNull<_CubitA>(key: 'missing'), isNull);
    });

    test('returns instance when registered', () {
      final a = _CubitA();
      publishActive<_CubitA>(a);
      expect(getActiveOrNull<_CubitA>(), same(a));
    });
  });

  group('hasActive', () {
    test('returns false when not registered', () {
      expect(hasActive<_CubitA>(), false);
    });

    test('returns true after publish', () {
      publishActive<_CubitA>(_CubitA());
      expect(hasActive<_CubitA>(), true);
    });

    test('returns false after unpublish', () {
      publishActive<_CubitA>(_CubitA());
      unpublishActive<_CubitA>();
      expect(hasActive<_CubitA>(), false);
    });
  });

  group('unpublishActive', () {
    test('removes registration so getActiveOrNull returns null', () {
      publishActive<_CubitA>(_CubitA());
      unpublishActive<_CubitA>();
      expect(getActiveOrNull<_CubitA>(), isNull);
    });

    test('removing with key does not affect default registration', () {
      final def = _CubitA();
      publishActive<_CubitA>(def);
      publishActive<_CubitA>(_CubitA(), key: 'k');
      unpublishActive<_CubitA>(key: 'k');
      expect(getActive<_CubitA>(), same(def));
    });

    test('no-op when nothing is registered', () {
      expect(() => unpublishActive<_CubitA>(), returnsNormally);
    });
  });

  group('getAllActiveKeys', () {
    // Note: _activeKeys is a module-level Set — getIt.reset() clears GetIt
    // but does NOT clear _activeKeys. Tests use unique keys and clean up.

    test('contains key after publish', () {
      const k = 'getAllActiveKeys-publish-test';
      publishActive<_CubitA>(_CubitA(), key: k);
      expect(getAllActiveKeys(), contains(k));
      unpublishActive<_CubitA>(key: k);
    });

    test('does not contain key after unpublish', () {
      const k = 'getAllActiveKeys-unpublish-test';
      publishActive<_CubitA>(_CubitA(), key: k);
      unpublishActive<_CubitA>(key: k);
      expect(getAllActiveKeys(), isNot(contains(k)));
    });
  });

  group('getActive — exception', () {
    test('throws ActiveCubitNotFoundException when not registered', () {
      expect(
        () => getActive<_CubitA>(),
        throwsA(isA<ActiveCubitNotFoundException<_CubitA>>()),
      );
    });

    test('exception message includes type name', () {
      try {
        getActive<_CubitA>(key: 'missing');
        fail('expected exception');
      } on ActiveCubitNotFoundException<_CubitA> catch (e) {
        expect(e.toString(), contains('_CubitA'));
      }
    });
  });
}
