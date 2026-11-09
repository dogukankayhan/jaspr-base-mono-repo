import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

extension BuildContextExt on BuildContext {
  // ─── App colors ──────────────────────────────────────────────────────────

  AppColors get appColors => Theme.of(this).extension<AppColors>()!;

  // ─── Keyboard ────────────────────────────────────────────────────────────

  void dismissKeyboard() {
    final scope = FocusScope.of(this);
    if (scope.hasFocus) scope.unfocus();
  }

  // ─── Safe area ───────────────────────────────────────────────────────────

  double get topSafe => MediaQuery.paddingOf(this).top;
  double get bottomSafe => MediaQuery.paddingOf(this).bottom;

  /// Bottom padding that grows when the software keyboard appears.
  EdgeInsets get bottomInsetPadding =>
      EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(this).bottom);

  /// `true` while the software keyboard is visible.
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  // ─── Screen size ─────────────────────────────────────────────────────────

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isPortrait =>
      MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  // ─── Breakpoints (Material window size classes) ─────────────────────────

  bool get isCompactScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1024;
  bool get isExpandedScreen => screenWidth >= 1024;

  // ─── Platform ────────────────────────────────────────────────────────────

  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  // ─── Theme shortcuts ─────────────────────────────────────────────────────

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ─── Snackbar ────────────────────────────────────────────────────────────

  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(
      this,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }
}
