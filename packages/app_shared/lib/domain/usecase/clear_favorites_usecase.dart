import '../repository/favorites_repository.dart';

/// Use case for clearing all favorites
class ClearFavoritesUseCase {
  final FavoritesRepository _repository;

  const ClearFavoritesUseCase(this._repository);

  Future<void> call() {
    return _repository.clearAll();
  }
}
