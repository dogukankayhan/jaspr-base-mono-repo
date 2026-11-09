import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_navigator.dart' show rootKey;

/// Low-level navigator helpers.
///
/// Used to access root navigator without context or post-frame.
/// used. For feature coordination use AppNavigator.instance.
final class Nav {
  Nav._();

  static bool canPopRoot() => rootKey.currentState?.canPop() ?? false;

  static void popRoot<T extends Object?>([T? result]) =>
      rootKey.currentState?.pop<T>(result);

  static void goPostFrame(BuildContext context, String path, {Object? extra}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(path, extra: extra);
    });
  }

  static void pushPostFrame(
    BuildContext context,
    String path, {
    Object? extra,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.push(path, extra: extra);
    });
  }

  static void popPostFrame(BuildContext context, [Object? result]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted && context.canPop()) context.pop(result);
    });
  }

  static void popRootPostFrame([Object? result]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (canPopRoot()) popRoot(result);
    });
  }
}
