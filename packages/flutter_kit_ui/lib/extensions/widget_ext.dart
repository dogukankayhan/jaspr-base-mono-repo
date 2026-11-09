import 'package:flutter/material.dart';

extension WidgetExt on Widget {
  /// Returns this widget when [visible] is true, otherwise collapses to nothing.
  Widget visibleIf(bool visible) => visible ? this : const SizedBox.shrink();

  /// Dims and blocks interaction with this widget when [disabled] is true.
  Widget disabledIf(bool disabled, {double opacity = 0.4}) => IgnorePointer(
    ignoring: disabled,
    child: Opacity(opacity: disabled ? opacity : 1, child: this),
  );

  /// Wraps this widget so it can be used directly as a sliver in a [CustomScrollView].
  Widget get sliver => SliverToBoxAdapter(child: this);
}
