class PokemonSprites {
  final String? frontDefault;
  final String? frontShiny;
  final String? backDefault;
  final String? backShiny;
  final PokemonOtherSprites? other;

  const PokemonSprites({
    this.frontDefault,
    this.frontShiny,
    this.backDefault,
    this.backShiny,
    this.other,
  });
}

class PokemonOtherSprites {
  final OfficialArtwork? officialArtwork;
  final DreamWorld? dreamWorld;
  final ShowdownSprites? showdown;
  final HomeSprites? home;

  const PokemonOtherSprites({
    this.officialArtwork,
    this.dreamWorld,
    this.showdown,
    this.home,
  });
}

class OfficialArtwork {
  final String? frontDefault;
  final String? frontShiny;

  const OfficialArtwork({this.frontDefault, this.frontShiny});
}

class DreamWorld {
  final String? frontDefault;

  const DreamWorld({this.frontDefault});
}

class ShowdownSprites {
  final String? frontDefault;
  final String? frontShiny;

  const ShowdownSprites({this.frontDefault, this.frontShiny});
}

class HomeSprites {
  final String? frontDefault;
  final String? frontShiny;

  const HomeSprites({this.frontDefault, this.frontShiny});
}
