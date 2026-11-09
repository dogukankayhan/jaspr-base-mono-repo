import 'package:app_shared/domain/entity/evolution_chain_entity.dart';

sealed class EvolutionSimulatorEvent {
  const EvolutionSimulatorEvent();
}

class EvolutionSimulatorStarted extends EvolutionSimulatorEvent {
  final EvolutionChain chain;
  final int initialPokemonId;

  const EvolutionSimulatorStarted({
    required this.chain,
    required this.initialPokemonId,
  });
}

class EvolutionSimulatorLevelChanged extends EvolutionSimulatorEvent {
  final int level;

  const EvolutionSimulatorLevelChanged(this.level);
}

class EvolutionSimulatorEvolve extends EvolutionSimulatorEvent {
  final int targetSpeciesId;

  const EvolutionSimulatorEvolve({required this.targetSpeciesId});
}

class EvolutionSimulatorPokemonSelected extends EvolutionSimulatorEvent {
  final int speciesId;

  const EvolutionSimulatorPokemonSelected(this.speciesId);
}
