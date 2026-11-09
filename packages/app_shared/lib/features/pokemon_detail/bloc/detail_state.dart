import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:kit_core/base_bloc/base_state.dart';
import '../../../domain/entity/pokemon_entity.dart';
import '../../../domain/entity/pokemon_species_entity.dart';

class DetailState extends BaseState {
  final Pokemon? pokemon;
  final PokemonSpecies? species;
  final EvolutionChain? evolutionChain;
  final bool isFavorite;
  final bool isEvolutionLoading;

  const DetailState({
    this.pokemon,
    this.species,
    this.evolutionChain,
    this.isFavorite = false,
    this.isEvolutionLoading = false,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  DetailState copyWith({
    Pokemon? pokemon,
    PokemonSpecies? species,
    EvolutionChain? evolutionChain,
    bool? isFavorite,
    bool? isEvolutionLoading,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DetailState(
      pokemon: pokemon ?? this.pokemon,
      species: species ?? this.species,
      evolutionChain: evolutionChain ?? this.evolutionChain,
      isFavorite: isFavorite ?? this.isFavorite,
      isEvolutionLoading: isEvolutionLoading ?? this.isEvolutionLoading,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const empty = DetailState();

  @override
  List<Object?> get props => [
    pokemon,
    species,
    evolutionChain,
    isFavorite,
    isEvolutionLoading,
    isLoading,
    isValid,
    errorMessage,
  ];
}
