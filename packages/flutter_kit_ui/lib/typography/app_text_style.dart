import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Context-aware text styles using Plus Jakarta Sans via Google Fonts.
///
/// Usage:
///   AppTextStyle(context).display32Bold
///   AppTextStyle(context).paragraph14Medium
final class AppTextStyle {
  final BuildContext context;
  AppTextStyle(this.context);

  ColorScheme get _cs => Theme.of(context).colorScheme;

  TextStyle _base({
    required double size,
    required FontWeight weight,
    double? height,
  }) => GoogleFonts.plusJakartaSans(
    textStyle: TextStyle(
      color: _cs.onSurface,
      fontSize: size.sp,
      fontWeight: weight,
      height: height,
    ),
  );

  // ─── Display 32 ────────────────────────────────────────
  TextStyle get display32Bold =>
      _base(size: 32, weight: FontWeight.w700, height: 44 / 32);
  TextStyle get display32SemiBold =>
      _base(size: 32, weight: FontWeight.w600, height: 44 / 32);
  TextStyle get display32Medium =>
      _base(size: 32, weight: FontWeight.w500, height: 44 / 32);
  TextStyle get display32Regular =>
      _base(size: 32, weight: FontWeight.w400, height: 44 / 32);

  // ─── Display 28 ────────────────────────────────────────
  TextStyle get display28Bold =>
      _base(size: 28, weight: FontWeight.w700, height: 40 / 28);
  TextStyle get display28SemiBold =>
      _base(size: 28, weight: FontWeight.w600, height: 40 / 28);
  TextStyle get display28Medium =>
      _base(size: 28, weight: FontWeight.w500, height: 40 / 28);
  TextStyle get display28Regular =>
      _base(size: 28, weight: FontWeight.w400, height: 40 / 28);

  // ─── Display 24 ────────────────────────────────────────
  TextStyle get display24Bold =>
      _base(size: 24, weight: FontWeight.w700, height: 36 / 24);
  TextStyle get display24SemiBold =>
      _base(size: 24, weight: FontWeight.w600, height: 36 / 24);
  TextStyle get display24Medium =>
      _base(size: 24, weight: FontWeight.w500, height: 36 / 24);
  TextStyle get display24Regular =>
      _base(size: 24, weight: FontWeight.w400, height: 36 / 24);

  // ─── Display 20 ────────────────────────────────────────
  TextStyle get display20Bold =>
      _base(size: 20, weight: FontWeight.w700, height: 32 / 20);
  TextStyle get display20SemiBold =>
      _base(size: 20, weight: FontWeight.w600, height: 32 / 20);
  TextStyle get display20Medium =>
      _base(size: 20, weight: FontWeight.w500, height: 32 / 20);
  TextStyle get display20Regular =>
      _base(size: 20, weight: FontWeight.w400, height: 32 / 20);

  // ─── Display 18 ────────────────────────────────────────
  TextStyle get display18Bold =>
      _base(size: 18, weight: FontWeight.w700, height: 28 / 18);
  TextStyle get display18SemiBold =>
      _base(size: 18, weight: FontWeight.w600, height: 28 / 18);
  TextStyle get display18Medium =>
      _base(size: 18, weight: FontWeight.w500, height: 28 / 18);
  TextStyle get display18Regular =>
      _base(size: 18, weight: FontWeight.w400, height: 28 / 18);

  // ─── Display 16 ────────────────────────────────────────
  TextStyle get display16Bold =>
      _base(size: 16, weight: FontWeight.w700, height: 24 / 16);
  TextStyle get display16SemiBold =>
      _base(size: 16, weight: FontWeight.w600, height: 24 / 16);
  TextStyle get display16Medium =>
      _base(size: 16, weight: FontWeight.w500, height: 24 / 16);
  TextStyle get display16Regular =>
      _base(size: 16, weight: FontWeight.w400, height: 24 / 16);

  // ─── Title 18 ──────────────────────────────────────────
  TextStyle get title18Bold =>
      _base(size: 18, weight: FontWeight.w700, height: 28 / 18);
  TextStyle get title18SemiBold =>
      _base(size: 18, weight: FontWeight.w600, height: 28 / 18);
  TextStyle get title18Medium =>
      _base(size: 18, weight: FontWeight.w500, height: 28 / 18);
  TextStyle get title18Regular =>
      _base(size: 18, weight: FontWeight.w400, height: 28 / 18);

