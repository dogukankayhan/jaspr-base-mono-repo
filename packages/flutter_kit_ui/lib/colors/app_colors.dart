import 'package:flutter/material.dart';
import 'palette.dart';

/// Theme-adaptive semantic colors registered as a ThemeExtension.
///
/// Register to ThemeData:
///   ThemeData(extensions: [AppColors.light])
///
/// Access in Widget:
///   context.appColors.background
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    // ─── Surface ──────────────────────────────────────────
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.secondary,
    required this.disabledColor,
    required this.borderColor,
    required this.borderSecondary,
    required this.bgSecondary,
    required this.bgInfo,
    required this.highLight,
    required this.green,
    required this.container,
    required this.secondaryTextColor,
    required this.textColor,
    required this.primaryTitleColor,
    required this.secondaryContainer,
    required this.iconColor,
    required this.dropdownTextColor,
    required this.tertiaryButtonTextColor,
    required this.tertiaryContainerColor,
    required this.tertiaryIconColor,
    // ─── Primary button ───────────────────────────────────
    required this.primaryButtonBg,
    required this.primaryButtonBgBusy,
    required this.primaryButtonFg,
    required this.disabledButtonBg,
    required this.disabledButtonFg,
    // ─── Tertiary button ──────────────────────────────────
    required this.tertiaryButtonBg,
    required this.tertiaryButtonBorder,
    required this.tertiaryButtonBgBusy,
    required this.tertiaryButtonFgBusy,
    required this.tertiaryDisabledButtonBg,
    required this.tertiaryDisabledButtonBorder,
    required this.tertiaryDisabledButtonFg,
    // ─── Text field ───────────────────────────────────────
    required this.textFieldUnFocusBorder,
    required this.textFieldUnFocusText,
    required this.textFieldFocusBorder,
    required this.textFieldDisabledBorder,
    required this.textFieldDisabled,
  });

  // ─── Surface ────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color secondary;
  final Color disabledColor;
  final Color borderColor;
  final Color borderSecondary;
  final Color bgSecondary;
  final Color bgInfo;
  final Color highLight;
  final Color green;
  final Color container;
  final Color secondaryTextColor;
  final Color textColor;
  final Color primaryTitleColor;
  final Color secondaryContainer;
  final Color iconColor;
  final Color dropdownTextColor;
  final Color tertiaryButtonTextColor;
  final Color tertiaryContainerColor;
  final Color tertiaryIconColor;

  // ─── Primary button ─────────────────────────────────────
  final Color primaryButtonBg;
  final Color primaryButtonBgBusy;
  final Color primaryButtonFg;
  final Color disabledButtonBg;
  final Color disabledButtonFg;

  // ─── Tertiary button ────────────────────────────────────
  final Color tertiaryButtonBg;
  final Color tertiaryButtonBorder;
  final Color tertiaryButtonBgBusy;
  final Color tertiaryButtonFgBusy;
  final Color tertiaryDisabledButtonBg;
  final Color tertiaryDisabledButtonBorder;
  final Color tertiaryDisabledButtonFg;

  // ─── Text field ─────────────────────────────────────────
  final Color textFieldUnFocusBorder;
  final Color textFieldUnFocusText;
  final Color textFieldFocusBorder;
  final Color textFieldDisabledBorder;
  final Color textFieldDisabled;

  // ─── Light ──────────────────────────────────────────────
  static final AppColors light = AppColors(
    background: const Color(0xFFF5F6FA),
    surface: const Color(0xFFFFFFFF),
    onSurface: Palette.primary[100]!,
    secondary: const Color(0xFF717277),
    disabledColor: const Color(0xFFECEDED),
    borderColor: Palette.gray[20]!,
    borderSecondary: const Color(0xFFA0A1A4),
    bgSecondary: const Color(0xFFD9E6E9),
    bgInfo: const Color(0xFF619E45).withValues(alpha: .08),
    highLight: const Color(0xFFF2FBFD),
    green: const Color(0xFF00B69B),
    container: const Color(0xFFF5F5F6),
    secondaryTextColor: Palette.gray[50]!,
    textColor: const Color(0xFF000000),
    primaryTitleColor: Palette.primary[100]!,
    secondaryContainer: Palette.gray[10]!,
    iconColor: Palette.gray[100]!,
    dropdownTextColor: Palette.primary[100]!,
    tertiaryButtonTextColor: Palette.gray[100]!,
    tertiaryContainerColor: Palette.gray[10]!,
    tertiaryIconColor: Palette.gray[30]!,
    // Primary button
    primaryButtonBg: const Color(0xFF5b7dfb),
    primaryButtonBgBusy: const Color(0xFF3a55f7),
    primaryButtonFg: const Color(0xFFFFFFFF),
    disabledButtonBg: const Color(0xFFdbe2fe),
    disabledButtonFg: const Color(0xFF5b7dfb),
    // Tertiary button
    tertiaryButtonBg: const Color(0xFFFFFFFF),
    tertiaryButtonBorder: const Color(0xFF9847ff),
    tertiaryButtonBgBusy: const Color(0xFF8e3afa),
    tertiaryButtonFgBusy: const Color(0xFFFFFFFF),
    tertiaryDisabledButtonBg: Colors.transparent,
    tertiaryDisabledButtonBorder: const Color(0xFFd1aeff),
    tertiaryDisabledButtonFg: const Color(0xFFd1aeff),
    // Text field
    textFieldUnFocusBorder: const Color(0xFF8a91a6),
    textFieldUnFocusText: const Color(0xFF8a91a6),
    textFieldFocusBorder: const Color(0xFF3a55f7),
    textFieldDisabledBorder: const Color(0xFF8a91a6),
    textFieldDisabled: const Color(0xFF8a91a6),
  );

  // ─── Dark ───────────────────────────────────────────────
  static final AppColors dark = AppColors(
    background: Palette.colorGray[100]!,
    surface: const Color(0xFF333333),
    onSurface: Palette.white[10]!,
    secondary: const Color(0xFF323232),
    disabledColor: const Color(0xFF44454b),
    borderColor: Palette.colorGray[90]!,
    borderSecondary: const Color(0xFF717277),
    bgSecondary: const Color(0xFF2A3664),
    bgInfo: const Color(0xFF383C49),
    highLight: const Color(0xFF29424E),
    green: const Color(0xFF04F4D1),
    container: const Color(0xFF23283D),
    secondaryTextColor: Palette.colorGray[10]!,
    textColor: const Color(0xFFFFFFFF),
    primaryTitleColor: Palette.primary[40]!,
    secondaryContainer: Palette.colorGray[100]!,
    iconColor: Colors.white,
    dropdownTextColor: Colors.white,
    tertiaryButtonTextColor: Colors.white,
    tertiaryContainerColor: Palette.colorGray[80]!,
    tertiaryIconColor: Palette.colorGray[50]!,
    // Primary button — brand color remains the same in dark mode as well
    primaryButtonBg: const Color(0xFF5b7dfb),
    primaryButtonBgBusy: const Color(0xFF3a55f7),
    primaryButtonFg: const Color(0xFFFFFFFF),
    disabledButtonBg: Palette.colorGray[80]!,
    disabledButtonFg: Palette.primary[30]!,
    // Tertiary button
    tertiaryButtonBg: Palette.colorGray[80]!,
    tertiaryButtonBorder: Palette.tertiary[40]!,
    tertiaryButtonBgBusy: const Color(0xFF8e3afa),
    tertiaryButtonFgBusy: const Color(0xFFFFFFFF),
    tertiaryDisabledButtonBg: Colors.transparent,
    tertiaryDisabledButtonBorder: Palette.colorGray[60]!,
    tertiaryDisabledButtonFg: Palette.gray[40]!,
    // Text field
    textFieldUnFocusBorder: Palette.colorGray[60]!,
    textFieldUnFocusText: Palette.gray[30]!,
    textFieldFocusBorder: Palette.primary[30]!,
    textFieldDisabledBorder: Palette.colorGray[70]!,
    textFieldDisabled: Palette.colorGray[70]!,
  );

  // ─── ThemeExtension ─────────────────────────────────────
  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? onSurface,
    Color? secondary,
    Color? disabledColor,
    Color? borderColor,
    Color? borderSecondary,
    Color? bgSecondary,
    Color? bgInfo,
    Color? highLight,
    Color? green,
    Color? container,
    Color? secondaryTextColor,
    Color? textColor,
    Color? primaryTitleColor,
    Color? secondaryContainer,
    Color? iconColor,
    Color? dropdownTextColor,
    Color? tertiaryButtonTextColor,
    Color? tertiaryContainerColor,
    Color? tertiaryIconColor,
    Color? primaryButtonBg,
    Color? primaryButtonBgBusy,
    Color? primaryButtonFg,
    Color? disabledButtonBg,
    Color? disabledButtonFg,
    Color? tertiaryButtonBg,
    Color? tertiaryButtonBorder,
    Color? tertiaryButtonBgBusy,
    Color? tertiaryButtonFgBusy,
    Color? tertiaryDisabledButtonBg,
    Color? tertiaryDisabledButtonBorder,
    Color? tertiaryDisabledButtonFg,
    Color? textFieldUnFocusBorder,
    Color? textFieldUnFocusText,
    Color? textFieldFocusBorder,
    Color? textFieldDisabledBorder,
    Color? textFieldDisabled,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    onSurface: onSurface ?? this.onSurface,
    secondary: secondary ?? this.secondary,
    disabledColor: disabledColor ?? this.disabledColor,
    borderColor: borderColor ?? this.borderColor,
    borderSecondary: borderSecondary ?? this.borderSecondary,
    bgSecondary: bgSecondary ?? this.bgSecondary,
    bgInfo: bgInfo ?? this.bgInfo,
    highLight: highLight ?? this.highLight,
    green: green ?? this.green,
    container: container ?? this.container,
    secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
    textColor: textColor ?? this.textColor,
    primaryTitleColor: primaryTitleColor ?? this.primaryTitleColor,
    secondaryContainer: secondaryContainer ?? this.secondaryContainer,
    iconColor: iconColor ?? this.iconColor,
    dropdownTextColor: dropdownTextColor ?? this.dropdownTextColor,
    tertiaryButtonTextColor:
        tertiaryButtonTextColor ?? this.tertiaryButtonTextColor,
    tertiaryContainerColor:
        tertiaryContainerColor ?? this.tertiaryContainerColor,
    tertiaryIconColor: tertiaryIconColor ?? this.tertiaryIconColor,
    primaryButtonBg: primaryButtonBg ?? this.primaryButtonBg,
    primaryButtonBgBusy: primaryButtonBgBusy ?? this.primaryButtonBgBusy,
    primaryButtonFg: primaryButtonFg ?? this.primaryButtonFg,
    disabledButtonBg: disabledButtonBg ?? this.disabledButtonBg,
    disabledButtonFg: disabledButtonFg ?? this.disabledButtonFg,
    tertiaryButtonBg: tertiaryButtonBg ?? this.tertiaryButtonBg,
    tertiaryButtonBorder: tertiaryButtonBorder ?? this.tertiaryButtonBorder,
    tertiaryButtonBgBusy: tertiaryButtonBgBusy ?? this.tertiaryButtonBgBusy,
    tertiaryButtonFgBusy: tertiaryButtonFgBusy ?? this.tertiaryButtonFgBusy,
    tertiaryDisabledButtonBg:
        tertiaryDisabledButtonBg ?? this.tertiaryDisabledButtonBg,
    tertiaryDisabledButtonBorder:
        tertiaryDisabledButtonBorder ?? this.tertiaryDisabledButtonBorder,
    tertiaryDisabledButtonFg:
        tertiaryDisabledButtonFg ?? this.tertiaryDisabledButtonFg,
    textFieldUnFocusBorder:
        textFieldUnFocusBorder ?? this.textFieldUnFocusBorder,
    textFieldUnFocusText: textFieldUnFocusText ?? this.textFieldUnFocusText,
    textFieldFocusBorder: textFieldFocusBorder ?? this.textFieldFocusBorder,
    textFieldDisabledBorder:
        textFieldDisabledBorder ?? this.textFieldDisabledBorder,
    textFieldDisabled: textFieldDisabled ?? this.textFieldDisabled,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderSecondary: Color.lerp(borderSecondary, other.borderSecondary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgInfo: Color.lerp(bgInfo, other.bgInfo, t)!,
      highLight: Color.lerp(highLight, other.highLight, t)!,
      green: Color.lerp(green, other.green, t)!,
      container: Color.lerp(container, other.container, t)!,
      secondaryTextColor: Color.lerp(
        secondaryTextColor,
        other.secondaryTextColor,
        t,
      )!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      primaryTitleColor: Color.lerp(
        primaryTitleColor,
        other.primaryTitleColor,
        t,
      )!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      dropdownTextColor: Color.lerp(
        dropdownTextColor,
        other.dropdownTextColor,
        t,
      )!,
      tertiaryButtonTextColor: Color.lerp(
        tertiaryButtonTextColor,
        other.tertiaryButtonTextColor,
        t,
      )!,
      tertiaryContainerColor: Color.lerp(
        tertiaryContainerColor,
        other.tertiaryContainerColor,
        t,
      )!,
      tertiaryIconColor: Color.lerp(
        tertiaryIconColor,
        other.tertiaryIconColor,
        t,
      )!,
      primaryButtonBg: Color.lerp(primaryButtonBg, other.primaryButtonBg, t)!,
      primaryButtonBgBusy: Color.lerp(
        primaryButtonBgBusy,
        other.primaryButtonBgBusy,
        t,
      )!,
      primaryButtonFg: Color.lerp(primaryButtonFg, other.primaryButtonFg, t)!,
      disabledButtonBg: Color.lerp(
        disabledButtonBg,
        other.disabledButtonBg,
        t,
      )!,
      disabledButtonFg: Color.lerp(
        disabledButtonFg,
        other.disabledButtonFg,
        t,
      )!,
      tertiaryButtonBg: Color.lerp(
        tertiaryButtonBg,
        other.tertiaryButtonBg,
        t,
      )!,
      tertiaryButtonBorder: Color.lerp(
        tertiaryButtonBorder,
        other.tertiaryButtonBorder,
        t,
      )!,
      tertiaryButtonBgBusy: Color.lerp(
        tertiaryButtonBgBusy,
        other.tertiaryButtonBgBusy,
        t,
      )!,
      tertiaryButtonFgBusy: Color.lerp(
        tertiaryButtonFgBusy,
        other.tertiaryButtonFgBusy,
        t,
      )!,
      tertiaryDisabledButtonBg: Color.lerp(
        tertiaryDisabledButtonBg,
        other.tertiaryDisabledButtonBg,
        t,
      )!,
      tertiaryDisabledButtonBorder: Color.lerp(
        tertiaryDisabledButtonBorder,
        other.tertiaryDisabledButtonBorder,
        t,
      )!,
      tertiaryDisabledButtonFg: Color.lerp(
        tertiaryDisabledButtonFg,
        other.tertiaryDisabledButtonFg,
        t,
      )!,
      textFieldUnFocusBorder: Color.lerp(
        textFieldUnFocusBorder,
        other.textFieldUnFocusBorder,
        t,
      )!,
      textFieldUnFocusText: Color.lerp(
        textFieldUnFocusText,
        other.textFieldUnFocusText,
        t,
      )!,
      textFieldFocusBorder: Color.lerp(
        textFieldFocusBorder,
        other.textFieldFocusBorder,
        t,
      )!,
      textFieldDisabledBorder: Color.lerp(
        textFieldDisabledBorder,
        other.textFieldDisabledBorder,
        t,
      )!,
      textFieldDisabled: Color.lerp(
        textFieldDisabled,
        other.textFieldDisabled,
        t,
      )!,
    );
  }
}
