import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/login/login_navigator.dart';
import '../../../features/register/register_navigator.dart';
import '../../../features/shell/shell_navigator.dart';
import '../../config/app_environment.dart';

/// Root navigator key — all routes open via this key.
///
/// GoRouter is not taken as constructor parameter here or from GetIt
/// not pulled because this leads to navigation → auth → firebase cycle.
/// Instead, the [NotificationDeepLinkHandler.onNavigate] callback is
/// set at app startup — firebase package does not import router.
final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final class AppNavigator {
  AppNavigator._()
    : login = LoginNavigator(rootKey),
      register = RegisterNavigator(rootKey),
      shell = ShellNavigator();

  static final instance = AppNavigator._();

  final LoginNavigator login;
  final RegisterNavigator register;
  final ShellNavigator shell;

  List<RouteBase> get routes => [login.route, register.route, shell.route];

  static const _shellPaths = {
    ShellNavigator.appointmentsPath,
    ShellNavigator.pokemonPath,
    ShellNavigator.componentsPath,
  };

  String? redirect({required bool isLoggedIn, required String path}) {
    if (AppConfig.instance.isDev) return null;
    if (!isLoggedIn) {
      if (_shellPaths.contains(path)) return LoginNavigator.path;
    } else {
      if (path == LoginNavigator.path || path == RegisterNavigator.path) {
        return ShellNavigator.pokemonPath;
      }
    }
    return null;
  }
}
