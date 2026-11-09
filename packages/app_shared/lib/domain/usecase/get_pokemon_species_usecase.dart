import '../entity/pokemon_species_entity.dart';
import '../repository/pokemon_repository.dart';

class GetPokemonSpeciesUseCase {
  final PokemonRepository _repository;

  const GetPokemonSpeciesUseCase(this._repository);

  Future<PokemonSpecies> call(String url) async {
    final result = await _repository.getSpecies(url);
    return result.when(
      ok: (data) => data,
      // Rethrow as-is: keeps statusCode (404 vs 5xx) for callers.
      err: (e) => throw e,
    );
  }
}
