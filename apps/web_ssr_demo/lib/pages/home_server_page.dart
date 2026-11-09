import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:app_shared/domain/usecase/filter_pokemon_by_type_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_page_usecase.dart';
import 'package:app_shared/domain/usecase/search_pokemon_usecase.dart';
import 'package:jaspr/server.dart';
import 'package:kit_core/utils/extensions/string_ext.dart';
import 'package:kit_network/core/di/locator.dart';

import '../codec/home_seed.dart';
import '../config.dart';
import '../islands/pokemon_home_island.dart';
import '../routes.dart';
import '../seo/seo.dart';
import 'not_found_page.dart';

/// Home page, rendered **on the server for every request**.
///
/// Serves `/`, `/?type=fire`, `/?q=pika` and their `&page=N` pages. Each page
/// is a crawlable URL with its own HTML — bots can't trigger infinite scroll,
/// so the island also renders real "next/previous page" links.
class HomeServerPage extends AsyncStatelessComponent {
  const HomeServerPage({this.query, this.type, this.page = 1, super.key});

  final String? query;
  final String? type;
  final int page;

  @override
  Future<Component> build(BuildContext context) async {
    if (page < 1) return const NotFoundPage();

    final repo = getIt<PokemonRepository>();
    final type = this.type;
    final q = type == null ? query?.trim() : null;
    final hasQuery = q != null && q.isNotEmpty;
    final offset = (page - 1) * pageSize;

    final (items, hasMore, nextOffset) = await switch ((type, hasQuery)) {
      (final t?, _) => FilterPokemonByTypeUseCase(repo)(
        type: t,
        size: pageSize,
        offset: offset,
      ),
      (null, true) => SearchPokemonUseCase(repo)(
        query: q!,
        size: pageSize,
        offset: offset,
      ),
      _ => GetPokemonPageUseCase(repo)(size: pageSize, offset: offset),
    };
    // Past the last page → 404 instead of an empty, indexable page.
    if (items.isEmpty && page > 1) return const NotFoundPage();

    final seed = HomeSeed(
      items: items,
      hasMore: hasMore,
      nextOffset: nextOffset,
      startPage: page,
      query: hasQuery ? q : null,
      type: type,
    );

    // ── SEO ──────────────────────────────────────────────────────────────
    final pageSuffix = page > 1 ? ' — Page $page' : '';
    final (title, description) = switch ((type, hasQuery)) {
      (final t?, _) => (
        '${t.capitalize}-type Pokémon$pageSuffix · Pokédex',
        'All ${t.capitalize}-type Pokémon with artwork, types and stats.',
      ),
      (null, true) => (
        'Results for “$q” · Pokédex',
        'Pokémon whose name contains “$q”.',
      ),
      _ => (
        'Pokédex — all Pokémon$pageSuffix',
        'Browse every Pokémon: search by name or filter by type, with artwork, types and base stats.',
      ),
    };
    final path = homeLocation(
      query: hasQuery ? q : null,
      type: type,
      page: page,
    );
    final origin = siteOrigin(context);
    final firstArtwork = items.isEmpty
        ? null
        : items.first.sprites.other?.officialArtwork?.frontDefault;

    return Component.fragment([
      seoHead(
        context: context,
        title: title,
        description: description,
        path: path,
        image: firstArtwork,
        // Search result pages are thin/duplicate content: keep them out of the
        // index (links are still followed). Type pages are real landing pages.
        index: !hasQuery,
        jsonLd: [
          if (!hasQuery && type == null && page == 1)
            {
              '@context': 'https://schema.org',
              '@type': 'WebSite',
              'name': 'Pokédex',
              'url': '$origin/',
              'potentialAction': {
                '@type': 'SearchAction',
                'target': '$origin/?q={search_term_string}',
                'query-input': 'required name=search_term_string',
              },
            },
          {
            '@context': 'https://schema.org',
            '@type': 'ItemList',
            'name': title,
            'numberOfItems': items.length,
            'itemListElement': [
              for (final (i, p) in items.indexed)
                {
                  '@type': 'ListItem',
                  'position': offset + i + 1,
                  'url': '$origin/pokemon/${p.id}',
                  'name': p.name.capitalize,
                },
            ],
          },
        ],
      ),
      PokemonHomeIsland(seed: seed),
    ]);
  }
}
