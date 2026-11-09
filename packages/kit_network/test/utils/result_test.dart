import 'package:kit_network/core/utils/result.dart';
import 'package:test/test.dart';

void main() {
  group('Ok', () {
    test('isOk is true, isErr is false', () {
      const result = Ok<int, String>(42);
      expect(result.isOk, true);
      expect(result.isErr, false);
    });

    test('value returns the wrapped value', () {
      const result = Ok<String, Never>('hello');
      expect(result.value, 'hello');
    });

    test('when calls ok callback with value', () {
      const result = Ok<int, String>(10);
      final out = result.when(ok: (v) => v * 2, err: (_) => -1);
      expect(out, 20);
    });

    test('supports null value', () {
      const result = Ok<void, String>(null);
      expect(result.isOk, true);
    });
  });

  group('Err', () {
    test('isErr is true, isOk is false', () {
      const result = Err<int, String>('error');
      expect(result.isErr, true);
      expect(result.isOk, false);
    });

    test('error returns the wrapped error', () {
      const result = Err<Never, String>('something went wrong');
      expect(result.error, 'something went wrong');
    });

    test('when calls err callback with error', () {
      const result = Err<int, String>('bad');
      final out = result.when(ok: (_) => 0, err: (e) => e.length);
      expect(out, 3);
    });
  });

  group('Result.when', () {
    Result<int, String> divide(int a, int b) {
      if (b == 0) return const Err('division by zero');
      return Ok(a ~/ b);
    }

    test('successful division returns Ok', () {
      final result = divide(10, 2);
      expect(result.isOk, true);
      result.when(
        ok: (v) => expect(v, 5),
        err: (_) => fail('should not be err'),
      );
    });

    test('division by zero returns Err', () {
      final result = divide(10, 0);
      expect(result.isErr, true);
      result.when(
        ok: (_) => fail('should not be ok'),
        err: (e) => expect(e, 'division by zero'),
      );
    });
  });
}
