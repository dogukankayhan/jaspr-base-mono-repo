import 'package:app_shared/domain/entity/pokemon_entity.dart';

/// Abstract repository interface for favorites
abstract class FavoritesRepository {
  /// Stream of favorite Pokemon IDs
  Stream<Set<int>> get favoriteIdsStream;

  /// Get all favorite Pokemon with full details
  Future<List<Pokemon>> getFavorites();

  /// Add a Pokemon to favorites
  Future<void> addFavorite(int id);

  /// Remove a Pokemon from favorites
  Future<void> removeFavorite(int id);

  /// Check if a Pokemon is favorited
  Future<bool> isFavorite(int id);

  /// Toggle favorite status and return new status
  Future<bool> toggleFavorite(int id);

  /// Get favorite IDs only (without fetching full Pokemon data)
  Future<Set<int>> getFavoriteIds();

  /// Clear all favorites
  Future<void> clearAll();

  /// Dispose resources
  void dispose();
}
