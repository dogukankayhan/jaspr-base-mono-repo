import '../repository/favorites_repository.dart';

/// Use case for adding a Pokemon to favorites
class AddFavoriteUseCase {
  final FavoritesRepository _repository;

  const AddFavoriteUseCase(this._repository);

  Future<void> call(int pokemonId) {
    return _repository.addFavorite(pokemonId);
  }
}
