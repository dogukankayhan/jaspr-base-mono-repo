import 'package:kit_core/utils/background/run_in_background.dart';
import 'package:test/test.dart';

void main() {
  test('returns the computation result', () async {
    expect(await runInBackground(() => 21 * 2), 42);
  });

  test('awaits async computations', () async {
    expect(await runInBackground(() async => 'done'), 'done');
  });

  test('propagates errors', () {
    expect(
      runInBackground<int>(() => throw StateError('boom')),
      throwsStateError,
    );
  });
}
