import 'package:go_router/go_router.dart';

import 'view/components_screen.dart';

final class ComponentsNavigator {
  static const String componentsPath = '/components';

  GoRoute get route => GoRoute(
    path: componentsPath,
    builder: (_, _) => const ComponentsScreen(),
  );
}
