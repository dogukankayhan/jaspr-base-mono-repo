import 'package:kit_core/utils/extensions/datetime_ext.dart';
import 'package:test/test.dart';

void main() {
  group('timeAgo', () {
    test('uses default English labels', () {
      final target = DateTime.now().subtract(const Duration(hours: 3));
      expect(target.timeAgo(), '3h ago');
    });

    test('accepts custom labels for localization', () {
      final target = DateTime.now().subtract(const Duration(days: 2));
      const labels = TimeAgoLabels(daysAgo: ' gün önce');
      expect(target.timeAgo(labels), '2 gün önce');
    });

    test('just now for sub-minute differences', () {
      final target = DateTime.now().subtract(const Duration(seconds: 5));
      expect(target.timeAgo(), 'just now');
    });
  });
}
