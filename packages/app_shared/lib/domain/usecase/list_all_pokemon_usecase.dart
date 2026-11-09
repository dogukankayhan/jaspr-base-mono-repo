import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../entity/pokemon_brief_entity.dart';
import '../repository/pokemon_repository.dart';

/// Every Pokémon as name + URL (no details) — e.g. for a sitemap.
class ListAllPokemonUseCase {
  final PokemonRepository _repository;

  const ListAllPokemonUseCase(this._repository);

  Future<Result<List<PokemonBrief>, ApiError>> call() => _repository.listAll();
}
