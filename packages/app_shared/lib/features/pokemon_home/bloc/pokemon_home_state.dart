import 'package:kit_core/base_bloc/paginated_bloc.dart';

import '../../../domain/entity/pokemon_entity.dart';

class PokemonHomeState extends PaginatedState<Pokemon> {
  @override
  final List<Pokemon> items;
  @override
  final bool hasMore;
  @override
  final int nextOffset;
  final String? searchQuery;
  final String? selectedType;
  final Set<int> favoriteIds;
  final bool isCompareMode;
  final List<Pokemon> compareSelection;

  /// Incremented every time a **new result set** starts (search, type filter,
  /// clear). Views watch it to reset their scroll position — the bloc itself
  /// stays free of UI objects like `ScrollController`, so it runs on both
  /// Flutter and Jaspr.
  final int resultsVersion;

  const PokemonHomeState({
    this.items = const [],
    this.hasMore = true,
    this.nextOffset = 0,
    this.searchQuery,
    this.selectedType,
    this.favoriteIds = const {},
    this.isCompareMode = false,
    this.compareSelection = const [],
    this.resultsVersion = 0,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  bool isSelectedForCompare(int pokemonId) =>
      compareSelection.any((p) => p.id == pokemonId);

  bool get hasActiveQuery => searchQuery != null || selectedType != null;

  /// Initial load in progress (nothing to show yet).
  bool get isInitialLoading => isLoading && items.isEmpty;

  /// A query finished and matched nothing.
  bool get isEmptyResult =>
      !isLoading && errorMessage == null && items.isEmpty && !hasMore;

  PokemonHomeState copyWith({
    List<Pokemon>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    String? searchQuery,
    String? selectedType,
    Set<int>? favoriteIds,
    bool? isCompareMode,
    List<Pokemon>? compareSelection,
    int? resultsVersion,
    bool clearError = false,
    bool clearSearch = false,
    bool clearFilter = false,
  }) {
    return PokemonHomeState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      selectedType: clearFilter ? null : (selectedType ?? this.selectedType),
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isCompareMode: isCompareMode ?? this.isCompareMode,
      compareSelection: compareSelection ?? this.compareSelection,
      resultsVersion: resultsVersion ?? this.resultsVersion,
    );
  }

  static const empty = PokemonHomeState();

  @override
  List<Object?> get props => [
    isLoading,
    isValid,
    errorMessage,
    nextOffset,
    hasMore,
    items,
    searchQuery,
    selectedType,
    favoriteIds,
    isCompareMode,
    compareSelection,
    resultsVersion,
  ];
}
