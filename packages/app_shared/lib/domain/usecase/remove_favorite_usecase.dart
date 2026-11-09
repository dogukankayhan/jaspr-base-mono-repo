import '../repository/favorites_repository.dart';

/// Use case for removing a Pokemon from favorites
class RemoveFavoriteUseCase {
  final FavoritesRepository _repository;

  const RemoveFavoriteUseCase(this._repository);

  Future<void> call(int pokemonId) {
    return _repository.removeFavorite(pokemonId);
  }
}
