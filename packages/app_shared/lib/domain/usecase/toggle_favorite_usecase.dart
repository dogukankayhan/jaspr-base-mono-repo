import '../repository/favorites_repository.dart';

/// Use case for toggling favorite status of a Pokemon
class ToggleFavoriteUseCase {
  final FavoritesRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  Future<bool> call(int pokemonId) {
    return _repository.toggleFavorite(pokemonId);
  }
}
