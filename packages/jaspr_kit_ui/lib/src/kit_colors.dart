import 'package:jaspr/dom.dart';

/// Kit colors for Jaspr components, backed by CSS custom properties that
/// [kitTokenStyles] emits from `kit_design_tokens`.
///
/// Using `var(--kit-…)` instead of literal hex keeps one source of truth and
/// lets a page re-theme (e.g. dark mode) by overriding the variables.
abstract final class KitColors {
  // ─── Brand (BrandTokens) ───────────────────────────────
  static const Color primary = Color.variable('--kit-primary');
  static const Color primaryBusy = Color.variable('--kit-primaryBusy');
  static const Color primaryContainer = Color.variable(
    '--kit-primaryContainer',
  );
  static const Color onPrimary = Color.variable('--kit-onPrimary');
  static const Color secondary = Color.variable('--kit-secondaryPalette');
  static const Color tertiary = Color.variable('--kit-tertiary');
  static const Color error = Color.variable('--kit-error');
  static const Color success = Color.variable('--kit-success');
  static const Color warn = Color.variable('--kit-warn');
  static const Color gold = Color.variable('--kit-gold');
  static const Color textBlack = Color.variable('--kit-textBlack');
  static const Color secondaryTitle = Color.variable(
    '--kit-secondaryTitleColor',
  );

  /// Any palette shade, e.g. `KitColors.palette('gray', 20)`.
  static Color palette(String group, int shade) =>
      Color.variable('--kit-$group-$shade');

  /// Any brand token by its `BrandTokens` name, e.g. `KitColors.brand('ceil')`.
  static Color brand(String name) => Color.variable('--kit-$name');
}
