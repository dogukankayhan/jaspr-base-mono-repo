abstract final class ListPokemonEndpoint {
  static const path = 'pokemon';
  static const listWrapperKey = 'results';
  static Map<String, dynamic> query({
    required int limit,
    required int offset,
  }) => {'limit': limit, 'offset': offset};
}

abstract final class GetPokemonDetailEndpoint {
  static String path(String name) => 'pokemon/$name';
}

abstract final class FilterPokemonByTypeEndpoint {
  static String path(String type) => 'type/$type';
}

abstract final class GetPokemonSpeciesEndpoint {
  static String path(String id) => 'pokemon-species/$id';
}

abstract final class GetEvolutionChainEndpoint {
  static String path(String id) => 'evolution-chain/$id';
}
