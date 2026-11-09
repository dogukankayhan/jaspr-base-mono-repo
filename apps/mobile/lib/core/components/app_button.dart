import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/enums/app_icon.dart';
import 'package:flutter_kit_ui/colors/app_colors.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ButtonVariant { primary, tertiary }

enum ButtonSize { small, medium, large }

/// Usage examples:
///
///   AppButton(label: 'Continue', onPressed: _submit)
///   AppButton(label: 'Save', prefixIcon: SvgIcon.save, isLoading: _loading)
///   AppButton(label: 'Cancel', variant: ButtonVariant.tertiary, onPressed: _cancel)
///   AppButton(label: 'Submit', suffixIcon: SvgIcon.arrowRight, fullWidth: true)
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.isEnabled = true,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;

  /// Icon enum value — color automatically set based on button state.
  final SvgIcon? prefixIcon;
  final SvgIcon? suffixIcon;

  final bool isLoading;
  final bool isEnabled;

  /// true → double.infinity width
  final bool fullWidth;

  // ─── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (width, height) = _dimensions;

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: _effectiveCallback,
        style: _resolveStyle(colors),
        child: _buildChild(context, colors),
      ),
    );
  }

  // ─── Child ──────────────────────────────────────────────
  Widget _buildChild(BuildContext context, AppColors colors) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 18.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _fgColor(colors, enabled: true),
        ),
      );
    }

    final ts = _textStyle(context, colors);
    final iconColor = _fgColor(colors, enabled: isEnabled);

    if (prefixIcon == null && suffixIcon == null) {
      return Text(label, style: ts);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!.call(color: iconColor, width: 18.w, height: 18.w),
          SizedBox(width: 8.w),
        ],
        Text(label, style: ts),
        if (suffixIcon != null) ...[
          SizedBox(width: 8.w),
          suffixIcon!.call(color: iconColor, width: 18.w, height: 18.w),
        ],
      ],
    );
  }

  // ─── Style ──────────────────────────────────────────────
  ButtonStyle _resolveStyle(AppColors colors) {
    final base = _baseStyle(colors);
    return switch (variant) {
      ButtonVariant.primary => base,
      ButtonVariant.tertiary => base.copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BorderSide(color: colors.tertiaryDisabledButtonBorder);
          }
          return BorderSide(color: colors.tertiaryButtonBorder);
        }),
      ),
    };
  }

  ButtonStyle _baseStyle(AppColors colors) {
    return switch (variant) {
      ButtonVariant.primary => ElevatedButton.styleFrom(
        backgroundColor: isLoading
            ? colors.primaryButtonBgBusy
            : colors.primaryButtonBg,
        foregroundColor: colors.primaryButtonFg,
        disabledBackgroundColor: colors.disabledButtonBg,
        disabledForegroundColor: colors.disabledButtonFg,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      ButtonVariant.tertiary => ElevatedButton.styleFrom(
        backgroundColor: isLoading
            ? colors.tertiaryButtonBgBusy
            : colors.tertiaryButtonBg,
        foregroundColor: isLoading
            ? colors.tertiaryButtonFgBusy
            : colors.tertiaryButtonTextColor,
        disabledBackgroundColor: colors.tertiaryDisabledButtonBg,
        disabledForegroundColor: colors.tertiaryDisabledButtonFg,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    };
  }

  // ─── Helpers ────────────────────────────────────────────

  /// Empty callback to prevent disabled styling during loading.
  VoidCallback? get _effectiveCallback {
    if (isLoading) {
      return () {}; // enabled look is preserved, clicking is prevented
    }
    if (!isEnabled) return null; // Flutter disabled styling takes effect
    return onPressed;
  }

  Color _fgColor(AppColors colors, {required bool enabled}) {
    return switch (variant) {
      ButtonVariant.primary =>
        enabled ? colors.primaryButtonFg : colors.disabledButtonFg,
      ButtonVariant.tertiary =>
        enabled
            ? colors.tertiaryButtonTextColor
            : colors.tertiaryDisabledButtonFg,
    };
  }

  TextStyle _textStyle(BuildContext context, AppColors colors) {
    final style = switch (size) {
      ButtonSize.small => context.textStyle.button12Bold,
      ButtonSize.medium => context.textStyle.button14Bold,
      ButtonSize.large => context.textStyle.button16Bold,
    };
    return style.copyWith(color: _fgColor(colors, enabled: isEnabled));
  }

  (double width, double height) get _dimensions => switch (size) {
    ButtonSize.small => (164.w, 36.h),
    ButtonSize.medium => (185.w, 40.h),
    ButtonSize.large => (205.w, 48.h),
  };
}
