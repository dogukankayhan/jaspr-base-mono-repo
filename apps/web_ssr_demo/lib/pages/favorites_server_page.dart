import 'package:jaspr/jaspr.dart';

import '../islands/favorites_island.dart';

/// `/favorites` — the server sends the page shell; the list itself is per
/// visitor and is filled in the browser (see FavoritesIsland).
class FavoritesServerPage extends StatelessComponent {
  const FavoritesServerPage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      // Personal page: keep it out of search results.
      Document.head(
        title: 'Favorilerim · Pokédex',
        meta: {'robots': 'noindex,follow'},
      ),
      const FavoritesIsland(),
    ]);
  }
}
