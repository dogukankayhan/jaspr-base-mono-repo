class PokemonSpecies {
  final int id;
  final String name;
  final String description;
  final String genus;
  final String? habitat;
  final List<String> eggGroups;
  final int genderRate;
  final String evolutionChainUrl;

  const PokemonSpecies({
    required this.id,
    required this.name,
    required this.description,
    required this.genus,
    this.habitat,
    required this.eggGroups,
    required this.genderRate,
    required this.evolutionChainUrl,
  });
  double get malePercentage =>
      genderRate == -1 ? 0 : (100 - (genderRate / 8 * 100));
  double get femalePercentage => genderRate == -1 ? 0 : (genderRate / 8 * 100);
  bool get isGenderless => genderRate == -1;
}
