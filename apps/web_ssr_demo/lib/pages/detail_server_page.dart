import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_species_entity.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:app_shared/domain/usecase/get_evolution_chain_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_by_id_usecase.dart';
import 'package:app_shared/domain/usecase/get_pokemon_species_usecase.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:kit_core/utils/extensions/string_ext.dart';
import 'package:kit_network/core/di/locator.dart';

import 'package:kit_network/core/network/error/api_error.dart';

import '../islands/favorite_button.dart';
import '../routes.dart';
import '../seo/seo.dart';
import 'not_found_page.dart';

/// Pokémon detail page, rendered **on the server for every request**.
///
/// Uses the same shared use cases DetailBloc uses. Everything here is static
/// HTML — only the favorite button is an interactive island.
class DetailServerPage extends AsyncStatelessComponent {
  const DetailServerPage({required this.id, super.key});

  final int id;

  @override
  Future<Component> build(BuildContext context) async {
    final repo = getIt<PokemonRepository>();
    final Pokemon pokemon;
    try {
      pokemon = await GetPokemonByIdUseCase(repo)(id);
    } on ApiError catch (e) {
      // 404 only when the API says it doesn't exist; anything else (timeout,
      // 5xx) is temporary → 503 so search engines retry instead of dropping it.
      return e.statusCode == 404
          ? NotFoundPage(message: 'Pokémon #$id not found')
          : const NotFoundPage.unavailable();
    } catch (_) {
      return const NotFoundPage.unavailable();
    }

    // Species + evolution are nice-to-have: render the page even if they fail.
    PokemonSpecies? species;
    EvolutionChain? chain;
    try {
      species = await GetPokemonSpeciesUseCase(repo)(pokemon.speciesUrl);
      chain = await GetEvolutionChainUseCase(repo)(species.evolutionChainUrl);
    } catch (_) {}

    final name = pokemon.name.capitalize;
    final artwork =
        pokemon.sprites.other?.officialArtwork?.frontDefault ??
        pokemon.sprites.frontDefault;
    final description = species?.description ?? '$name — #${pokemon.id}';

    final origin = siteOrigin(context);
    final path = detailLocation(pokemon.id);
    final types = pokemon.types.map((t) => t.type.name.capitalize).toList();

    return Component.fragment([
      seoHead(
        context: context,
        title: '$name (#${pokemon.id}) — ${types.join('/')} Pokémon · Pokédex',
        description: description,
        path: path,
        image: artwork,
        ogType: 'article',
        jsonLd: [
          {
            '@context': 'https://schema.org',
            '@type': 'BreadcrumbList',
            'itemListElement': [
              {
                '@type': 'ListItem',
                'position': 1,
                'name': 'Pokédex',
                'item': '$origin/',
              },
              {
                '@type': 'ListItem',
                'position': 2,
                'name': name,
                'item': '$origin$path',
              },
            ],
          },
          // There is no schema.org "Pokémon" type: describe the page and the
          // thing it is about, so answer engines can tie facts to the entity.
          {
            '@context': 'https://schema.org',
            '@type': 'WebPage',
            'name': '$name · Pokédex',
            'url': '$origin$path',
            'description': description,
            'primaryImageOfPage': ?artwork,
            'about': {
              '@type': 'Thing',
              'name': name,
              'identifier': '#${pokemon.id.toString().padLeft(3, '0')}',
              'description': [
                if (species != null) species.genus,
                'Type: ${types.join(', ')}',
                'Base stats — HP ${pokemon.stats.hp}, Attack ${pokemon.stats.attack}, '
                    'Defense ${pokemon.stats.defense}, Sp. Atk ${pokemon.stats.specialAttack}, '
                    'Sp. Def ${pokemon.stats.specialDefense}, Speed ${pokemon.stats.speed}',
              ].join('. '),
              'image': ?artwork,
            },
          },
        ],
      ),
      article(classes: 'detail', [
        a(href: '/', classes: 'back', [Component.text('← All Pokémon')]),
        section(classes: 'detail-hero', [
          if (artwork != null)
            img(
              src: artwork,
              alt: '$name official artwork',
              // Intrinsic size (no layout shift) + this is the LCP element:
              // fetch it before anything else.
              width: 475,
              height: 475,
              attributes: const {'fetchpriority': 'high', 'decoding': 'async'},
            ),
          div([
            span([Component.text('#${pokemon.id.toString().padLeft(3, '0')}')]),
            h1([Component.text(name)]),
            p([
              Component.text(
                pokemon.types.map((t) => t.type.name.capitalize).join(' · '),
              ),
            ]),
            if (species != null) ...[
              p([Component.text(species.genus)]),
              p([Component.text(species.description)]),
            ],
            FavoriteButton(pokemonId: pokemon.id),
          ]),
        ]),
        section([
          h2([Component.text('Base stats')]),
          table(classes: 'stats', [
            caption(classes: 'sr-only', [
              Component.text('Base stats of $name'),
            ]),
            tbody([
              for (final (label, value) in [
                ('HP', pokemon.stats.hp),
                ('Attack', pokemon.stats.attack),
                ('Defense', pokemon.stats.defense),
                ('Sp. Atk', pokemon.stats.specialAttack),
                ('Sp. Def', pokemon.stats.specialDefense),
                ('Speed', pokemon.stats.speed),
              ])
                tr([
                  th(
                    attributes: const {'scope': 'row'},
                    [Component.text(label)],
                  ),
                  td([Component.text('$value')]),
                  // Decorative bar — the number is the content.
                  td(
                    attributes: const {'aria-hidden': 'true'},
                    [
                      div(
                        classes: 'bar',
                        styles: Styles(
                          raw: {
                            'width': '${(value / 255 * 100).clamp(0, 100)}%',
                          },
                        ),
                        [],
                      ),
                    ],
                  ),
                ]),
            ]),
          ]),
        ]),
        if (chain != null)
          section([
            h2([Component.text('Evolution')]),
            for (final path in chain.allPaths)
              p(classes: 'evo', [
                for (final (i, node) in path.indexed) ...[
                  if (i > 0) Component.text(' → '),
                  if (node.speciesId == pokemon.id)
                    strong([Component.text(node.speciesName.capitalize)])
                  else
                    a(href: detailLocation(node.speciesId), [
                      Component.text(node.speciesName.capitalize),
                    ]),
                ],
              ]),
          ]),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css(
      '.back',
    ).styles(raw: {'display': 'inline-block', 'margin-bottom': '12px'}),
    css('.detail').styles(raw: {'display': 'grid', 'gap': '24px'}),
    css('.detail-hero').styles(
      raw: {
        'display': 'grid',
        'grid-template-columns': 'minmax(160px, 280px) 1fr',
        'gap': '24px',
        'align-items': 'center',
        'padding': '24px',
        'border-radius': '24px',
        'background': 'var(--kit-primary-10)',
      },
    ),
    css('.detail-hero img').styles(raw: {'width': '100%', 'height': 'auto'}),
    css('.detail-hero h1').styles(raw: {'margin': '0'}),
    css('.stats').styles(raw: {'width': '100%', 'border-spacing': '8px 6px'}),
    css('.stats th').styles(
      raw: {
        'text-align': 'left',
        'font-weight': '400',
        'color': 'var(--kit-gray-50)',
        'width': '80px',
      },
    ),
    css(
      '.stats td:nth-child(2)',
    ).styles(raw: {'width': '40px', 'font-weight': '700'}),
    css('.bar').styles(
      raw: {
        'height': '8px',
        'border-radius': '4px',
        'background': 'var(--kit-primary)',
      },
    ),
  ];
}
