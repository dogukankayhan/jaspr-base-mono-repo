import 'package:flutter/material.dart';

extension ColorExt on Color {
  /// Lightens the color by [amount] (0.0–1.0).
  Color lighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Darkens the color by [amount] (0.0–1.0).
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Returns the hex string, e.g. `#FF5733`.
  String get toHex {
    final r = (this.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (this.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (this.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  /// True when the color is perceived as bright (good for dark text on top).
  bool get isBright => computeLuminance() > 0.5;

  bool get isDark => !isBright;
}

extension StringAvatarColorExt on String {
  /// A deterministic color from [Colors.primaries], stable for this string.
  /// Pairs well with `StringExt.initials` for avatar backgrounds.
  Color get avatarColor => Colors.primaries[hashCode.abs() % Colors.primaries.length];
}
