import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Usage:
///   context.showAppBottomSheet(
///     title: 'Filter',
///     child: FilterSheet(),
///   );
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.padding,
  });

  final Widget child;
  final String? title;
  final bool showDragHandle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle) ...[
              SizedBox(height: 8.h),
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.appColors.borderColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Text(title!, style: context.textStyle.display18Bold),
              ),
              Divider(height: 1.h),
            ],
            Padding(
              padding:
                  padding ??
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

extension AppBottomSheetExtension on BuildContext {
  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    String? title,
    bool showDragHandle = true,
    bool isScrollControlled = true,
    EdgeInsetsGeometry? padding,
  }) => showModalBottomSheet<T>(
    context: this,
    isScrollControlled: isScrollControlled,
    backgroundColor: appColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => AppBottomSheet(
      title: title,
      showDragHandle: showDragHandle,
      padding: padding,
      child: child,
    ),
  );
}
