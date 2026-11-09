import 'package:app_shared/features/pokemon_favorites/bloc/pokemon_favorites_bloc.dart';
import 'package:app_shared/features/pokemon_favorites/bloc/pokemon_favorites_state.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_core/jaspr_kit_core.dart';

import '../components/pokemon_card.dart';

/// The favorites list — entirely an island.
///
/// Favorites live in *this browser* (localStorage), so the server can't know
/// them: it renders the loading state, and the browser fills the list with
/// the shared `PokemonFavoritesBloc` (the same one the mobile tab uses).
@client
class FavoritesIsland extends StatelessComponent {
  const FavoritesIsland({super.key});

  @override
  Component build(BuildContext context) {
    if (!kIsWeb) {
      // Same markup as the browser's first frame (initial state = loading).
      return BaseBlocView.shell([
        const _FavoritesView(state: PokemonFavoritesState(), bloc: null),
      ]);
    }
    return BaseBlocView<PokemonFavoritesBloc, PokemonFavoritesState>(
      // The bloc loads itself in onReady(), which BaseBlocView calls after
      // the first frame — in the browser only.
      create: PokemonFavoritesBloc.create,
      showLoadingOverlay: false,
      builder: (context, state, bloc) =>
          _FavoritesView(state: state, bloc: bloc),
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.fav-header').styles(
      raw: {
        'display': 'flex',
        'align-items': 'center',
        'justify-content': 'space-between',
        'gap': '12px',
        'margin-bottom': '16px',
      },
    ),
    css('.fav-header h1').styles(raw: {'margin': '0'}),
    css('.clear-all').styles(
      raw: {
        'padding': '8px 16px',
        'border': '2px solid var(--kit-error)',
        'border-radius': '999px',
        'background': 'white',
        'color': 'var(--kit-error)',
        'font-weight': '600',
        'cursor': 'pointer',
      },
    ),
    css('.empty').styles(
      raw: {
        'display': 'grid',
        'justify-items': 'center',
        'gap': '8px',
        'padding': '48px 16px',
        'text-align': 'center',
        'color': 'var(--kit-gray-50)',
      },
    ),
  ];
}

/// [bloc] is null on the server (inert HTML).
class _FavoritesView extends StatelessComponent {
  const _FavoritesView({required this.state, required this.bloc});

  final PokemonFavoritesState state;
  final PokemonFavoritesBloc? bloc;

  /// Nothing loaded yet: the bloc sets isValid after its first load, so the
  /// server render and the browser's first frame both show "loading".
  bool get _isLoading =>
      state.favorites.isEmpty && (state.isLoading || !state.isValid);

  @override
  Component build(BuildContext context) {
    final bloc = this.bloc;
    final count = state.favorites.length;

    // Turkish content inside an English site → mark the language.
    return section(
      attributes: const {'lang': 'tr'},
      [
        div(classes: 'fav-header', [
          h1([
            Component.text(_isLoading ? 'Favorilerim' : 'Favorilerim ($count)'),
          ]),
          if (count > 0)
            button(
              classes: 'clear-all',
              attributes: const {'type': 'button'},
              onClick: bloc == null
                  ? null
                  : () => bloc.add(PokemonFavoritesClearAll()),
              [Component.text('Tümünü temizle')],
            ),
        ]),
        if (_isLoading)
          div(classes: 'footer', [Component.text('Yükleniyor…')])
        else if (state.errorMessage != null && count == 0)
          div(classes: 'empty', [
            p([Component.text('Favoriler yüklenemedi.')]),
            button(
              classes: 'clear-all',
              onClick: bloc == null
                  ? null
                  : () => bloc.add(PokemonFavoritesLoad()),
              [Component.text('Tekrar dene')],
            ),
          ])
        else if (count == 0)
          div(classes: 'empty', [
            p([Component.text('Henüz favorin yok.')]),
            p([Component.text('Ana sayfadaki ☆ ile Pokémon ekleyebilirsin.')]),
            a(href: '/', [Component.text('Pokémon\'lara göz at →')]),
          ])
        else
          div(classes: 'grid', [
            for (final pokemon in state.favorites)
              PokemonCard(
                key: ValueKey(pokemon.id),
                pokemon: pokemon,
                isFavorite: true,
                onToggleFavorite: bloc == null
                    ? null
                    : () => bloc.add(PokemonFavoritesRemove(pokemon.id)),
              ),
          ]),
      ],
    );
  }
}
