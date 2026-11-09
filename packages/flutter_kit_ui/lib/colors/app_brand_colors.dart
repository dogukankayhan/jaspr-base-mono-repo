import 'package:flutter/material.dart';
import 'package:kit_design_tokens/kit_design_tokens.dart';

/// Constant (mode independent) brand colors.
///
/// All values are compile-time const — no runtime allocation.
/// Does not require context: AppBrandColors.gold, AppBrandColors.primary
///
/// For rarely used shades: Palette.primary[30]!
abstract final class AppBrandColors {
  // ─── Primary palette shortcuts ────────────────────────
  static const Color primary = Color(BrandTokens.primary); // primary[40]
  static const Color primaryBusy = Color(BrandTokens.primaryBusy); // primary[50]
  static const Color primaryContainer = Color(BrandTokens.primaryContainer); // primary[10]
  static const Color onPrimaryContainer = Color(BrandTokens.onPrimaryContainer); // primary[100]
  static const Color inversePrimary = Color(BrandTokens.inversePrimary); // primary[30]

  // ─── Secondary palette shortcuts ──────────────────────
  static const Color secondaryPalette = Color(BrandTokens.secondaryPalette); // secondary[40]
  static const Color secondaryContainer = Color(BrandTokens.secondaryContainer); // secondary[10]
  static const Color onSecondaryContainer = Color(BrandTokens.onSecondaryContainer); // secondary[100]

  // ─── Tertiary palette shortcuts ───────────────────────
  static const Color tertiary = Color(BrandTokens.tertiary); // tertiary[40]
  static const Color tertiaryContainer = Color(BrandTokens.tertiaryContainer); // tertiary[10]
  static const Color onTertiaryContainer = Color(BrandTokens.onTertiaryContainer); // tertiary[100]

  // ─── On-colors ────────────────────────────────────────
  static const Color onPrimary = Color(BrandTokens.onPrimary);
  static const Color onSecondary = Color(BrandTokens.onSecondary);
  static const Color onError = Color(BrandTokens.onError);

  // ─── Semantic ─────────────────────────────────────────
  static const Color error = Color(BrandTokens.error);
  static const Color helper = Color(BrandTokens.helper);
  static const Color success = Color(BrandTokens.success);
  static const Color warn = Color(BrandTokens.warn);
  static const Color info = Color(BrandTokens.info);
  static const Color primaryLight = Color(BrandTokens.primaryLight);
  static const Color successLight = Color(BrandTokens.successLight);

  // ─── Brand ────────────────────────────────────────────
  static const Color gold = Color(BrandTokens.gold);
  static const Color goldLight = Color(BrandTokens.goldLight);
  static const Color ceil = Color(BrandTokens.ceil);
  static const Color textBlack = Color(BrandTokens.textBlack);
  static const Color blueShadow = Color(BrandTokens.blueShadow);
  static const Color grayBase = Color(BrandTokens.grayBase);
  static const Color grayDark = Color(BrandTokens.grayDark);
  static const Color grayLight = Color(BrandTokens.grayLight);
  static const Color shadowGreen = Color(BrandTokens.shadowGreen);
  static const Color tanHide = Color(BrandTokens.tanHide);
  static const Color goldenTainoi = Color(BrandTokens.goldenTainoi);

  // ─── Shadows (withValues → const olamaz) ─────────────
  static final Color shadow = const Color(0xFF000000).withValues(alpha: 0.08);
  static final Color shadowBlack = const Color(
    0xFF000000,
  ).withValues(alpha: 0.5);

  // ─── Mode-consistent ──────────────────────────────────
  static const Color secondaryTitleColor = Color(BrandTokens.secondaryTitleColor); // colorGray[50]
  static const Color selectedTabIconColor = Color(BrandTokens.selectedTabIconColor); // primary[40]
  static const Color unSelectedTabIconColor = Color(BrandTokens.unSelectedTabIconColor); // gray[50]

  // ─── Gradients ────────────────────────────────────────
  static const LinearGradient mainGradient = LinearGradient(
    colors: [
      Color(0xFF3ad7f2),
      Color(0xFF5b7dfb),
    ], // secondary[40] → primary[40]
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [
      Color(0xFFf588ff),
      Color(0xFF8e3afa),
    ], // fourth[40ish] → tertiary[60]
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
