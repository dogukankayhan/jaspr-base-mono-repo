import '../entity/pokemon_entity.dart';
import '../repository/favorites_repository.dart';

/// Use case for getting all favorite Pokemon with full details
class GetFavoritesUseCase {
  final FavoritesRepository _repository;

  const GetFavoritesUseCase(this._repository);

  Future<List<Pokemon>> call() {
    return _repository.getFavorites();
  }
}
