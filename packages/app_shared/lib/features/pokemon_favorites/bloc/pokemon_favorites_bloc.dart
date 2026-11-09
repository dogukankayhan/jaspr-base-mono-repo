import 'dart:async';
import 'package:app_shared/domain/usecase/clear_favorites_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_network/core/di/locator.dart';
import '../../../domain/repository/favorites_repository.dart';
import '../../../domain/usecase/get_favorites_usecase.dart';
import '../../../domain/usecase/remove_favorite_usecase.dart';
import 'pokemon_favorites_state.dart';

sealed class PokemonFavoritesEvent {}

class PokemonFavoritesLoad extends PokemonFavoritesEvent {}

class PokemonFavoritesRefresh extends PokemonFavoritesEvent {}

class PokemonFavoritesRemove extends PokemonFavoritesEvent {
  final int pokemonId;
  PokemonFavoritesRemove(this.pokemonId);
}

class PokemonFavoritesClearAll extends PokemonFavoritesEvent {}

class PokemonFavoritesBloc
    extends BaseBloc<PokemonFavoritesEvent, PokemonFavoritesState> {
  final GetFavoritesUseCase _getFavoritesUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;
  final ClearFavoritesUseCase _clearFavoritesUseCase;
  final FavoritesRepository _repository;
  StreamSubscription? _favoritesSubscription;

  PokemonFavoritesBloc.create()
    : this(
        GetFavoritesUseCase(getIt<FavoritesRepository>()),
        RemoveFavoriteUseCase(getIt<FavoritesRepository>()),
        ClearFavoritesUseCase(getIt<FavoritesRepository>()),
        getIt<FavoritesRepository>(),
      );

  PokemonFavoritesBloc(
    this._getFavoritesUseCase,
    this._removeFavoriteUseCase,
    this._clearFavoritesUseCase,
    this._repository,
  ) : super(const PokemonFavoritesState()) {
    _favoritesSubscription = _repository.favoriteIdsStream.listen(
      (_) => add(PokemonFavoritesRefresh()),
    );
    on<PokemonFavoritesLoad>(_onLoad);
    on<PokemonFavoritesRefresh>((_, _) => add(PokemonFavoritesLoad()));
    on<PokemonFavoritesRemove>(_onRemove);
    on<PokemonFavoritesClearAll>(_onClearAll);
  }

  @override
  void onReady() => add(PokemonFavoritesLoad());

  Future<void> _onLoad(
    PokemonFavoritesLoad event,
    Emitter<PokemonFavoritesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final favorites = await _getFavoritesUseCase();
      emit(
        state.copyWith(favorites: favorites, isLoading: false, isValid: true),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load favorites: $e',
        ),
      );
    }
  }

  Future<void> _onRemove(
    PokemonFavoritesRemove event,
    Emitter<PokemonFavoritesState> emit,
  ) async {
    try {
      await _removeFavoriteUseCase(event.pokemonId);
      final updated = state.favorites
          .where((p) => p.id != event.pokemonId)
          .toList();
      emit(state.copyWith(favorites: updated, clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to remove favorite: $e'));
    }
  }

  Future<void> _onClearAll(
    PokemonFavoritesClearAll event,
    Emitter<PokemonFavoritesState> emit,
  ) async {
    try {
      await _clearFavoritesUseCase();
      emit(state.copyWith(favorites: [], clearError: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to clear favorites: $e'));
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
