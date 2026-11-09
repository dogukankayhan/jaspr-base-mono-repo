import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class PokemonDetailNavigator {
  static void show(
    BuildContext context, {
    required int pokemonId,
    Pokemon? pokemon,
  }) {
    final branch =
        GoRouterState.of(context).uri.pathSegments.firstOrNull ?? 'pokemon';
    context.push('/$branch/pokemon/$pokemonId', extra: pokemon);
  }
}
