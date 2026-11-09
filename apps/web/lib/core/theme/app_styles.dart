import 'package:jaspr/dom.dart';
import 'package:jaspr_kit_ui/jaspr_kit_ui.dart';

/// Global stylesheet: kit design tokens as CSS variables + kit base styles.
/// Registered through `App.styles`; component-specific rules live next to
/// each component (`@css static`).
List<StyleRule> get globalStyles => [
  ...kitGlobalStyles,
  css('a').styles(raw: {'color': 'inherit'}),
];
