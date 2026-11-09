import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_kit_auth/auth/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

/// Bridges GoRouter by listening to AuthBloc.
/// Does not maintain its own state; the single source of truth is AuthBloc.
class AuthRouterNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;
  late StreamSubscription _sub;

  AuthRouterNotifier(this._authBloc) {
    _sub = _authBloc.stream.listen((_) => notifyListeners());
  }

  bool get isLoggedIn => _authBloc.state.isAuthenticated;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// For test environment — works without requiring AuthBloc.
@visibleForTesting
class TestAuthRouterNotifier extends ChangeNotifier {
  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;

  void signIn() {
    _loggedIn = true;
    notifyListeners();
  }

  void signOut() {
    _loggedIn = false;
    notifyListeners();
  }
}

String? requireAuth(AuthRouterNotifier auth, GoRouterState state) {
  if (auth.isLoggedIn) return null;
  final next = Uri.encodeComponent(state.uri.toString());
  return '/login?next=$next';
}

Page<T> fadeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 180),
}) => CustomTransitionPage<T>(
  key: key,
  child: child,
  transitionsBuilder: (c, a, sA, w) => FadeTransition(opacity: a, child: w),
  transitionDuration: duration,
);
