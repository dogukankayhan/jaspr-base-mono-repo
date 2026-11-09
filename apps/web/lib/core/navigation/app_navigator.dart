import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../features/pokemon_detail/pokemon_detail_navigator.dart';
import '../../features/pokemon_home/pokemon_home_navigator.dart';
// gen_feature: imports
import '../components/app_shell.dart';

/// Collects every feature navigator's route — the web twin of mobile's
/// `AppNavigator`. Add a feature here and nowhere else.
abstract final class AppNavigator {
  static List<RouteBase> get routes => [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        PokemonHomeNavigator.route,
        PokemonDetailNavigator.route,
        // gen_feature: routes
      ],
    ),
  ];

  static Component router() => Router(routes: routes);
}
