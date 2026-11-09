import 'package:app_shared/domain/constants/pokemon_types.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_bloc.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_state.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_core/jaspr_kit_core.dart';
import 'package:kit_core/utils/extensions/string_ext.dart';
import 'package:kit_design_tokens/kit_design_tokens.dart';
import 'package:universal_web/web.dart' as web;

import '../codec/home_seed.dart';
import '../components/pokemon_card.dart';
import '../config.dart';
import '../routes.dart';

/// The interactive part of the home page — an "island".
///
/// `@client` means: rendered to HTML on the server like everything else, then
/// shipped to the browser as JS and *hydrated* there (made interactive),
/// receiving [seed] — the first page the server already fetched.
///
/// * Server: no bloc, no DI — just renders the seed's state as HTML.
/// * Browser: the shared `PokemonHomeBloc`, started *from* the seed, takes
///   over search, type filters and infinite scroll.
@client
class PokemonHomeIsland extends StatelessComponent {
  const PokemonHomeIsland({required this.seed, super.key});

  final HomeSeed seed;

  @override
  Component build(BuildContext context) {
    if (!kIsWeb) {
      // Same wrapper markup the browser's BaseBlocView produces → clean hydration.
      return BaseBlocView.shell([
        _HomeView(
          state: seed.toState(),
          onEvent: null,
          startPage: seed.startPage,
        ),
      ]);
    }
    return BaseBlocView<PokemonHomeBloc, PokemonHomeState>(
      create: () => PokemonHomeBloc.create(initialState: seed.toState()),
      showLoadingOverlay: false,
      builder: (context, state, bloc) =>
          _HomeView(state: state, onEvent: bloc.add, startPage: seed.startPage),
    );
  }

  @css
  static List<StyleRule> get styles => _HomeView.styles;
}

/// Renders a [PokemonHomeState]. [onEvent] is null on the server (inert HTML)
/// and `bloc.add` in the browser.
class _HomeView extends StatefulComponent {
  const _HomeView({
    required this.state,
    required this.onEvent,
    required this.startPage,
  });

  final PokemonHomeState state;
  final void Function(PokemonHomeEvent event)? onEvent;

  /// Server page (`?page=N`) the seeded items start at.
  final int startPage;

  @override
  State<_HomeView> createState() => _HomeViewState();

  static List<StyleRule> get styles => [
    css(
      '.home-title',
    ).styles(raw: {'margin': '0 0 4px', 'font-size': '1.6rem'}),
    css('.pagination').styles(
      raw: {
        'display': 'flex',
        'justify-content': 'center',
        'gap': '24px',
        'padding': '24px',
        'color': 'var(--kit-gray-50)',
      },
    ),
    css('.toolbar').styles(
      raw: {
        'position': 'sticky',
        'top': '0',
        'z-index': '10',
        'display': 'grid',
        'gap': '12px',
        'padding': '12px 0',
        'background': 'var(--kit-white-10)',
      },
    ),
    css('.search-input').styles(
      raw: {
        'width': '100%',
        'box-sizing': 'border-box',
        'padding': '12px 16px',
        'font-size': '1rem',
        'border': '2px solid var(--kit-gray-20)',
        'border-radius': '999px',
        'outline': 'none',
      },
    ),
    css(
      '.search-input:focus',
    ).styles(raw: {'border-color': 'var(--kit-primary)'}),
    css(
      '.type-filters',
    ).styles(raw: {'display': 'flex', 'gap': '8px', 'overflow-x': 'auto'}),
    css('.type-chip').styles(
      raw: {
        'flex': '0 0 auto',
        'padding': '6px 14px',
        'border': '2px solid var(--chip-color)',
        'border-radius': '999px',
        'background': 'white',
        'font-weight': '600',
        'cursor': 'pointer',
      },
    ),
    css(
      '.type-chip.is-active',
    ).styles(raw: {'background': 'var(--chip-color)', 'color': 'white'}),
  ];
}

class _HomeViewState extends State<_HomeView> {
  late String _text = component.state.searchQuery ?? '';

  PokemonHomeState get state => component.state;
  void _send(PokemonHomeEvent e) => component.onEvent?.call(e);

