import '../../domain/entity/pokemon_ability_entity.dart';

class PokemonAbilityDto {
  final bool isHidden;
  final int slot;
  final String abilityName;
  final String abilityUrl;

  PokemonAbilityDto({
    required this.isHidden,
    required this.slot,
    required this.abilityName,
    required this.abilityUrl,
  });

  factory PokemonAbilityDto.fromJson(Map<String, dynamic> json) {
    return PokemonAbilityDto(
      isHidden: json['is_hidden'] as bool,
      slot: json['slot'] as int,
      abilityName: json['ability']['name'] as String,
      abilityUrl: json['ability']['url'] as String,
    );
  }

  PokemonAbility toDomain() {
    return PokemonAbility(
      isHidden: isHidden,
      slot: slot,
      ability: AbilityInfo(name: abilityName, url: abilityUrl),
    );
  }
}
