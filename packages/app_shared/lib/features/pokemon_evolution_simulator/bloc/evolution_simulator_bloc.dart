import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/repository/pokemon_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_network/core/di/locator.dart';

import 'evolution_simulator_event.dart';
import 'evolution_simulator_state.dart';

class EvolutionSimulatorBloc
    extends BaseBloc<EvolutionSimulatorEvent, EvolutionSimulatorState> {
  final PokemonRepository _pokemonRepository;

  EvolutionSimulatorBloc.create()
    : this(pokemonRepository: getIt<PokemonRepository>());

  EvolutionSimulatorBloc({required PokemonRepository pokemonRepository})
    : _pokemonRepository = pokemonRepository,
      super(const EvolutionSimulatorState()) {
    on<EvolutionSimulatorStarted>(_onStarted);
    on<EvolutionSimulatorLevelChanged>(_onLevelChanged);
    on<EvolutionSimulatorPokemonSelected>(_onPokemonSelected);
    on<EvolutionSimulatorEvolve>(_onEvolve);
  }

  Future<void> _onStarted(
    EvolutionSimulatorStarted event,
    Emitter<EvolutionSimulatorState> emit,
  ) async {
    final initialNode = _findNode(event.chain.root, event.initialPokemonId);
    final initialLevel = (initialNode != null && initialNode.minLevel != null)
        ? initialNode.minLevel!
        : 1;

    emit(
      state.copyWith(
        isLoading: true,
        chain: event.chain,
        currentPokemonId: event.initialPokemonId,
        currentLevel: initialLevel,
      ),
    );

    try {
      final ids = _getAllSpeciesIds(event.chain.root);
      final detailResults = await Future.wait(
        ids.map((id) => _pokemonRepository.getById(id)),
      );

      final pokemonsMap = <int, Pokemon>{};
      String? apiErrorMessage;

      for (final res in detailResults) {
        res.when(
          ok: (pokemon) => pokemonsMap[pokemon.id] = pokemon,
          err: (err) => apiErrorMessage = err.message,
        );
      }

      if (apiErrorMessage != null) {
        emit(state.copyWith(isLoading: false, errorMessage: apiErrorMessage));
        return;
      }

      emit(
        state.copyWith(
          pokemons: pokemonsMap,
          isLoading: false,
          isValid: true,
          unlockedEvolutions: _calculateUnlockedEvolutions(
            event.initialPokemonId,
            initialLevel,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Evrim ağacı yüklenemedi',
        ),
      );
    }
  }

  void _onLevelChanged(
    EvolutionSimulatorLevelChanged event,
    Emitter<EvolutionSimulatorState> emit,
  ) {
    emit(
      state.copyWith(
        currentLevel: event.level,
        unlockedEvolutions: _calculateUnlockedEvolutions(
          state.currentPokemonId,
          event.level,
        ),
      ),
    );
  }

  void _onPokemonSelected(
    EvolutionSimulatorPokemonSelected event,
    Emitter<EvolutionSimulatorState> emit,
  ) {
    if (!state.pokemons.containsKey(event.speciesId)) return;
    if (state.chain == null) return;

    final targetNode = _findNode(state.chain!.root, event.speciesId);
    final targetLevel = (targetNode != null && targetNode.minLevel != null)
        ? targetNode.minLevel!
        : 1;

    emit(
      state.copyWith(
        currentPokemonId: event.speciesId,
        currentLevel: targetLevel,
        unlockedEvolutions: _calculateUnlockedEvolutions(
          event.speciesId,
          targetLevel,
        ),
      ),
    );
  }

  void _onEvolve(
    EvolutionSimulatorEvolve event,
    Emitter<EvolutionSimulatorState> emit,
  ) {
    if (!state.pokemons.containsKey(event.targetSpeciesId)) return;

    emit(
      state.copyWith(
        currentPokemonId: event.targetSpeciesId,
        unlockedEvolutions: _calculateUnlockedEvolutions(
          event.targetSpeciesId,
          state.currentLevel,
        ),
      ),
    );
  }

  // Recursive helper to get all unique species IDs from the chain tree
  List<int> _getAllSpeciesIds(EvolutionNode node) {
    final ids = [node.speciesId];
    for (final child in node.evolvesTo) {
      ids.addAll(_getAllSpeciesIds(child));
    }
    return ids.toSet().toList(); // Ensure unique IDs
  }

  // Recursively search the tree to find a node by species ID
  EvolutionNode? _findNode(EvolutionNode node, int targetId) {
    if (node.speciesId == targetId) return node;
    for (final child in node.evolvesTo) {
      final found = _findNode(child, targetId);
      if (found != null) return found;
    }
    return null;
  }

  List<EvolutionNode> _calculateUnlockedEvolutions(int pokemonId, int level) {
    if (state.chain == null) return [];
    final currentNode = _findNode(state.chain!.root, pokemonId);
    if (currentNode == null) return [];

    final unlocked = <EvolutionNode>[];
    for (final child in currentNode.evolvesTo) {
      if (child.triggerName == 'level-up') {
        // minLevel == null means no specific level requirement (e.g. friendship-based)
        if (child.minLevel == null || level >= child.minLevel!) {
          unlocked.add(child);
        }
      } else {
        // Other triggers (use-item, trade, etc.) are always available in simulator
        unlocked.add(child);
      }
    }
    return unlocked;
  }
}
