import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'view/compare_screen.dart';

final class CompareNavigator {
  static const String _subPath = 'compare';
  static const String path = '/pokemon/$_subPath';

  static GoRoute get route => GoRoute(
    path: _subPath,
    builder: (_, state) {
      final pokemons = state.extra as List<Pokemon>;
      return CompareScreen(pokemons: pokemons);
    },
  );

  static void show(BuildContext context, {required List<Pokemon> pokemons}) {
    assert(pokemons.isNotEmpty && pokemons.length <= 5);
    context.go(path, extra: pokemons);
  }
}
