import '../entity/evolution_chain_entity.dart';
import '../repository/pokemon_repository.dart';

class GetEvolutionChainUseCase {
  final PokemonRepository _repository;

  const GetEvolutionChainUseCase(this._repository);

  Future<EvolutionChain> call(String url) async {
    final result = await _repository.getEvolutionChain(url);
    return result.when(
      ok: (data) => data,
      // Rethrow as-is: keeps statusCode (404 vs 5xx) for callers.
      err: (e) => throw e,
    );
  }
}
