import '../../domain/entity/pokemon_species_entity.dart';

class PokemonSpeciesDto {
  final int id;
  final String name;
  final String description;
  final String genus;
  final String? habitat;
  final List<String> eggGroups;
  final int genderRate;
  final String evolutionChainUrl;

  PokemonSpeciesDto({
    required this.id,
    required this.name,
    required this.description,
    required this.genus,
    this.habitat,
    required this.eggGroups,
    required this.genderRate,
    required this.evolutionChainUrl,
  });

  factory PokemonSpeciesDto.fromJson(Map<String, dynamic> json) {
    final flavorTexts = json['flavor_text_entries'] as List<dynamic>;
    final bestFlavor = flavorTexts.firstWhere(
      (e) => e['language']['name'] == 'tr',
      orElse: () => flavorTexts.firstWhere(
        (e) => e['language']['name'] == 'en',
        orElse: () => flavorTexts.first,
      ),
    );

    final genera = json['genera'] as List<dynamic>;
    final bestGenus = genera.firstWhere(
      (e) => e['language']['name'] == 'tr',
      orElse: () => genera.firstWhere(
        (e) => e['language']['name'] == 'en',
        orElse: () => genera.first,
      ),
    );

    return PokemonSpeciesDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: (bestFlavor['flavor_text'] as String)
          .replaceAll('\n', ' ')
          .replaceAll('\f', ' '),
      genus: bestGenus['genus'] as String,
      habitat: json['habitat']?['name'] as String?,
      eggGroups: (json['egg_groups'] as List<dynamic>)
          .map((e) => e['name'] as String)
          .toList(),
      genderRate: json['gender_rate'] as int,
      evolutionChainUrl: json['evolution_chain']['url'] as String,
    );
  }

  PokemonSpecies toDomain() {
    return PokemonSpecies(
      id: id,
      name: name,
      description: description,
      genus: genus,
      habitat: habitat,
      eggGroups: eggGroups,
      genderRate: genderRate,
      evolutionChainUrl: evolutionChainUrl,
    );
  }
}
