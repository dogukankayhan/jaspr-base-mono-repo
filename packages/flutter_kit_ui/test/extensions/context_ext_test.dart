import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<BuildContext> pumpWithWidth(WidgetTester tester, double width) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return capturedContext;
  }

  Future<BuildContext> pumpWithMediaQuery(
    WidgetTester tester,
    MediaQueryData data,
  ) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MediaQuery(
        data: data,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    return capturedContext;
  }

  group('screen breakpoints', () {
    testWidgets('isCompactScreen for narrow widths', (tester) async {
      final context = await pumpWithWidth(tester, 400);
      expect(context.isCompactScreen, true);
      expect(context.isMediumScreen, false);
      expect(context.isExpandedScreen, false);
    });

    testWidgets('isMediumScreen for tablet widths', (tester) async {
      final context = await pumpWithWidth(tester, 700);
      expect(context.isCompactScreen, false);
      expect(context.isMediumScreen, true);
      expect(context.isExpandedScreen, false);
    });

    testWidgets('isExpandedScreen for wide widths', (tester) async {
      final context = await pumpWithWidth(tester, 1200);
      expect(context.isCompactScreen, false);
      expect(context.isMediumScreen, false);
      expect(context.isExpandedScreen, true);
    });
  });

  group('isKeyboardOpen', () {
    testWidgets('false when there is no bottom view inset', (tester) async {
      final context = await pumpWithMediaQuery(
        tester,
        const MediaQueryData(size: Size(400, 800)),
      );
      expect(context.isKeyboardOpen, false);
    });

    testWidgets('true when the bottom view inset is positive', (tester) async {
      final context = await pumpWithMediaQuery(
        tester,
        const MediaQueryData(
          size: Size(400, 800),
          viewInsets: EdgeInsets.only(bottom: 300),
        ),
      );
      expect(context.isKeyboardOpen, true);
    });
  });

  group('orientation', () {
    testWidgets('isPortrait for taller-than-wide sizes', (tester) async {
      final context = await pumpWithMediaQuery(
        tester,
        const MediaQueryData(size: Size(400, 800)),
      );
      expect(context.isPortrait, true);
      expect(context.isLandscape, false);
    });

    testWidgets('isLandscape for wider-than-tall sizes', (tester) async {
      final context = await pumpWithMediaQuery(
        tester,
        const MediaQueryData(size: Size(800, 400)),
      );
      expect(context.isPortrait, false);
      expect(context.isLandscape, true);
    });
  });
}
