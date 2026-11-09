import 'package:kit_core/utils/extensions/collection_ext.dart';
import 'package:test/test.dart';

void main() {
  group('ListExt.indexOrNull', () {
    test('returns index of first match', () {
      expect([1, 2, 3, 4].indexOrNull((e) => e == 3), 2);
    });

    test('returns null when nothing matches', () {
      expect([1, 2, 3].indexOrNull((e) => e == 99), isNull);
    });
  });

  group('NullableIterableExt.whereNotNull', () {
    test('drops null elements', () {
      expect([1, null, 2, null, 3].whereNotNull(), [1, 2, 3]);
    });

    test('returns empty list when all elements are null', () {
      expect(<int?>[null, null].whereNotNull(), isEmpty);
    });
  });

  group('IterableExt', () {
    test('distinctBy keeps first occurrence per key', () {
      final result = [1, 2, 3, 4].distinctBy((e) => e % 2);
      expect(result, [1, 2]);
    });

    test('groupBy buckets by key', () {
      final result = [1, 2, 3, 4].groupBy((e) => e % 2);
      expect(result, {1: [1, 3], 0: [2, 4]});
    });
  });
}
