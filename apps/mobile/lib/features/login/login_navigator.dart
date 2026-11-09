import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/managers/navigation_manager/guards.dart';
import 'view/login_screen.dart';

final class LoginNavigator {
  const LoginNavigator(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  static const String path = '/login';

  void show() => navigatorKey.currentState?.context.go(path);

  GoRoute get route => GoRoute(
    path: path,
    parentNavigatorKey: navigatorKey,
    pageBuilder: (context, state) =>
        fadeTransitionPage(key: state.pageKey, child: const LoginScreen()),
  );
}
