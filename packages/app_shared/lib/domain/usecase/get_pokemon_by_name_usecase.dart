import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class GetPokemonByNameUseCase {
  final PokemonRepository _repository;

  const GetPokemonByNameUseCase(this._repository);

  Future<Pokemon> call(String name) async {
    final result = await _repository.getByName(name);
    return result.when(
      ok: (data) => data,
      // Rethrow as-is: keeps statusCode (404 vs 5xx) for callers.
      err: (e) => throw e,
    );
  }
}
