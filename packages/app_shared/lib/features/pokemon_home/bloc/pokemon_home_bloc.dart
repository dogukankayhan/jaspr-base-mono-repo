import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_core/base_bloc/paginated_bloc.dart';
import 'package:kit_network/core/di/locator.dart';

import '../../../domain/entity/pokemon_entity.dart';
import '../../../domain/repository/favorites_repository.dart';
import '../../../domain/repository/pokemon_repository.dart';
import '../../../domain/usecase/filter_pokemon_by_type_usecase.dart';
import '../../../domain/usecase/get_pokemon_page_usecase.dart';
import '../../../domain/usecase/search_pokemon_usecase.dart';
import 'pokemon_home_state.dart';

/// Pokemon Home Events
sealed class PokemonHomeEvent {}

/// Loads the first page. [query] / [type] restore a previous result set
/// (e.g. from the web URL `?q=…&type=…`); left null, the current state's
/// query/filter is kept. A type filter wins over a search, as in the UI.
class PokemonHomeStarted extends PokemonHomeEvent {
  final String? query;
  final String? type;
  PokemonHomeStarted({this.query, this.type});
}

class PokemonHomeLoadMore extends PokemonHomeEvent {}

class PokemonHomeRefresh extends PokemonHomeEvent {}

class PokemonHomeRemoveAt extends PokemonHomeEvent {
  final int index;
  PokemonHomeRemoveAt(this.index);
}

class PokemonHomeRemoveById extends PokemonHomeEvent {
  final int id;
  PokemonHomeRemoveById(this.id);
}

/// Raw keystrokes — debounced into [PokemonHomeSearch].
class PokemonHomeSearchQueryChanged extends PokemonHomeEvent {
  final String query;
  PokemonHomeSearchQueryChanged(this.query);
}

/// Runs a search immediately (e.g. on submit). Empty clears the search.
class PokemonHomeSearch extends PokemonHomeEvent {
  final String query;
  PokemonHomeSearch(this.query);
}

/// Toggles a type filter: the active type again (or null) clears it.
class PokemonHomeFilterByType extends PokemonHomeEvent {
  final String? type;
  PokemonHomeFilterByType(this.type);
}

class PokemonHomeClearFilters extends PokemonHomeEvent {}

/// Platform-neutral scroll metrics (Flutter `ScrollMetrics`, or the browser
/// window's scrollY / scrollable height). Loads more past 70 %.
class PokemonHomeScrollPositionChanged extends PokemonHomeEvent {
  final double pixels;
  final double maxScrollExtent;
  PokemonHomeScrollPositionChanged(this.pixels, this.maxScrollExtent);
}

class PokemonHomeToggleFavorite extends PokemonHomeEvent {
  final int pokemonId;
  PokemonHomeToggleFavorite(this.pokemonId);
}

class PokemonHomeFavoritesUpdated extends PokemonHomeEvent {
  final Set<int> favoriteIds;
  PokemonHomeFavoritesUpdated(this.favoriteIds);
}

class PokemonHomeCompareModeToggled extends PokemonHomeEvent {}

class PokemonHomeCompareSelectionToggled extends PokemonHomeEvent {
  final Pokemon pokemon;
  PokemonHomeCompareSelectionToggled(this.pokemon);
}

