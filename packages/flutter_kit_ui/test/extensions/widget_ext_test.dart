import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/extensions/widget_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('visibleIf', () {
    testWidgets('renders the widget when true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Text('hello').visibleIf(true)),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('collapses to nothing when false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: const Text('hello').visibleIf(false)),
      );
      expect(find.text('hello'), findsNothing);
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('disabledIf', () {
    testWidgets('blocks pointer events and dims when true', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const Text('hello').disabledIf(true),
        ),
      );
      final ignorePointer = tester.widget<IgnorePointer>(
        find.byType(IgnorePointer),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(ignorePointer.ignoring, true);
      expect(opacity.opacity, 0.4);
    });

    testWidgets('stays interactive and opaque when false', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const Text('hello').disabledIf(false),
        ),
      );
      final ignorePointer = tester.widget<IgnorePointer>(
        find.byType(IgnorePointer),
      );
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(ignorePointer.ignoring, false);
      expect(opacity.opacity, 1);
    });
  });

  test('sliver wraps the widget in SliverToBoxAdapter', () {
    const widget = Text('hello');
    expect(widget.sliver, isA<SliverToBoxAdapter>());
  });
}
