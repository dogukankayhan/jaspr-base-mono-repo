import 'pokemon_ability_entity.dart';
import 'pokemon_move_entity.dart';
import 'pokemon_sprites_entity.dart';
import 'pokemon_stats_entity.dart';
import 'pokemon_type_entity.dart';

class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int? baseExperience;
  final List<PokemonType> types;
  final List<PokemonAbility> abilities;
  final PokemonStats stats;
  final PokemonSprites sprites;
  final List<PokemonMove> moves;
  final String speciesName;
  final String speciesUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    this.baseExperience,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.sprites,
    required this.speciesName,
    required this.speciesUrl,
    this.moves = const [],
  });
}
