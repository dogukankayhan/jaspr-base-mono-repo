import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';

import '../entity/pokemon_entity.dart';
import '../repository/pokemon_repository.dart';

class GetPokemonForCompareUseCase {
  final PokemonRepository _repository;

  const GetPokemonForCompareUseCase(this._repository);

  Future<Result<Pokemon, ApiError>> call(String nameOrId) {
    final id = int.tryParse(nameOrId.trim());
    return id != null
        ? _repository.getById(id)
        : _repository.getByName(nameOrId.trim().toLowerCase());
  }
}
