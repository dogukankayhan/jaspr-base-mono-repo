import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_button.dart';

/// Usage:
///   AppEmptyState(title: 'No appointments found')
///   AppEmptyState(
///     title: 'No customers',
///     subtitle: 'You have not added any customers yet.',
///     icon: Icons.people_outline,
///     actionLabel: 'Add Customer',
///     onAction: () => CustomerNavigator.showCreate(context),
///   )
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64.w,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textStyle.display18Bold,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: context.textStyle.paragraph14Regular.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24.h),
              AppButton(label: actionLabel!, onPressed: onAction!),
            ],
          ],
        ),
      ),
    );
  }
}
