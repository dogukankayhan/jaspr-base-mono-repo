class PokemonAbility {
  final bool isHidden;
  final int slot;
  final AbilityInfo ability;

  const PokemonAbility({
    required this.isHidden,
    required this.slot,
    required this.ability,
  });
}

class AbilityInfo {
  final String name;
  final String url;

  const AbilityInfo({required this.name, required this.url});
}
