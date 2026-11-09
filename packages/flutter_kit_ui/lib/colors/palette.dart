import 'package:flutter/material.dart';
import 'package:kit_design_tokens/kit_design_tokens.dart';

/// Raw color palette — pure data, zero logic.
///
/// Values come from `kit_design_tokens` ([PaletteTokens]) so the web app
/// renders the exact same colors. Edit them there, not here.
///
/// All values are compile-time const. No map allocation at runtime.
/// Directly access rarely used shades here: Palette.primary[30]!
///
/// See [AppBrandColors] for commonly used semantic colors.
abstract final class Palette {
  static const Map<int, Color> primary = {
    10: Color(PaletteTokens.primary10),
    20: Color(PaletteTokens.primary20),
    30: Color(PaletteTokens.primary30),
    40: Color(PaletteTokens.primary40),
    50: Color(PaletteTokens.primary50),
    60: Color(PaletteTokens.primary60),
    70: Color(PaletteTokens.primary70),
    80: Color(PaletteTokens.primary80),
    90: Color(PaletteTokens.primary90),
    100: Color(PaletteTokens.primary100),
  };

  static const Map<int, Color> secondary = {
    10: Color(PaletteTokens.secondary10),
    20: Color(PaletteTokens.secondary20),
    30: Color(PaletteTokens.secondary30),
    40: Color(PaletteTokens.secondary40),
    50: Color(PaletteTokens.secondary50),
    60: Color(PaletteTokens.secondary60),
    70: Color(PaletteTokens.secondary70),
    80: Color(PaletteTokens.secondary80),
    90: Color(PaletteTokens.secondary90),
    100: Color(PaletteTokens.secondary100),
  };

  static const Map<int, Color> tertiary = {
    10: Color(PaletteTokens.tertiary10),
    20: Color(PaletteTokens.tertiary20),
    30: Color(PaletteTokens.tertiary30),
    40: Color(PaletteTokens.tertiary40),
    50: Color(PaletteTokens.tertiary50),
    60: Color(PaletteTokens.tertiary60),
    70: Color(PaletteTokens.tertiary70),
    80: Color(PaletteTokens.tertiary80),
    90: Color(PaletteTokens.tertiary90),
    100: Color(PaletteTokens.tertiary100),
  };

  static const Map<int, Color> fourth = {
    10: Color(PaletteTokens.fourth10),
    20: Color(PaletteTokens.fourth20),
    30: Color(PaletteTokens.fourth30),
    40: Color(PaletteTokens.fourth40),
    50: Color(PaletteTokens.fourth50),
    60: Color(PaletteTokens.fourth60),
    70: Color(PaletteTokens.fourth70),
    80: Color(PaletteTokens.fourth80),
    90: Color(PaletteTokens.fourth90),
    100: Color(PaletteTokens.fourth100),
  };

  static const Map<int, Color> gray = {
    10: Color(PaletteTokens.gray10),
    20: Color(PaletteTokens.gray20),
    30: Color(PaletteTokens.gray30),
    40: Color(PaletteTokens.gray40),
    50: Color(PaletteTokens.gray50),
    60: Color(PaletteTokens.gray60),
    70: Color(PaletteTokens.gray70),
    80: Color(PaletteTokens.gray80),
    90: Color(PaletteTokens.gray90),
    100: Color(PaletteTokens.gray100),
  };

  static const Map<int, Color> colorGray = {
    10: Color(PaletteTokens.colorGray10),
    20: Color(PaletteTokens.colorGray20),
    30: Color(PaletteTokens.colorGray30),
    40: Color(PaletteTokens.colorGray40),
    50: Color(PaletteTokens.colorGray50),
    60: Color(PaletteTokens.colorGray60),
    70: Color(PaletteTokens.colorGray70),
    80: Color(PaletteTokens.colorGray80),
    90: Color(PaletteTokens.colorGray90),
    100: Color(PaletteTokens.colorGray100),
  };

  static const Map<int, Color> white = {
    10: Color(PaletteTokens.white10),
    20: Color(PaletteTokens.white20),
    30: Color(PaletteTokens.white30),
    40: Color(PaletteTokens.white40),
    50: Color(PaletteTokens.white50),
    60: Color(PaletteTokens.white60),
    70: Color(PaletteTokens.white70),
    80: Color(PaletteTokens.white80),
    90: Color(PaletteTokens.white90),
    100: Color(PaletteTokens.white100),
  };
}
