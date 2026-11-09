class PokemonType {
  final int slot;
  final TypeInfo type;

  const PokemonType({required this.slot, required this.type});
}

class TypeInfo {
  final String name;
  final String url;

  const TypeInfo({required this.name, required this.url});
}
