import 'package:app_shared/domain/constants/pokemon_types.dart';
import 'package:flutter/material.dart';

class PokemonUtils {
  /// Type colors come from the shared catalog so mobile and web match.
  static Color getTypeColor(String typeName) =>
      Color(PokemonTypes.colorOf(typeName));

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static Color getStatColor(double percentage) {
    if (percentage >= 0.7) return Colors.green;
    if (percentage >= 0.4) return Colors.orange;
    return Colors.red;
  }

  // Gen 5 Black/White animated sprite — available for Pokémon #1–649.
  // Returns null for IDs without an animated sprite (Gen 6+).
  static String? animatedSpriteUrl(int id) {
    if (id < 1 || id > 649) return null;
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
        'sprites/pokemon/versions/generation-v/black-white/animated/$id.gif';
  }
}
