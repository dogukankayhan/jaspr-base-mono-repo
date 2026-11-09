import 'package:flutter/material.dart';
import 'package:flutter_kit_ui/colors/app_brand_colors.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Usage examples:
///
///   AppCard(child: Text('Content'))
///   AppCard(child: Text('Clickable'), onTap: _onTap)
///   AppCard(child: _Content(), padding: EdgeInsets.all(16), elevation: 0)
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
    this.elevation,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16.r);
    final bg = backgroundColor ?? context.appColors.surface;
    final elev = elevation ?? 0.0;

    final content = Padding(
      padding: padding ?? EdgeInsets.all(16.w),
      child: child,
    );

    return Material(
      color: bg,
      borderRadius: radius,
      elevation: elev,
      shadowColor: AppBrandColors.shadow,
      child: onTap != null
          ? InkWell(onTap: onTap, borderRadius: radius, child: content)
          : content,
    );
  }
}
