import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/managers/navigation_manager/guards.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('AuthGate login flow: /settings requires login', (tester) async {
    final auth = TestAuthRouterNotifier();

    final router = GoRouter(
      initialLocation: '/settings',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isLoggedIn;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isLoggedIn && state.uri.toString() == '/settings') {
          return '/login';
        }
        if (isLoggedIn && isLoggingIn) {
          return '/settings';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const Scaffold(body: Text('Ayarlar')),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Giriş')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.pumpAndSettle();
    expect(find.text('Giriş'), findsOneWidget);

    auth.signIn();
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget);
  });
}
