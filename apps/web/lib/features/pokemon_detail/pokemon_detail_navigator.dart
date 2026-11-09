import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'view/pokemon_detail_page.dart';

/// Owns the Pokémon detail route (CLAUDE.md Rule 5).
///
/// Web difference from mobile: screen data travels as a **path param**, not
/// `extra`. A web URL must survive reload / bookmarking / sharing, and
/// jaspr_router's `extra` only carries serializable primitives anyway — so the
/// page receives an id and its bloc loads the entity.
final class PokemonDetailNavigator {
  static const String path = '/pokemon/:id';

  static String location({required int id}) => '/pokemon/$id';

  static Route get route => Route(
    path: path,
    title: 'Pokémon',
    builder: (context, state) {
      final id = int.tryParse(state.params['id'] ?? '') ?? 1;
      // Keyed by id: navigating detail → detail (e.g. along the evolution
      // chain) must remount the page so BaseBlocView builds a fresh bloc.
      return PokemonDetailPage(key: ValueKey('pokemon-$id'), pokemonId: id);
    },
  );

  /// The ONLY programmatic way to open this page.
  static void show(BuildContext context, {required int id}) =>
      Router.of(context).push(location(id: id));

  /// An `<a>` to this page (see HomeNavigator.link).
  static Component link({
    required int id,
    required Component child,
    String? classes,
  }) => Link(
    to: location(id: id),
    classes: classes,
    child: child,
  );
}
