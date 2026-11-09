import '../../domain/entity/pokemon_sprites_entity.dart';

class PokemonSpritesDto {
  final String? frontDefault;
  final String? frontShiny;
  final String? backDefault;
  final String? backShiny;
  final PokemonOtherSpritesDto? other;

  PokemonSpritesDto({
    this.frontDefault,
    this.frontShiny,
    this.backDefault,
    this.backShiny,
    this.other,
  });

  factory PokemonSpritesDto.fromJson(Map<String, dynamic> json) {
    return PokemonSpritesDto(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
      backDefault: json['back_default'] as String?,
      backShiny: json['back_shiny'] as String?,
      other: json['other'] != null
          ? PokemonOtherSpritesDto.fromJson(
              json['other'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  PokemonSprites toDomain() {
    return PokemonSprites(
      frontDefault: frontDefault,
      frontShiny: frontShiny,
      backDefault: backDefault,
      backShiny: backShiny,
      other: other != null
          ? PokemonOtherSprites(
              officialArtwork: other!.officialArtwork != null
                  ? OfficialArtwork(
                      frontDefault: other!.officialArtwork!.frontDefault,
                      frontShiny: other!.officialArtwork!.frontShiny,
                    )
                  : null,
              dreamWorld: other!.dreamWorld != null
                  ? DreamWorld(frontDefault: other!.dreamWorld!.frontDefault)
                  : null,
              showdown: other!.showdown != null
                  ? ShowdownSprites(
                      frontDefault: other!.showdown!.frontDefault,
                      frontShiny: other!.showdown!.frontShiny,
                    )
                  : null,
              home: other!.home != null
                  ? HomeSprites(
                      frontDefault: other!.home!.frontDefault,
                      frontShiny: other!.home!.frontShiny,
                    )
                  : null,
            )
          : null,
    );
  }
}

class PokemonOtherSpritesDto {
  final OfficialArtworkDto? officialArtwork;
  final DreamWorldDto? dreamWorld;
  final ShowdownSpritesDto? showdown;
  final HomeSpritesDto? home;

  PokemonOtherSpritesDto({
    this.officialArtwork,
    this.dreamWorld,
    this.showdown,
    this.home,
  });

  factory PokemonOtherSpritesDto.fromJson(Map<String, dynamic> json) {
    return PokemonOtherSpritesDto(
      officialArtwork: json['official-artwork'] != null
          ? OfficialArtworkDto.fromJson(
              json['official-artwork'] as Map<String, dynamic>,
            )
          : null,
      dreamWorld: json['dream_world'] != null
          ? DreamWorldDto.fromJson(json['dream_world'] as Map<String, dynamic>)
          : null,
      showdown: json['showdown'] != null
          ? ShowdownSpritesDto.fromJson(
              json['showdown'] as Map<String, dynamic>,
            )
          : null,
      home: json['home'] != null
          ? HomeSpritesDto.fromJson(json['home'] as Map<String, dynamic>)
          : null,
    );
  }
}

class OfficialArtworkDto {
  final String? frontDefault;
  final String? frontShiny;

  OfficialArtworkDto({this.frontDefault, this.frontShiny});

  factory OfficialArtworkDto.fromJson(Map<String, dynamic> json) {
    return OfficialArtworkDto(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );
  }
}

class DreamWorldDto {
  final String? frontDefault;

  DreamWorldDto({this.frontDefault});

  factory DreamWorldDto.fromJson(Map<String, dynamic> json) {
    return DreamWorldDto(frontDefault: json['front_default'] as String?);
  }
}

class ShowdownSpritesDto {
  final String? frontDefault;
  final String? frontShiny;

  ShowdownSpritesDto({this.frontDefault, this.frontShiny});

  factory ShowdownSpritesDto.fromJson(Map<String, dynamic> json) {
    return ShowdownSpritesDto(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );
  }
}

class HomeSpritesDto {
  final String? frontDefault;
  final String? frontShiny;

  HomeSpritesDto({this.frontDefault, this.frontShiny});

  factory HomeSpritesDto.fromJson(Map<String, dynamic> json) {
    return HomeSpritesDto(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
    );
  }
}
