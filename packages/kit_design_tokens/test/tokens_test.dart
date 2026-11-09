import 'package:kit_design_tokens/kit_design_tokens.dart';
import 'package:test/test.dart';

void main() {
  group('cssHex', () {
    test('opaque color → #rrggbb', () {
      expect(cssHex(0xFF5b7dfb), '#5b7dfb');
      expect(cssHex(0xFF000000), '#000000');
    });

    test('translucent color → #rrggbbaa', () {
      expect(cssHex(0x80FF0000), '#ff000080');
    });
  });

  test('palette maps point at the flat constants', () {
    expect(PaletteTokens.primary[40], PaletteTokens.primary40);
    expect(PaletteTokens.primary40, BrandTokens.primary);
    expect(PaletteTokens.primary.keys, [
      10,
      20,
      30,
      40,
      50,
      60,
      70,
      80,
      90,
      100,
    ]);
  });
}
