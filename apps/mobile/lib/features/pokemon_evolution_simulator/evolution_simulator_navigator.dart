import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'view/evolution_simulator_screen.dart';

class EvolutionSimulatorArgs {
  final EvolutionChain chain;
  final int initialPokemonId;

  const EvolutionSimulatorArgs({
    required this.chain,
    required this.initialPokemonId,
  });
}

final class EvolutionSimulatorNavigator {
  static const String _subPath = 'evolution-simulator';
  static const String path = '/pokemon/$_subPath';

  static GoRoute get route => GoRoute(
    path: _subPath,
    builder: (_, state) {
      final args = state.extra as EvolutionSimulatorArgs;
      return EvolutionSimulatorScreen(
        chain: args.chain,
        initialPokemonId: args.initialPokemonId,
      );
    },
  );

  static void show(
    BuildContext context, {
    required EvolutionChain chain,
    required int initialPokemonId,
  }) {
    context.push(
      path,
      extra: EvolutionSimulatorArgs(
        chain: chain,
        initialPokemonId: initialPokemonId,
      ),
    );
  }
}
