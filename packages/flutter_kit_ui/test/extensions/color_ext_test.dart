import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/extensions/color_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorExt', () {
    test('toHex returns uppercase hex string', () {
      expect(Colors.red.toHex, '#F44336');
    });

    test('isBright/isDark are opposites', () {
      expect(Colors.white.isBright, true);
      expect(Colors.white.isDark, false);
      expect(Colors.black.isBright, false);
      expect(Colors.black.isDark, true);
    });
  });

  group('StringAvatarColorExt', () {
    test('is deterministic for the same string', () {
      expect('Jane Doe'.avatarColor, 'Jane Doe'.avatarColor);
    });

    test('picks from Colors.primaries', () {
      expect(Colors.primaries, contains('Jane Doe'.avatarColor));
    });
  });
}
