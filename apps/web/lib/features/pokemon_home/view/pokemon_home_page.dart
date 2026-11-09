import 'package:app_shared/domain/constants/pokemon_types.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_bloc.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_state.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_core/jaspr_kit_core.dart';
import 'package:kit_core/utils/extensions/string_ext.dart';
import 'package:kit_design_tokens/kit_design_tokens.dart';
import 'package:universal_web/web.dart' as web;

import '../../pokemon_detail/pokemon_detail_navigator.dart';
import '../pokemon_home_navigator.dart';

part 'widgets/home_search_bar.dart';
part 'widgets/home_type_filters.dart';
part 'widgets/home_results.dart';
part 'widgets/home_pokemon_card.dart';

/// Pokédex home — paginated list with debounced search and type filters.
///
/// Driven by the **same `PokemonHomeBloc` as the Flutter screen**
/// (packages/app_shared): pagination, debounce, filter rules and race
/// handling are shared; this file is only the web view.
class PokemonHomePage extends StatelessComponent {
  const PokemonHomePage({this.initialQuery, this.initialType, super.key});

  /// Restored from the URL (`?q=` / `?type=`) — see PokemonHomeNavigator.
  final String? initialQuery;
  final String? initialType;

  @override
  Component build(BuildContext context) {
    return BaseBlocView<PokemonHomeBloc, PokemonHomeState>(
      create: PokemonHomeBloc.create,
      // The page renders its own skeleton / "loading more" states.
      showLoadingOverlay: false,
      onReady: (bloc) =>
          bloc.add(PokemonHomeStarted(query: initialQuery, type: initialType)),
      builder: (context, state, bloc) => _PokemonHomeView(
        state: state,
        bloc: bloc,
        initialQuery: initialType == null ? initialQuery : null,
      ),
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.home').styles(raw: {'display': 'grid', 'gap': '16px'}),
    css('.home-toolbar').styles(
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
    ..._HomeSearchBar.styles,
    ..._HomeTypeFilters.styles,
    ..._HomeResults.styles,
    ..._HomePokemonCard.styles,
  ];
}

/// Owns view-only state the shared bloc must not hold: the search field text,
/// the window scroll position and the URL.
class _PokemonHomeView extends StatefulComponent {
  const _PokemonHomeView({
    required this.state,
    required this.bloc,
    required this.initialQuery,
  });

  final PokemonHomeState state;
  final PokemonHomeBloc bloc;
  final String? initialQuery;

  @override
  State<_PokemonHomeView> createState() => _PokemonHomeViewState();
}

class _PokemonHomeViewState extends State<_PokemonHomeView> {
  late String _text = component.initialQuery ?? '';

  PokemonHomeState get state => component.state;
  PokemonHomeBloc get bloc => component.bloc;

  @override
  void didUpdateComponent(_PokemonHomeView oldComponent) {
    super.didUpdateComponent(oldComponent);
    final old = oldComponent.state;

    if (state.resultsVersion != old.resultsVersion) {
      // A type filter replaced the search → reflect that in the field.
      if (state.searchQuery == null && _text.isNotEmpty) _text = '';
      // New result set → back to the top of the list.
      if (kIsWeb && web.window.scrollY > 0) {
        web.window.scrollTo(web.ScrollToOptions(top: 0, behavior: 'instant'));
      }
    }

    if (state.searchQuery != old.searchQuery ||
        state.selectedType != old.selectedType) {
      // Router updates may not run mid-build — defer to after the frame.
      context.binding.addPostFrameCallback(() {
        if (!mounted) return;
        PokemonHomeNavigator.syncUrl(
          context,
          query: state.searchQuery,
          type: state.selectedType,
        );
      });
    }
  }

  void _onTextChanged(String value) {
    setState(() => _text = value);
    bloc.add(PokemonHomeSearchQueryChanged(value));
  }

  void _onSubmitted() => bloc.add(PokemonHomeSearch(_text));

  void _onClear() {
    setState(() => _text = '');
    bloc.add(PokemonHomeSearch(''));
  }

  @override
  Component build(BuildContext context) {
    return section(classes: 'home', [
      div(classes: 'home-toolbar', [
        _HomeSearchBar(
          text: _text,
          onChanged: _onTextChanged,
          onSubmitted: _onSubmitted,
          onClear: _onClear,
        ),
        _HomeTypeFilters(
          selectedType: state.selectedType,
          onSelected: (type) => bloc.add(PokemonHomeFilterByType(type)),
        ),
      ]),
      _HomeResults(state: state, bloc: bloc),
    ]);
  }
}
