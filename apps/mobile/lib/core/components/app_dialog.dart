// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_button.dart';

/// Usage:
///   context.showAppDialog(
///     title: 'Log Out',
///     content: 'Are you sure you want to log out?',
///     primaryLabel: 'Log Out',
///     onPrimary: () { context.read<AuthBloc>().add(LogoutRequested()); },
///     secondaryLabel: 'Cancel',
///   );
///
///   context.showAppDialog(title: 'Deleted', content: 'Appointment cancelled.');
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.primaryLabel = 'OK',
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
  });

  final String title;
  final String content;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.textStyle.display20Bold),
            SizedBox(height: 12.h),
            Text(content, style: context.textStyle.paragraph14Regular),
            SizedBox(height: 24.h),
            Row(
              children: [
                if (secondaryLabel != null) ...[
                  Expanded(
                    child: AppButton(
                      label: secondaryLabel!,
                      variant: ButtonVariant.tertiary,
                      onPressed:
                          onSecondary ?? () => Navigator.of(context).pop(),
                      fullWidth: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: AppButton(
                    label: primaryLabel,
                    onPressed: onPrimary ?? () => Navigator.of(context).pop(),
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension AppDialogExtension on BuildContext {
  Future<T?> showAppDialog<T>({
    required String title,
    required String content,
    String primaryLabel = 'OK',
    String? secondaryLabel,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    bool isDismissible = true,
  }) => showDialog<T>(
    context: this,
    barrierDismissible: isDismissible,
    builder: (_) => AppDialog(
      title: title,
      content: content,
      primaryLabel: primaryLabel,
      secondaryLabel: secondaryLabel,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
    ),
  );
}
