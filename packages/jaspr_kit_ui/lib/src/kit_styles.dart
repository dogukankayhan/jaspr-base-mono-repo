import 'package:jaspr/dom.dart';
import 'package:kit_design_tokens/kit_design_tokens.dart';

/// `:root` CSS custom properties generated from `kit_design_tokens`:
/// `--kit-<group>-<shade>` for every palette shade and `--kit-<name>` for
/// every brand color. Include it once in the app's global `@css` styles.
List<StyleRule> get kitTokenStyles => [
  css(':root').styles(
    raw: {
      for (final group in PaletteTokens.groups.entries)
        for (final shade in group.value.entries)
          '--kit-${group.key}-${shade.key}': cssHex(shade.value),
      for (final brand in BrandTokens.all.entries)
        '--kit-${brand.key}': cssHex(brand.value),
    },
  ),
];

/// Base styles every kit page relies on — including the default loading
/// overlay rendered by `jaspr_kit_core`'s `BaseBlocView`.
List<StyleRule> get kitBaseStyles => [
  css('html, body').styles(
    margin: Margin.zero,
    padding: Padding.zero,
    raw: {
      'font-family': 'Roboto, system-ui, -apple-system, sans-serif',
      'color': 'var(--kit-textBlack)',
      'background-color': 'var(--kit-white-10)',
    },
  ),
  css('.kit-loading-overlay').styles(
    raw: {
      'position': 'fixed',
      'inset': '0',
      'display': 'flex',
      'align-items': 'center',
      'justify-content': 'center',
      'background-color': 'rgba(255, 255, 255, 0.6)',
      'z-index': '1000',
    },
  ),
  css('.kit-spinner').styles(
    raw: {
      'width': '40px',
      'height': '40px',
      'border': '4px solid var(--kit-primary-10)',
      'border-top-color': 'var(--kit-primary)',
      'border-radius': '50%',
      'animation': 'kit-spin 0.8s linear infinite',
    },
  ),
  css.keyframes('kit-spin', {
    'to': const Styles(raw: {'transform': 'rotate(360deg)'}),
  }),
];

/// Convenience: tokens + base styles.
List<StyleRule> get kitGlobalStyles => [...kitTokenStyles, ...kitBaseStyles];
