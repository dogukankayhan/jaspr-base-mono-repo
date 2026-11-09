import '../../domain/entity/pokemon_entity.dart';
import 'pokemon_ability_dto.dart';
import 'pokemon_move_dto.dart';
import 'pokemon_sprites_dto.dart';
import 'pokemon_stats_dto.dart';
import 'pokemon_type_dto.dart';

class PokemonDto {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int? baseExperience;
  final List<PokemonTypeDto> types;
  final List<PokemonAbilityDto> abilities;
  final PokemonStatsDto stats;
  final PokemonSpritesDto sprites;
  final List<PokemonMoveDto> moves;
  final String speciesName;
  final String speciesUrl;

  PokemonDto({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    this.baseExperience,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.sprites,
    required this.moves,
    required this.speciesName,
    required this.speciesUrl,
  });

  factory PokemonDto.fromJson(
    Map<String, dynamic> json, {
    bool includeMoves = true,
  }) {
    final statsData = json['stats'] as List<dynamic>?;
    final stats = statsData != null
        ? PokemonStatsDto.fromStatsList(statsData)
        : PokemonStatsDto(
            hp: 0,
            attack: 0,
            defense: 0,
            specialAttack: 0,
            specialDefense: 0,
            speed: 0,
          );

    final species = json['species'] as Map<String, dynamic>;

    return PokemonDto(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      baseExperience: json['base_experience'] as int?,
      types: (json['types'] as List<dynamic>)
          .map((e) => PokemonTypeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      abilities: (json['abilities'] as List<dynamic>)
          .map((e) => PokemonAbilityDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      stats: stats,
      sprites: PokemonSpritesDto.fromJson(
        json['sprites'] as Map<String, dynamic>,
      ),
      speciesName: species['name'] as String,
      speciesUrl: species['url'] as String,
      moves: includeMoves
          ? (json['moves'] as List<dynamic>?)
                    ?.map(
                      (e) => PokemonMoveDto.fromJson(e as Map<String, dynamic>),
                    )
                    .toList() ??
                []
          : [],
    );
  }

  Pokemon toDomain() {
    return Pokemon(
      id: id,
      name: name,
      height: height,
      weight: weight,
      baseExperience: baseExperience,
      types: types.map((e) => e.toDomain()).toList(),
      abilities: abilities.map((e) => e.toDomain()).toList(),
      stats: stats.toDomain(),
      sprites: sprites.toDomain(),
      speciesName: speciesName,
      speciesUrl: speciesUrl,
      moves: moves.map((e) => e.toDomain()).toList(),
    );
  }
}
