import '../../domain/entity/pokemon_type_entity.dart';

class PokemonTypeDto {
  final int slot;
  final String typeName;
  final String typeUrl;

  PokemonTypeDto({
    required this.slot,
    required this.typeName,
    required this.typeUrl,
  });

  factory PokemonTypeDto.fromJson(Map<String, dynamic> json) {
    return PokemonTypeDto(
      slot: json['slot'] as int,
      typeName: json['type']['name'] as String,
      typeUrl: json['type']['url'] as String,
    );
  }

  PokemonType toDomain() {
    return PokemonType(
      slot: slot,
      type: TypeInfo(name: typeName, url: typeUrl),
    );
  }
}