  /// The server's `?page=N` until the user starts a new search/filter here.
  int get _startPage => state.resultsVersion == 0 ? component.startPage : 1;

  String get _heading {
    final base = switch ((state.selectedType, state.searchQuery)) {
      (final t?, _) => '${t.capitalize}-type Pokémon',
      (null, final q?) => 'Results for “$q”',
      _ => 'All Pokémon',
    };
    return _startPage > 1 ? '$base — Page $_startPage' : base;
  }

  @override
  void didUpdateComponent(_HomeView old) {
    super.didUpdateComponent(old);
    if (state.resultsVersion != old.state.resultsVersion) {
      if (state.searchQuery == null && _text.isNotEmpty) _text = '';
      if (kIsWeb && web.window.scrollY > 0) {
        web.window.scrollTo(web.ScrollToOptions(top: 0, behavior: 'instant'));
      }
    }
    // Keep the URL in sync so reload / share / Back re-render this result
    // set on the server. No client router in multi-page mode → History API.
    if (kIsWeb &&
        (state.searchQuery != old.state.searchQuery ||
            state.selectedType != old.state.selectedType)) {
      final url = homeLocation(
        query: state.searchQuery,
        type: state.selectedType,
      );
      web.window.history.replaceState(null, '', url);
    }
  }

  @override
  Component build(BuildContext context) {
    return section([
      // One h1 per page; changes with the result set (cards are h2).
      h1(classes: 'home-title', [Component.text(_heading)]),
      div(classes: 'toolbar', [
        input<String>(
          type: InputType.search,
          value: _text,
          classes: 'search-input',
          attributes: const {
            'placeholder': 'Search Pokémon by name…',
            'aria-label': 'Search Pokémon',
          },
          onInput: (v) {
            setState(() => _text = v);
            _send(PokemonHomeSearchQueryChanged(v));
          },
        ),
        div(classes: 'type-filters', [
          for (final type in PokemonTypes.filterable)
            button(
              classes: type == state.selectedType
                  ? 'type-chip is-active'
                  : 'type-chip',
              styles: Styles(
                raw: {'--chip-color': cssHex(PokemonTypes.colorOf(type))},
              ),
              attributes: {
                'type': 'button',
                'aria-pressed': '${type == state.selectedType}',
              },
              onClick: () => _send(PokemonHomeFilterByType(type)),
              [Component.text(type.capitalize)],
            ),
        ]),
      ]),
      if (state.isInitialLoading)
        div(classes: 'footer', [Component.text('Loading…')])
      else if (state.isEmptyResult)
        div(classes: 'footer', [Component.text('No Pokémon found.')])
      else ...[
        div(classes: 'grid', [
          for (final p in state.items)
            PokemonCard(
              key: ValueKey(p.id),
              pokemon: p,
              isFavorite: state.favoriteIds.contains(p.id),
              onToggleFavorite: component.onEvent == null
                  ? null
                  : () => _send(PokemonHomeToggleFavorite(p.id)),
            ),
        ]),
        _pagination(),
      ],
    ]);
  }

  /// Real links bots (and no-JS visitors) can follow — infinite scroll is
  /// invisible to crawlers. In the browser the trigger loads the next page
  /// automatically before the link is ever reached.
  Component _pagination() {
    String location(int page) => homeLocation(
      query: state.searchQuery,
      type: state.selectedType,
      page: page,
    );
    final nextPage = state.nextOffset ~/ pageSize + 1;

    return nav(
      classes: 'pagination',
      attributes: const {'aria-label': 'Pagination'},
      [
        if (_startPage > 1)
          a(
            href: location(_startPage - 1),
            attributes: const {'rel': 'prev'},
            [Component.text('← Previous page')],
          ),
        if (state.hasMore)
          InfiniteScrollTrigger(
            watch: state.items.length,
            enabled: component.onEvent != null,
            onVisible: () => _send(PokemonHomeLoadMore()),
            child: a(
              href: location(nextPage),
              attributes: const {'rel': 'next'},
              [Component.text('Next page →')],
            ),
          )
        else
          span([Component.text("You've reached the end.")]),
      ],
    );
  }
}
