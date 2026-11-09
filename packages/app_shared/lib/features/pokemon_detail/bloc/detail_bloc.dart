import 'dart:async';
import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:app_shared/domain/usecase/get_evolution_chain_usecase.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_network/core/di/locator.dart';
import '../../../domain/entity/pokemon_entity.dart';
import '../../../domain/usecase/get_pokemon_by_id_usecase.dart';
import '../../../domain/usecase/get_pokemon_species_usecase.dart';
import 'detail_state.dart';

/// Detail Events
sealed class DetailEvent {}

class DetailLoad extends DetailEvent {
  final int pokemonId;
  DetailLoad(this.pokemonId);
}

class DetailToggleFavorite extends DetailEvent {}

class DetailFavoritesUpdated extends DetailEvent {
  final Set<int> favoriteIds;
  DetailFavoritesUpdated(this.favoriteIds);
}

/// Detail Bloc
class DetailBloc extends BaseBloc<DetailEvent, DetailState> {
  final GetPokemonByIdUseCase _getPokemonByIdUseCase;
  final GetPokemonSpeciesUseCase _getPokemonSpeciesUseCase;
  final GetEvolutionChainUseCase _getEvolutionChainUseCase;
  final FavoritesRepository _favoritesRepo;
  int? _currentPokemonId;
  StreamSubscription? _favoritesSubscription;

  DetailBloc.create({Pokemon? initialPokemon})
    : this(
        getPokemonByIdUseCase: GetPokemonByIdUseCase(
          getIt<PokemonRepository>(),
        ),
        getPokemonSpeciesUseCase: GetPokemonSpeciesUseCase(
          getIt<PokemonRepository>(),
        ),
        getEvolutionChainUseCase: GetEvolutionChainUseCase(
          getIt<PokemonRepository>(),
        ),
        favoritesRepo: getIt<FavoritesRepository>(),
        initialPokemon: initialPokemon,
      );

  DetailBloc({
    required GetPokemonByIdUseCase getPokemonByIdUseCase,
    required GetPokemonSpeciesUseCase getPokemonSpeciesUseCase,
    required GetEvolutionChainUseCase getEvolutionChainUseCase,
    required FavoritesRepository favoritesRepo,
    Pokemon? initialPokemon,
  }) : _getPokemonByIdUseCase = getPokemonByIdUseCase,
       _getPokemonSpeciesUseCase = getPokemonSpeciesUseCase,
       _getEvolutionChainUseCase = getEvolutionChainUseCase,
       _favoritesRepo = favoritesRepo,
       super(DetailState(pokemon: initialPokemon)) {
    _favoritesSubscription = _favoritesRepo.favoriteIdsStream.listen((ids) {
      add(DetailFavoritesUpdated(ids));
    });

    on<DetailFavoritesUpdated>((event, emit) {
      if (_currentPokemonId != null) {
        final isFavorite = event.favoriteIds.contains(_currentPokemonId);
        emit(state.copyWith(isFavorite: isFavorite));
      }
    });

    on<DetailLoad>((event, emit) async {
      _currentPokemonId = event.pokemonId;
      emit(
        state.copyWith(
          isLoading: true,
          clearError: true,
          isEvolutionLoading: true,
        ),
      );

      try {
        // Step 1: Fetch Basic Data & Favorite Status
        final results = await Future.wait([
          _getPokemonByIdUseCase(event.pokemonId),
          _favoritesRepo.isFavorite(event.pokemonId),
        ]);

        final pokemon = results[0] as Pokemon;
        final isFavorite = results[1] as bool;

        emit(state.copyWith(pokemon: pokemon, isFavorite: isFavorite));

        // Step 2: Fetch Species using the URL from Pokemon data
        final species = await _getPokemonSpeciesUseCase(pokemon.speciesUrl);

        emit(
          state.copyWith(
            species: species,
            isLoading: false,
            isEvolutionLoading: true,
          ),
        );

        // Step 3: Fetch Evolution Chain
        try {
          final evolutionChain = await _getEvolutionChainUseCase(
            species.evolutionChainUrl,
          );
          emit(
            state.copyWith(
              evolutionChain: evolutionChain,
              isEvolutionLoading: false,
              isValid: true,
            ),
          );
        } catch (e) {
          emit(state.copyWith(isEvolutionLoading: false, isValid: true));
        }
      } catch (e) {
        emit(
          state.copyWith(
            isLoading: false,
            isEvolutionLoading: false,
            errorMessage: 'Failed to load Pokemon details: $e',
          ),
        );
      }
    });

    on<DetailToggleFavorite>((event, emit) async {
      if (_currentPokemonId == null) return;

      try {
        await _favoritesRepo.toggleFavorite(_currentPokemonId!);
      } catch (e) {
        emit(state.copyWith(errorMessage: 'Failed to toggle favorite: $e'));
      }
    });
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
