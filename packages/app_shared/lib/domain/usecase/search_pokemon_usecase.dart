import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class SearchPokemonUseCase {
  final PokemonRepository _repository;

  const SearchPokemonUseCase(this._repository);

  Future<(List<Pokemon>, bool, int)> call({
    required String query,
    required int size,
    required int offset,
  }) async {
    final result = await _repository.pageSearch(query, size, offset);
    return result.when(
      ok: (data) => data,
      // Rethrow as-is: keeps statusCode (404 vs 5xx) for callers.
      err: (e) => throw e,
    );
  }
}