  // ─── Title 16 ──────────────────────────────────────────
  TextStyle get title16Bold =>
      _base(size: 16, weight: FontWeight.w700, height: 24 / 16);
  TextStyle get title16SemiBold =>
      _base(size: 16, weight: FontWeight.w600, height: 24 / 16);
  TextStyle get title16Medium =>
      _base(size: 16, weight: FontWeight.w500, height: 24 / 16);
  TextStyle get title16Regular =>
      _base(size: 16, weight: FontWeight.w400, height: 24 / 16);

  // ─── Paragraph 16 ──────────────────────────────────────
  TextStyle get paragraph16Bold =>
      _base(size: 16, weight: FontWeight.w700, height: 24 / 16);
  TextStyle get paragraph16SemiBold =>
      _base(size: 16, weight: FontWeight.w600, height: 24 / 16);
  TextStyle get paragraph16Medium =>
      _base(size: 16, weight: FontWeight.w500, height: 24 / 16);
  TextStyle get paragraph16Regular =>
      _base(size: 16, weight: FontWeight.w400, height: 24 / 16);

  // ─── Paragraph 14 ──────────────────────────────────────
  TextStyle get paragraph14Bold =>
      _base(size: 14, weight: FontWeight.w700, height: 22 / 14);
  TextStyle get paragraph14SemiBold =>
      _base(size: 14, weight: FontWeight.w600, height: 22 / 14);
  TextStyle get paragraph14Medium =>
      _base(size: 14, weight: FontWeight.w500, height: 22 / 14);
  TextStyle get paragraph14Regular =>
      _base(size: 14, weight: FontWeight.w400, height: 22 / 14);

  // ─── Paragraph 12 ──────────────────────────────────────
  TextStyle get paragraph12Bold =>
      _base(size: 12, weight: FontWeight.w700, height: 22 / 12);
  TextStyle get paragraph12SemiBold =>
      _base(size: 12, weight: FontWeight.w600, height: 22 / 12);
  TextStyle get paragraph12Medium =>
      _base(size: 12, weight: FontWeight.w500, height: 22 / 12);
  TextStyle get paragraph12Regular =>
      _base(size: 12, weight: FontWeight.w400, height: 22 / 12);

  // ─── Paragraph 10 ──────────────────────────────────────
  TextStyle get paragraph10Bold => _base(size: 10, weight: FontWeight.w700);

  // ─── Button 16 ─────────────────────────────────────────
  TextStyle get button16Bold =>
      _base(size: 16, weight: FontWeight.w700, height: 24 / 16);
  TextStyle get button16SemiBold =>
      _base(size: 16, weight: FontWeight.w600, height: 24 / 16);
  TextStyle get button16Medium =>
      _base(size: 16, weight: FontWeight.w500, height: 24 / 16);
  TextStyle get button16Regular =>
      _base(size: 16, weight: FontWeight.w400, height: 24 / 16);

  // ─── Button 14 ─────────────────────────────────────────
  TextStyle get button14Bold =>
      _base(size: 14, weight: FontWeight.w700, height: 24 / 14);
  TextStyle get button14SemiBold =>
      _base(size: 14, weight: FontWeight.w600, height: 24 / 14);
  TextStyle get button14Medium =>
      _base(size: 14, weight: FontWeight.w500, height: 24 / 14);
  TextStyle get button14Regular =>
      _base(size: 14, weight: FontWeight.w400, height: 24 / 14);

  // ─── Button 12 ─────────────────────────────────────────
  TextStyle get button12Bold => _base(size: 12, weight: FontWeight.w700);
  TextStyle get button12SemiBold =>
      _base(size: 12, weight: FontWeight.w600, height: 20 / 12);
  TextStyle get button12Medium =>
      _base(size: 12, weight: FontWeight.w500, height: 20 / 12);
  TextStyle get button12Regular =>
      _base(size: 12, weight: FontWeight.w400, height: 20 / 12);
}

/// Shortcut access via context — `context.ts` instead of `AppTextStyle(context)`.
///
/// Example:
///   context.textStyle.title16Bold
///   context.textStyle.paragraph14Regular
extension AppTextStyleX on BuildContext {
  AppTextStyle get textStyle => AppTextStyle(this);
}
