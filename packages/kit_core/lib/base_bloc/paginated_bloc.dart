import 'package:bloc/bloc.dart';
import 'base_bloc.dart';
import 'base_state.dart';

/// Base class for states with pagination support.
///
/// State of each paginated screen must extend this.
/// [T] type of list item (e.g. PokemonDetail, ForumPost).
abstract class PaginatedState<T> extends BaseState {
  List<T> get items;
  bool get hasMore;
  int get nextOffset;

  const PaginatedState({super.isLoading, super.isValid, super.errorMessage});
}

/// Base Pagination Events
/// Every paginated bloc must use these events
sealed class PaginatedEvent {}

class LoadInitialEvent extends PaginatedEvent {}

class LoadMoreEvent extends PaginatedEvent {}

class RefreshEvent extends PaginatedEvent {}

class RemoveItemAtEvent extends PaginatedEvent {
  final int index;
  RemoveItemAtEvent(this.index);
}

class RemoveItemWhereEvent<T> extends PaginatedEvent {
  final bool Function(T item) test;
  RemoveItemWhereEvent(this.test);
}

/// Mixin that automates pagination logic.
///
/// **When to use:** When infinite-scroll is required in list screens.
/// Choose plain [BaseBloc] (without PaginatedBloc) if:
/// - list pagination is not required (all data loaded at once), or
/// - you want to implement pagination logic differently.
///
/// **Event wiring:** Subclass kendi event'lerini [handleLoadInitial],
/// Binds to [handleLoadMore], [handleRemoveAt], [handleRemoveWhere].
///
/// Usage:
/// ```dart
/// sealed class HomeEvent {}
/// class HomeStarted extends HomeEvent {}
/// class HomeLoadMore extends HomeEvent {}
/// class HomeRefresh extends HomeEvent {}
/// class HomeRemoveAt extends HomeEvent {
///   final int index;
///   HomeRemoveAt(this.index);
/// }
///
/// class HomeBloc extends BaseBloc<HomeEvent, HomeState>
///     with PaginatedBloc<PokemonDetail, HomeEvent, HomeState> {
///
///   HomeBloc(this.repo) : super(const HomeState()) {
///     on<HomeStarted>((e, emit) => handleLoadInitial(emit));
///     on<HomeLoadMore>((e, emit) => handleLoadMore(emit));
///     on<HomeRefresh>((e, emit) => add(HomeStarted()));
///     on<HomeRemoveAt>((e, emit) => handleRemoveAt(e.index, emit));
///   }
///
///   @override
///   Future<(List<PokemonDetail>, bool, int)> fetchPage(int offset, int size) =>
///       repo.pageWithSize(size, offset);
///
///   @override
///   HomeState paginatedState({...}) => state.copyWith(...);
/// }
/// ```
mixin PaginatedBloc<T, E, S extends PaginatedState<T>> on BaseBloc<E, S> {
  /// Initial page size. Can be overridden.
  int get firstPageSize => 20;

  /// Size of subsequent pages. Can be overridden.
  int get nextPageSize => 20;

  /// Subclass implements — fetches page from data source.
  Future<(List<T> items, bool hasMore, int nextOffset)> fetchPage(
    int offset,
    int size,
  );

  /// Subclass implements — updates current state with pagination fields.
  S paginatedState({
    List<T>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  });

  /// True while a page request of the current generation is in flight.
  bool _pBusy = false;
  int _pLastOffset = -1;

  /// Bumped by every [handleLoadInitial]. A request only applies its result
  /// if the generation it started in is still current — so a reload (new
  /// search / filter / refresh) always wins over anything still in flight.
  int _pGeneration = 0;

  /// Whether a page request is currently in flight (for "loading more" UI).
  bool get isFetchingPage => _pBusy;

  /// Load initial page helper
  /// Must be called inside event handler
  ///
  /// Never skipped: it supersedes any in-flight request. (Bloc runs handlers
  /// concurrently — the previous "return if busy" silently dropped a new
  /// search typed while a page was loading, leaving an empty list, and let a
  /// late page of the old query append itself to the new results.)
  Future<void> handleLoadInitial(Emitter<S> emit) async {
    final generation = ++_pGeneration;
    _pBusy = true;
    _pLastOffset = -1;
    emit(paginatedState(isLoading: true, clearError: true));
    try {
      final (items, hasMore, next) = await fetchPage(0, firstPageSize);
      if (generation != _pGeneration || emit.isDone) return;
      emit(
        paginatedState(
          items: items,
          hasMore: hasMore,
          nextOffset: next,
          isLoading: false,
        ),
      );
    } catch (e) {
      if (generation != _pGeneration || emit.isDone) return;
      emit(paginatedState(isLoading: false, errorMessage: '$e'));
    } finally {
      if (generation == _pGeneration) _pBusy = false;
    }
  }

  /// Load more pages helper
  /// Must be called inside event handler
  ///
  /// Ignored while any request is in flight or when there is nothing more.
  /// A result arriving after a newer [handleLoadInitial] is discarded.
  Future<void> handleLoadMore(Emitter<S> emit) async {
    if (_pBusy || !state.hasMore) return;
    final currentOffset = state.nextOffset;
    if (_pLastOffset == currentOffset) return;
    final generation = _pGeneration;
    _pLastOffset = currentOffset;
    _pBusy = true;
    try {
      final (items, hasMore, next) = await fetchPage(
        currentOffset,
        nextPageSize,
      );
      if (generation != _pGeneration || emit.isDone) return;
      emit(
        paginatedState(
          items: [...state.items, ...items],
          hasMore: hasMore,
          nextOffset: next,
        ),
      );
    } catch (e) {
      if (generation != _pGeneration || emit.isDone) return;
      _pLastOffset = -1;
      emit(paginatedState(errorMessage: '$e'));
    } finally {
      if (generation == _pGeneration) _pBusy = false;
    }
  }

  /// Remove item at index helper
  /// Must be called inside event handler
  void handleRemoveAt(int index, Emitter<S> emit) {
    final current = state.items;
    if (index < 0 || index >= current.length) return;
    emit(paginatedState(items: [...current]..removeAt(index)));
  }

  /// Remove items matching test helper
  /// Must be called inside event handler
  void handleRemoveWhere(bool Function(T item) test, Emitter<S> emit) {
    emit(paginatedState(items: state.items.where((e) => !test(e)).toList()));
  }
}
