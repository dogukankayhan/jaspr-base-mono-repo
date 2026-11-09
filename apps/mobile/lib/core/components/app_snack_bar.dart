import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/colors/app_brand_colors.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum SnackBarType { success, error, info, warning }

/// Usage:
///   AppSnackBar.show(context, message: 'Saved!', type: SnackBarType.success)
///   AppSnackBar.show(context, message: 'Error occurred', type: SnackBarType.error)
///   AppSnackBar.show(context,
///     message: 'Reversible',
///     type: SnackBarType.info,
///     actionLabel: 'Undo',
///     onAction: _undoDelete,
///   )
abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_icon(type), color: Colors.white, size: 18.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message,
                  style: context.textStyle.paragraph14Regular.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: _bgColor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          duration: duration,
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }

  static IconData _icon(SnackBarType type) => switch (type) {
    SnackBarType.success => Icons.check_circle_outline,
    SnackBarType.error => Icons.error_outline,
    SnackBarType.info => Icons.info_outline,
    SnackBarType.warning => Icons.warning_amber_outlined,
  };

  static Color _bgColor(SnackBarType type) => switch (type) {
    SnackBarType.success => AppBrandColors.success,
    SnackBarType.error => AppBrandColors.error,
    SnackBarType.info => AppBrandColors.primary,
    SnackBarType.warning => AppBrandColors.warn,
  };
}
