import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class GetPokemonPageUseCase {
  final PokemonRepository _repository;

  const GetPokemonPageUseCase(this._repository);

  Future<(List<Pokemon>, bool, int)> call({
    required int size,
    required int offset,
  }) async {
    final result = await _repository.pageWithSize(size, offset);
    return result.when(
      ok: (data) => data,
      // Rethrow as-is: keeps statusCode (404 vs 5xx) for callers.
      err: (e) => throw e,
    );
  }
}
