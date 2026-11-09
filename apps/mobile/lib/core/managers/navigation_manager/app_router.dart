import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../splash/splash_navigator.dart';
import 'app_navigator.dart';
import 'guards.dart';

export 'app_navigator.dart' show rootKey;

final class AppRouter {
  AppRouter._();

  static GoRouter create({
    required ChangeNotifier auth,
    String initialLocation = SplashNavigator.path,
  }) {
    final navigator = AppNavigator.instance;

    return GoRouter(
      navigatorKey: rootKey,
      initialLocation: initialLocation,
      refreshListenable: auth,
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) {
        if (state.uri.path == SplashNavigator.path) return null;
        return navigator.redirect(
          isLoggedIn: (auth as AuthRouterNotifier).isLoggedIn,
          path: state.uri.path,
        );
      },
      routes: [SplashNavigator.route(rootKey), ...navigator.routes],
    );
  }
}
