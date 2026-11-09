import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:kit_core/base_bloc/base_state.dart';

class EvolutionSimulatorState extends BaseState {
  final EvolutionChain? chain;
  final Map<int, Pokemon> pokemons; // speciesId -> Pokemon details
  final int currentPokemonId;
  final int currentLevel;
  final List<EvolutionNode>
  unlockedEvolutions; // list of nodes that can evolve to based on level

  const EvolutionSimulatorState({
    super.isLoading = false,
    super.isValid = false,
    super.errorMessage,
    this.chain,
    this.pokemons = const {},
    this.currentPokemonId = 0,
    this.currentLevel = 1,
    this.unlockedEvolutions = const [],
  });

  EvolutionSimulatorState copyWith({
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    EvolutionChain? chain,
    Map<int, Pokemon>? pokemons,
    int? currentPokemonId,
    int? currentLevel,
    List<EvolutionNode>? unlockedEvolutions,
    bool clearError = false,
  }) {
    return EvolutionSimulatorState(
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      chain: chain ?? this.chain,
      pokemons: pokemons ?? this.pokemons,
      currentPokemonId: currentPokemonId ?? this.currentPokemonId,
      currentLevel: currentLevel ?? this.currentLevel,
      unlockedEvolutions: unlockedEvolutions ?? this.unlockedEvolutions,
    );
  }

  Pokemon? get currentPokemon => pokemons[currentPokemonId];

  @override
  List<Object?> get props => [
    ...super.props,
    chain,
    pokemons,
    currentPokemonId,
    currentLevel,
    unlockedEvolutions,
  ];
}
