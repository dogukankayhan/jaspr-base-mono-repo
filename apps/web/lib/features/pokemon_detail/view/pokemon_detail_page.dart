import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_species_entity.dart';
import 'package:app_shared/features/pokemon_detail/bloc/detail_bloc.dart';
import 'package:app_shared/features/pokemon_detail/bloc/detail_state.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_core/jaspr_kit_core.dart';
import 'package:jaspr_kit_ui/jaspr_kit_ui.dart';
import 'package:kit_core/utils/extensions/string_ext.dart';

import '../pokemon_detail_navigator.dart';

part 'widgets/detail_stats_section.dart';
part 'widgets/detail_evolution_section.dart';

/// Pokémon detail page — driven by **the same `DetailBloc`** the Flutter
/// screen uses (packages/app_shared). Only this view layer is web-specific.
class PokemonDetailPage extends StatelessComponent {
  const PokemonDetailPage({required this.pokemonId, super.key});

  final int pokemonId;

  @override
  Component build(BuildContext context) {
    return BaseBlocView<DetailBloc, DetailState>(
      activeKey: 'pokemon-$pokemonId',
      create: DetailBloc.create,
      onReady: (bloc) => bloc.add(DetailLoad(pokemonId)),
      builder: (context, state, bloc) {
        final error = state.errorMessage;
        if (error != null && state.pokemon == null) {
          return div(classes: 'detail-error', [
            p([Component.text(error)]),
            button(onClick: () => bloc.add(DetailLoad(pokemonId)), [
              Component.text('Retry'),
            ]),
          ]);
        }

        final pokemon = state.pokemon;
        if (pokemon == null) return const div([]);

        return article(classes: 'detail', [
          _DetailHero(
            pokemon: pokemon,
            species: state.species,
            isFavorite: state.isFavorite,
            onToggleFavorite: () => bloc.add(DetailToggleFavorite()),
          ),
          _DetailStatsSection(pokemon: pokemon),
          _DetailEvolutionSection(
            chain: state.evolutionChain,
            isLoading: state.isEvolutionLoading,
            currentId: pokemon.id,
          ),
        ]);
      },
    );
  }

  @css
  static List<StyleRule> get styles => [
    ..._DetailStatsSection.styles,
    ..._DetailEvolutionSection.styles,
    css('.detail').styles(raw: {'display': 'grid', 'gap': '24px'}),
    css('.detail-hero', [
      css('&').styles(
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
      css('img').styles(raw: {'width': '100%'}),
      css('h1').styles(raw: {'margin': '0', 'text-transform': 'capitalize'}),
    ]),
    css(
      '.detail-types',
    ).styles(raw: {'display': 'flex', 'gap': '8px', 'margin': '8px 0'}),
    css('.detail-type').styles(
      color: KitColors.onPrimary,
      raw: {
        'padding': '2px 12px',
        'border-radius': '999px',
        'background': 'var(--kit-primary)',
        'text-transform': 'capitalize',
        'font-size': '0.85rem',
      },
    ),
    css('.detail-fav').styles(
      raw: {
        'padding': '8px 16px',
        'border': '2px solid var(--kit-gold)',
        'border-radius': '999px',
        'background': 'transparent',
        'cursor': 'pointer',
        'font-weight': '600',
      },
    ),
    css('.detail-fav.is-fav').styles(raw: {'background': 'var(--kit-gold)'}),
    css('.detail-error').styles(raw: {'color': 'var(--kit-error)'}),
    css('.detail h2').styles(raw: {'margin': '0 0 12px'}),
  ];
}

/// Header block: artwork, name, types, species blurb, favorite toggle.
class _DetailHero extends StatelessComponent {
  const _DetailHero({
    required this.pokemon,
    required this.species,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final Pokemon pokemon;
  final PokemonSpecies? species;
  final bool isFavorite;
  final void Function() onToggleFavorite;

  @override
  Component build(BuildContext context) {
    final artwork =
        pokemon.sprites.other?.officialArtwork?.frontDefault ??
        pokemon.sprites.frontDefault;
    final species = this.species;

    return section(classes: 'detail-hero', [
      if (artwork != null) img(src: artwork, alt: pokemon.name),
      div([
        span([Component.text('#${pokemon.id.toString().padLeft(3, '0')}')]),
        h1([Component.text(pokemon.name)]),
        div(classes: 'detail-types', [
          for (final t in pokemon.types)
            span(classes: 'detail-type', [Component.text(t.type.name)]),
        ]),
        if (species != null) ...[
          p([Component.text(species.genus)]),
          p([Component.text(species.description)]),
        ],
        button(
          classes: isFavorite ? 'detail-fav is-fav' : 'detail-fav',
          onClick: onToggleFavorite,
          [Component.text(isFavorite ? '★ Favorite' : '☆ Add to favorites')],
        ),
      ]),
    ]);
  }
}
