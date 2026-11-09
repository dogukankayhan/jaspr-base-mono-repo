import '../../domain/entity/pokemon_stats_entity.dart';

class PokemonStatsDto {
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  PokemonStatsDto({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  factory PokemonStatsDto.fromJson(Map<String, dynamic> json) {
    return PokemonStatsDto(
      hp: json['hp'] as int,
      attack: json['attack'] as int,
      defense: json['defense'] as int,
      specialAttack: json['special_attack'] as int,
      specialDefense: json['special_defense'] as int,
      speed: json['speed'] as int,
    );
  }

  factory PokemonStatsDto.fromStatsList(List<dynamic> stats) {
    int findStat(String name) {
      final stat = stats.firstWhere(
        (s) => s['stat']['name'] == name,
        orElse: () => {'base_stat': 0},
      );
      return stat['base_stat'] as int;
    }

    return PokemonStatsDto(
      hp: findStat('hp'),
      attack: findStat('attack'),
      defense: findStat('defense'),
      specialAttack: findStat('special-attack'),
      specialDefense: findStat('special-defense'),
      speed: findStat('speed'),
    );
  }

  PokemonStats toDomain() {
    return PokemonStats(
      hp: hp,
      attack: attack,
      defense: defense,
      specialAttack: specialAttack,
      specialDefense: specialDefense,
      speed: speed,
    );
  }
}
