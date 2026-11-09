/// Pokémon type catalog shared by mobile and web: which types the home screen
/// offers as quick filters, and each type's brand color (ARGB int — wrap it in
/// `Color(...)` on Flutter, `cssHex(...)` on the web).
abstract final class PokemonTypes {
  /// Quick-filter chips on the home screen, in display order.
  static const List<String> filterable = [
    'fire',
    'water',
    'grass',
    'electric',
    'psychic',
    'ice',
    'dragon',
    'dark',
    'fairy',
    'fighting',
  ];

  /// Used for unknown types.
  static const int fallbackColor = 0xFF9E9E9E;

  static const Map<String, int> _colors = {
    'normal': 0xFFA8A878,
    'fire': 0xFFF08030,
    'water': 0xFF6890F0,
    'electric': 0xFFF8D030,
    'grass': 0xFF78C850,
    'ice': 0xFF98D8D8,
    'fighting': 0xFFC03028,
    'poison': 0xFFA040A0,
    'ground': 0xFFE0C068,
    'flying': 0xFFA890F0,
    'psychic': 0xFFF85888,
    'bug': 0xFFA8B820,
    'rock': 0xFFB8A038,
    'ghost': 0xFF705898,
    'dragon': 0xFF7038F8,
    'dark': 0xFF705848,
    'steel': 0xFFB8B8D0,
    'fairy': 0xFFEE99AC,
  };

  /// ARGB color for [type] (case-insensitive), or [fallbackColor].
  static int colorOf(String type) =>
      _colors[type.toLowerCase()] ?? fallbackColor;
}
