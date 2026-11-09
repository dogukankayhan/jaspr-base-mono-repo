import 'package:kit_core/utils/extensions/future_ext.dart';
import 'package:test/test.dart';

void main() {
  group('timeoutOrNull', () {
    test('returns the value when it completes in time', () async {
      final result = await Future.value(42).timeoutOrNull(
        const Duration(milliseconds: 100),
      );
      expect(result, 42);
    });

    test('returns null when the future times out', () async {
      final slow = Future.delayed(
        const Duration(milliseconds: 200),
        () => 42,
      );
      final result = await slow.timeoutOrNull(const Duration(milliseconds: 10));
      expect(result, isNull);
    });
  });
}
