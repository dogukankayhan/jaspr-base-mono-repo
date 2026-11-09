import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class FilterPokemonByTypeUseCase {
  final PokemonRepository _repository;

  const FilterPokemonByTypeUseCase(this._repository);

  Future<(List<Pokemon>, bool, int)> call({
    required String type,
    required int size,
    required int offset,
  }) async {
    final result = await _repository.pageByType(type, size, offset);
    return result.when(
      ok: (data) => data,
      // Rethrow as-is: keeps statusCode (404 vs 5xx) for callers.
      err: (e) => throw e,
    );
  }
}
