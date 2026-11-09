import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'splash_screen.dart';

final class SplashNavigator {
  SplashNavigator._();

  static const String path = '/splash';

  static GoRoute route(GlobalKey<NavigatorState> parentKey) {
    return GoRoute(
      path: path,
      parentNavigatorKey: parentKey,
      builder: (context, state) => const SplashScreen(),
    );
  }
}
