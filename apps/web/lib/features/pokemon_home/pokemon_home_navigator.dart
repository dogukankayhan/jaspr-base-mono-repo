import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'view/pokemon_home_page.dart';

/// Owns the home route (CLAUDE.md Rule 5).
///
/// The active search / type filter lives in the URL (`/?q=pika`,
/// `/?type=fire`) so a result set survives reload, can be shared, and is
/// restored when the user comes Back from a detail page.
final class PokemonHomeNavigator {
  static const String path = '/';
  static const String queryParam = 'q';
  static const String typeParam = 'type';

  /// URL for a result set. A type filter wins over a search (as in the bloc).
  static String location({String? query, String? type}) {
    final q = query?.trim();
    final params = <String, String>{
      typeParam: ?type,
      if (type == null && q != null && q.isNotEmpty) queryParam: q,
    };
    return Uri(
      path: path,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
  }

  static Route get route => Route(
    path: path,
    title: 'Pokédex',
    builder: (context, state) => PokemonHomePage(
      initialQuery: state.queryParams[queryParam],
      initialType: state.queryParams[typeParam],
    ),
  );

  /// Opens the home page, optionally on a given result set.
  static void show(BuildContext context, {String? query, String? type}) =>
      Router.of(context).push(location(query: query, type: type));

  /// Mirrors the page's current result set into the URL without adding a
  /// history entry (typing must not fill the Back stack).
  static void syncUrl(BuildContext context, {String? query, String? type}) {
    final target = location(query: query, type: type);
    if (context.url != target) Router.of(context).replace(target);
  }

  /// An `<a>` to the home page.
  static Component link({required Component child, String? classes}) =>
      Link(to: path, classes: classes, child: child);
}
