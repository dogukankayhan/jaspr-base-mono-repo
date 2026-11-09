part of '../pokemon_home_page.dart';

/// Result area: skeleton → grid (+ infinite scroll) / error / empty states.
class _HomeResults extends StatelessComponent {
  const _HomeResults({required this.state, required this.bloc});

  final PokemonHomeState state;
  final PokemonHomeBloc bloc;

  static const _skeletonCount = 12;

  @override
  Component build(BuildContext context) {
    // 1. First page loading → skeleton grid (keeps layout stable).
    if (state.isInitialLoading) {
      return div(
        classes: 'results-grid',
        attributes: const {'aria-busy': 'true'},
        [
          for (var i = 0; i < _skeletonCount; i++)
            div(classes: 'poke-card is-skeleton', []),
        ],
      );
    }

    // 2. First page failed → full error with retry.
    final error = state.errorMessage;
    if (error != null && state.items.isEmpty) {
      return div(
        classes: 'results-message is-error',
        attributes: const {'role': 'alert'},
        [
          p([Component.text("Couldn't load Pokémon.")]),
          p(classes: 'results-detail', [Component.text(error)]),
          button(
            classes: 'results-action',
            onClick: () => bloc.add(PokemonHomeRefresh()),
            [Component.text('Try again')],
          ),
        ],
      );
    }

    // 3. Query finished with no matches.
    if (state.isEmptyResult) {
      return div(classes: 'results-message', [
        p([Component.text(_emptyText())]),
        if (state.hasActiveQuery)
          button(
            classes: 'results-action',
            onClick: () => bloc.add(PokemonHomeClearFilters()),
            [Component.text('Show all Pokémon')],
          ),
      ]);
    }

    // 4. Results + pagination footer.
    return div([
      p(
        classes: 'results-summary',
        attributes: const {'aria-live': 'polite'},
        [Component.text(_summaryText())],
      ),
      div(classes: 'results-grid', [
        for (final pokemon in state.items)
          _HomePokemonCard(
            key: ValueKey(pokemon.id),
            pokemon: pokemon,
            isFavorite: state.favoriteIds.contains(pokemon.id),
            onToggleFavorite: () =>
                bloc.add(PokemonHomeToggleFavorite(pokemon.id)),
          ),
      ]),
      _footer(),
    ]);
  }

  Component _footer() {
    // A load-more failed: keep the list, offer a retry instead of auto-looping.
    if (state.errorMessage != null) {
      return div(classes: 'results-footer is-error', [
        Component.text("Couldn't load more. "),
        button(
          classes: 'results-action',
          onClick: () => bloc.add(PokemonHomeLoadMore()),
          [Component.text('Retry')],
        ),
      ]);
    }
    if (state.hasMore) {
      return InfiniteScrollTrigger(
        // Re-armed after every page so tall screens keep filling up.
        watch: state.items.length,
        onVisible: () => bloc.add(PokemonHomeLoadMore()),
        child: div(classes: 'results-footer', [
          div(classes: 'kit-spinner', []),
          span([Component.text('Loading more…')]),
        ]),
      );
    }
    return div(classes: 'results-footer', [
      Component.text("That's all — ${state.items.length} Pokémon."),
    ]);
  }

  String _emptyText() {
    if (state.searchQuery case final q?) return 'No Pokémon named “$q”.';
    if (state.selectedType case final t?) {
      return 'No ${t.capitalize}-type Pokémon found.';
    }
    return 'No Pokémon found.';
  }

  String _summaryText() {
    final shown = '${state.items.length}${state.hasMore ? '+' : ''}';
    if (state.searchQuery case final q?) return '$shown results for “$q”';
    if (state.selectedType case final t?) {
      return '$shown ${t.capitalize}-type Pokémon';
    }
    return 'All Pokémon';
  }

  static List<StyleRule> get styles => [
    css('.results-grid').styles(
      raw: {
        'display': 'grid',
        'grid-template-columns': 'repeat(auto-fill, minmax(170px, 1fr))',
        'gap': '16px',
      },
    ),
    css(
      '.results-summary',
    ).styles(raw: {'margin': '0 0 12px', 'color': 'var(--kit-gray-50)'}),
    css('.results-message').styles(
      raw: {
        'display': 'grid',
        'justify-items': 'center',
        'gap': '8px',
        'padding': '48px 16px',
        'text-align': 'center',
      },
    ),
    css('.results-message.is-error').styles(raw: {'color': 'var(--kit-error)'}),
    css('.results-detail').styles(
      raw: {
        'font-size': '0.85rem',
        'opacity': '0.8',
        'word-break': 'break-word',
      },
    ),
    css('.results-action').styles(
      raw: {
        'padding': '8px 18px',
        'border': 'none',
        'border-radius': '999px',
        'background': 'var(--kit-primary)',
        'color': 'var(--kit-onPrimary)',
        'font-weight': '600',
        'cursor': 'pointer',
      },
    ),
    css('.results-footer').styles(
      raw: {
        'display': 'flex',
        'align-items': 'center',
        'justify-content': 'center',
        'gap': '12px',
        'padding': '24px',
        'color': 'var(--kit-gray-50)',
      },
    ),
    css(
      '.results-footer .kit-spinner',
    ).styles(raw: {'width': '24px', 'height': '24px'}),
  ];
}