/// Pokémon list with pagination, debounced search and type filter.
///
/// Shared by the Flutter screen and the Jaspr page — it holds **no UI
/// objects**: views own their scroll/text controllers, send events, and
/// reset scroll when [PokemonHomeState.resultsVersion] changes.
class PokemonHomeBloc extends BaseBloc<PokemonHomeEvent, PokemonHomeState>
    with PaginatedBloc<Pokemon, PokemonHomeEvent, PokemonHomeState> {
  final GetPokemonPageUseCase _getPokemonPageUseCase;
  final FilterPokemonByTypeUseCase _filterPokemonByTypeUseCase;
  final SearchPokemonUseCase _searchPokemonUseCase;
  final FavoritesRepository favoritesRepo;
  StreamSubscription<Set<int>>? _favoritesSubscription;

  // Search debounce
  Timer? _searchDebounceTimer;
  static const searchDebounceDuration = Duration(milliseconds: 500);

  // Scroll throttle
  DateTime? _lastScrollLoadTime;
  static const _scrollThrottleDuration = Duration(milliseconds: 300);

  /// Production wiring — resolves the repository once (CLAUDE.md Rule 3).
  ///
  /// [initialState] seeds the bloc with an already-loaded result set — e.g.
  /// the first page a server rendered (SSR hydration), so the client neither
  /// refetches it nor flashes an empty list. Pagination continues from
  /// `initialState.nextOffset`.
  factory PokemonHomeBloc.create({PokemonHomeState? initialState}) {
    final repo = getIt<PokemonRepository>();
    return PokemonHomeBloc(
      GetPokemonPageUseCase(repo),
      FilterPokemonByTypeUseCase(repo),
      SearchPokemonUseCase(repo),
      getIt<FavoritesRepository>(),
      initialState: initialState ?? const PokemonHomeState(),
    );
  }

  PokemonHomeBloc(
    this._getPokemonPageUseCase,
    this._filterPokemonByTypeUseCase,
    this._searchPokemonUseCase,
    this.favoritesRepo, {
    PokemonHomeState initialState = const PokemonHomeState(),
  }) : super(initialState) {
    _favoritesSubscription = favoritesRepo.favoriteIdsStream.listen((ids) {
      add(PokemonHomeFavoritesUpdated(ids));
    });

    on<PokemonHomeFavoritesUpdated>((event, emit) {
      emit(state.copyWith(favoriteIds: event.favoriteIds));
    });

    on<PokemonHomeStarted>((event, emit) async {
      if (event.query != null || event.type != null) {
        final type = event.type;
        final query = type == null ? _normalize(event.query) : null;
        emit(
          state.copyWith(
            searchQuery: query,
            selectedType: type,
            clearSearch: query == null,
            clearFilter: type == null,
          ),
        );
      }
      await handleLoadInitial(emit);
    });

    on<PokemonHomeLoadMore>((event, emit) => handleLoadMore(emit));

    on<PokemonHomeRefresh>((event, emit) => handleLoadInitial(emit));

    on<PokemonHomeRemoveAt>((event, emit) => handleRemoveAt(event.index, emit));

    on<PokemonHomeRemoveById>((event, emit) {
      handleRemoveWhere((item) => item.id == event.id, emit);
    });

    on<PokemonHomeSearch>((event, emit) async {
      final query = _normalize(event.query);
      // Same search again (e.g. debounce firing after submit) → nothing to do.
      if (query == state.searchQuery &&
          state.selectedType == null &&
          (state.items.isNotEmpty || state.isLoading)) {
        return;
      }
      // A search replaces any type filter.
      await _startNewResults(emit, query: query, type: null);
    });

    on<PokemonHomeFilterByType>((event, emit) async {
      _searchDebounceTimer?.cancel();
      final type = event.type == state.selectedType ? null : event.type;
      // A type filter replaces any search.
      await _startNewResults(emit, query: null, type: type);
    });

    on<PokemonHomeClearFilters>((event, emit) async {
      _searchDebounceTimer?.cancel();
      await _startNewResults(emit, query: null, type: null);
    });

    on<PokemonHomeSearchQueryChanged>((event, emit) {
      _searchDebounceTimer?.cancel();
      if (event.query.trim().isEmpty) {
        add(PokemonHomeSearch(''));
      } else {
        _searchDebounceTimer = Timer(searchDebounceDuration, () {
          if (!isClosed) add(PokemonHomeSearch(event.query));
        });
      }
    });

    on<PokemonHomeScrollPositionChanged>((event, emit) {
      final threshold = event.maxScrollExtent * 0.7;
      if (event.pixels >= threshold) {
        final now = DateTime.now();
        if (_lastScrollLoadTime == null ||
            now.difference(_lastScrollLoadTime!) > _scrollThrottleDuration) {
          if (state.hasMore && !state.isLoading && !isFetchingPage) {
            _lastScrollLoadTime = now;
            add(PokemonHomeLoadMore());
          }
        }
      }
    });

    on<PokemonHomeToggleFavorite>((event, emit) async {
      await favoritesRepo.toggleFavorite(event.pokemonId);
    });

    on<PokemonHomeCompareModeToggled>((event, emit) {
      emit(
        state.copyWith(
          isCompareMode: !state.isCompareMode,
          compareSelection: const [],
        ),
      );
    });

    on<PokemonHomeCompareSelectionToggled>((event, emit) {
      final current = List<Pokemon>.from(state.compareSelection);
      final existingIndex = current.indexWhere((p) => p.id == event.pokemon.id);
      if (existingIndex != -1) {
        current.removeAt(existingIndex);
      } else if (current.length < 5) {
        current.add(event.pokemon);
      }
      emit(state.copyWith(compareSelection: current));
    });
  }

  static String? _normalize(String? query) {
    final q = query?.trim();
    return (q == null || q.isEmpty) ? null : q;
  }

  /// Switches to a new result set: sets query/filter (null clears), empties
  /// the list, bumps [PokemonHomeState.resultsVersion] and loads page one.
  Future<void> _startNewResults(
    Emitter<PokemonHomeState> emit, {
    required String? query,
    required String? type,
  }) async {
    emit(
      state.copyWith(
        searchQuery: query,
        selectedType: type,
        clearSearch: query == null,
        clearFilter: type == null,
        items: const [],
        hasMore: true,
        nextOffset: 0,
        resultsVersion: state.resultsVersion + 1,
      ),
    );
    await handleLoadInitial(emit);
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    _searchDebounceTimer?.cancel();
    return super.close();
  }

  @override
  Future<(List<Pokemon>, bool, int)> fetchPage(int offset, int size) {
    final type = state.selectedType;
    if (type != null) {
      return _filterPokemonByTypeUseCase(
        type: type,
        size: size,
        offset: offset,
      );
    }
    final query = state.searchQuery;
    if (query != null && query.isNotEmpty) {
      return _searchPokemonUseCase(query: query, size: size, offset: offset);
    }
    return _getPokemonPageUseCase(size: size, offset: offset);
  }

  @override
  PokemonHomeState paginatedState({
    List<Pokemon>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => state.copyWith(
    items: items,
    hasMore: hasMore,
    nextOffset: nextOffset,
    isLoading: isLoading,
    errorMessage: errorMessage,
    clearError: clearError,
  );
}
