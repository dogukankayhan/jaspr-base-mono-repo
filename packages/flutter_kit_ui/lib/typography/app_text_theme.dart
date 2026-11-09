import 'package:flutter/material.dart';

/// Application typography.
///
/// Material 3 [TextTheme] standard naming conventions:
///   displayLarge / displayMedium / displaySmall
///   headlineLarge / headlineMedium / headlineSmall
///   titleLarge / titleMedium / titleSmall
///   bodyLarge / bodyMedium / bodySmall
///   labelLarge / labelMedium / labelSmall
///
/// Update [_fontFamily] constant to change font family.
/// If you want to use Google Fonts, add google_fonts to pubspec
/// and override the TextStyles here with GoogleFonts.xxx().
sealed class AppTextTheme {
  AppTextTheme._();

  static const String _fontFamily = 'Roboto';

  static TextTheme get textTheme => const TextTheme(
    // Display
    displayLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.22,
    ),

    // Headline
    headlineLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
    ),

    // Title
    titleLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w500,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),

    // Body
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),

    // Label
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );
}
