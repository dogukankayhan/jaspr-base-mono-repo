import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../colors/app_brand_colors.dart';
import '../colors/app_colors.dart';
import '../colors/palette.dart';
import '../typography/app_text_theme.dart';

sealed class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────
  static ThemeData get light {
    final appColors = AppColors.light;
    final colorScheme = _buildColorScheme(appColors, Brightness.light);
    return _buildTheme(colorScheme, appColors, Brightness.light);
  }

  // ─── Dark Theme ───────────────────────────────────────
  static ThemeData get dark {
    final appColors = AppColors.dark;
    final colorScheme = _buildColorScheme(appColors, Brightness.dark);
    return _buildTheme(colorScheme, appColors, Brightness.dark);
  }

  // ─── ColorScheme builder ──────────────────────────────
  static ColorScheme _buildColorScheme(AppColors c, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: AppBrandColors.primary,
      onPrimary: AppBrandColors.onPrimary,
      primaryContainer: AppBrandColors.primaryContainer,
      onPrimaryContainer: AppBrandColors.onPrimaryContainer,
      secondary: c.secondary,
      onSecondary: AppBrandColors.onSecondary,
      secondaryContainer: c.secondaryContainer,
      onSecondaryContainer: AppBrandColors.onSecondaryContainer,
      tertiary: AppBrandColors.tertiary,
      onTertiary: AppBrandColors.onPrimary,
      tertiaryContainer: c.tertiaryContainerColor,
      onTertiaryContainer: AppBrandColors.onTertiaryContainer,
      error: AppBrandColors.error,
      onError: AppBrandColors.onPrimary,
      errorContainer: Palette.fourth[10]!, // fourth[10]
      onErrorContainer: Palette.fourth[100]!, // fourth[100]
      surface: c.surface,
      onSurface: c.onSurface,
      surfaceContainer: c.container,
      surfaceContainerHighest: c.disabledColor,
      outline: c.borderColor,
      outlineVariant: c.borderSecondary,
      shadow: AppBrandColors.shadow,
      inverseSurface: brightness == Brightness.light
          ? Palette.colorGray[100]! // colorGray[100]
          : Palette.white[10]!, // white[10]
      onInverseSurface: brightness == Brightness.light
          ? Palette.white[10]! // white[10]
          : Palette.colorGray[100]!, // colorGray[100]
      inversePrimary: AppBrandColors.inversePrimary,
      scrim: Colors.black,
    );
  }

  // ─── ThemeData builder ────────────────────────────────
  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    AppColors appColors,
    Brightness brightness,
  ) {
    final isLight = brightness == Brightness.light;
    final textTheme = AppTextTheme.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: appColors.background,
      extensions: [appColors],

      // ─── AppBar ─────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // ─── Card ───────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
        color: colorScheme.surface,
      ),

      // ─── FilledButton ───────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── OutlinedButton ─────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── TextButton ─────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── Input ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),

      // ─── BottomNavigationBar ────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 0,
      ),

      // ─── NavigationBar (Material 3) ─────────────────
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),

      // ─── Divider ────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.5,
        space: 0,
      ),

      // ─── Chip ───────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ─── Dialog ─────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
      ),

      // ─── BottomSheet ────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: colorScheme.surface,
        showDragHandle: true,
      ),

      // ─── SnackBar ───────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ─── Switch ─────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(colorScheme.primary),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // ─── ListTile ───────────────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
