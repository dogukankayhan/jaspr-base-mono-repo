// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit managing theme state.
///
/// Supports 3 modes:
/// - [ThemeMode.system] → follows device settings (default)
/// - [ThemeMode.light]  → always light
/// - [ThemeMode.dark]   → always dark
///
/// Selection is persisted with [SharedPreferences].
///
/// Usage:
///   context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
///   context.read<ThemeCubit>().toggleTheme();
///
///   // Listening in Widget:
///   BlocBuilder<ThemeCubit, ThemeMode>(
///     builder: (context, mode) => MaterialApp(themeMode: mode, ...),
///   )
class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.system);

  /// Load saved theme mode from SharedPreferences.
  /// Must be called at app startup.
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => ThemeMode.system,
      );
      emit(mode);
    }
  }

  /// Change and save theme mode.
  /// If System selected, record is deleted → next startup defaults to system.
  Future<void> setThemeMode(ThemeMode mode) async {
    debugPrint('[ThemeCubit] setThemeMode → ${mode.name}');
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.system) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, mode.name);
    }
  }

  /// Toggle between Light ↔ Dark.
  /// Reverses based on current brightness when in System mode.
  Future<void> toggleTheme([BuildContext? context]) async {
    if (context != null) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      debugPrint(brightness.name);
    }
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // In system mode → look at current brightness
      if (context != null) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        await setThemeMode(
          brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
        );
      } else {
        await setThemeMode(ThemeMode.dark);
      }
    }
  }

  /// Check if current mode is dark.
  bool isDark([BuildContext? context]) {
    if (state == ThemeMode.dark) return true;
    if (state == ThemeMode.light) return false;
    // System mode
    if (context != null) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return false;
  }
}
